# Kritik Bileşen Alarmları — İzleme Stratejisi ve Uygulama Dokümanı

Kapsam: `openshift-logging`, `trident`, `twistlock`, `dynatrace`, `openshift-ingress`, `nvidia-gpu-operator`, `openshift-ovn-kubernetes`

Tüm PrometheusRule dosyaları mevcut şablon stilini takip eder: `openshift-monitoring` namespace, recording rule + `scope` (cluster/node/namespace), `category`/`metric` etiketleri, low/medium/high/critical dörtlü eşik modeli.

Uygulama: `oc apply -f <dosya>.yaml`

**Versiyon uyumluluğu (OCP 4.18.30 – 4.20.22):** Tüm alarmlar bu aralıktaki her versiyonda aynı YAML ile çalışır. Kullanılan metrikler (kube-state-metrics, `template_router_reload_failure`, `ovnkube_node_cni_request_duration_seconds`, DCGM_*, vector_*) 4.18–4.20 arasında isim değiştirmemiştir. OVN interconnect mimarisi (`ovnkube-control-plane` + `ovnkube-node`) 4.14'ten beri geçerli olduğundan tüm kümelerinizde aynıdır. Logging 6.x'te ClusterLogForwarder CRD'si `observability.openshift.io` API grubuna taşınmıştır (eski `logging.openshift.io` boş döner) — alarmlar bundan etkilenmez, yalnızca kontrol komutları yeni grubu kullanmalıdır.

---

## Genel Mimari Notu

Alarmlar iki metrik kaynağına dayanır:

1. **Workload sağlığı (kube-state-metrics)** — her kümede hazır çalışır, ek kurulum gerektirmez. Deployment/DaemonSet/StatefulSet availability, pod restart.
2. **Ürün-native metrikler** — bileşenin kendi exporter'ının platform Prometheus tarafından scrape edilmesi gerekir. Aşağıda proje bazında ön koşullar belirtilmiştir.

Namespace'in platform Prometheus tarafından scrape edilmesi için:
```bash
oc get ns <namespace> --show-labels | grep openshift.io/cluster-monitoring
# yoksa: oc label ns <namespace> openshift.io/cluster-monitoring=true
```
Not: Red Hat, bu label'ı Red Hat dışı namespace'lerde resmi olarak desteklemez; alternatif User Workload Monitoring'dir (o durumda rule'lar `openshift-user-workload-monitoring`'e taşınmalıdır).

---

## 1. Logging (openshift-logging — Vector 6.2.x → Splunk)

**Neden kritik:** Collector durursa loglar Splunk/cryptolog'a akmaz; regülasyon ve adli analiz açısından log kaybı kabul edilemez.

**Ne izleniyor:**

| Alarm | Kaynak | Mantık |
|---|---|---|
| ClusterLoggingOperatorDown | KSM | cluster-logging-operator replicas == 0 |
| ClusterLoggingCollectorUnavailable{L/M/H/C} | KSM | Collector DaemonSet unavailable % (0/10/25/50) |
| ClusterLoggingVectorComponentErrors{L/M/H/C} | Vector | `vector_component_errors_total` rate (0.1/1/5/20 err/s) |
| ClusterLoggingSinkErrorsHigh | Vector | Sink (Splunk HEC) hata oranı > 0.1/s |
| ClusterLoggingForwardingStalled | Vector | Event alınıyor ama hiçbiri gönderilmiyor (kritik) |
| ClusterLoggingBufferDiscardedEvents{H/C} | Vector | Buffer'dan event düşüyor = log kaybı |
| ClusterLoggingPodRestarts{M/C} | KSM | 1 saatte >3 / >10 restart |

**Ön koşul:** Logging operatörü openshift-logging namespace'ine cluster-monitoring label'ını kendisi ekler; Vector metrikleri normalde otomatik scrape edilir. Doğrulama aşağıda.

**6.2.10 → 6.2.12 upgrade notu:** Upgrade sırasında collector rolling restart olur; `ClusterLoggingCollectorUnavailableLow` kısa süreli tetiklenebilir. Upgrade penceresinde silence önerilir.

**Durum kontrol komutları (çıktılarını paylaşabilirsiniz):**
```bash
oc get pods -n openshift-logging -o wide
# Logging 6.x: CLF artik observability.openshift.io API grubunda
oc get clusterlogforwarders.observability.openshift.io -A
oc get clusterlogforwarders.observability.openshift.io -A -o yaml | grep -B2 -A8 "type: splunk"
oc get ds -n openshift-logging
oc get csv -n openshift-logging | grep -i logging
# Vector metrikleri scrape ediliyor mu:
oc get servicemonitor -n openshift-logging
# Prometheus'ta metrik var mı (console → Observe → Metrics veya):
#   vector_component_errors_total  /  vector_component_sent_events_total
```

---

## 2. Trident (NetApp CSI)

**Neden kritik:** Controller düşerse yeni PVC provision/attach/resize yapılamaz; backend offline olursa provisioning tamamen durur. Mevcut mount'lar çalışmaya devam eder ama sorun büyümeden yakalanmalıdır.

**Ne izleniyor:**

| Alarm | Kaynak | Mantık |
|---|---|---|
| ClusterTridentControllerDown | KSM | trident-controller/trident-csi replicas == 0 (kritik) |
| ClusterTridentOperatorDown | KSM | trident-operator down |
| ClusterTridentNodeUnavailable{L/H/C} | KSM | Node DaemonSet unavailable % (0/25/50) |
| ClusterTridentBackendNotOnline | Native | `trident_backend_state != 1` (1=online) |
| ClusterTridentMetricsAbsent | Native | trident metrikleri hiç yoksa → scrape kırık |
| ClusterPersistentVolumeFailed | KSM | Failed PV var |
| NamespacePersistentVolumeClaimPending | KSM | PVC 15 dk Pending |
| ClusterTridentPodRestarts{M/C} | KSM | restart eşikleri |

**Ön koşul (native metrikler) — hedef küme keşfine göre:** ServiceMonitor YOK, namespace'te `openshift.io/cluster-monitoring` label'ı YOK → `ClusterTridentBackendNotOnline` şu an veri alamaz, `ClusterTridentMetricsAbsent` uygulandığında tetiklenir (beklenen davranış — kurulum tamamlanınca söner). `trident-csi` service'i metrik portunu 9220 (→ pod 8001) olarak sunar. Kurulum:

```bash
oc label ns trident openshift.io/cluster-monitoring=true
```
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: trident-sm
  namespace: trident
spec:
  jobLabel: trident
  selector:
    matchLabels: { app: controller.csi.trident.netapp.io }
  namespaceSelector:
    matchNames: [trident]
  endpoints:
  - port: metrics
    interval: 15s
```

Uygulamadan önce doğrulanacaklar (keşif scriptindeki endpoint testi sonuçsuz kaldı):
```bash
# metrics ozelligi acik mi (--metrics arguman listesinde olmali):
oc get deploy trident-controller -n trident -o jsonpath='{.spec.template.spec.containers[?(@.name=="trident-main")].args}'
# service uzerindeki metrik port adi ve label'lar (SM selector'u service LABEL'ina bakar):
oc get svc trident-csi -n trident --show-labels
oc get svc trident-csi -n trident -o jsonpath='{range .spec.ports[*]}{.name}: {.port} -> {.targetPort}{"\n"}{end}'
```

**Not (hedef kümede doğrulandı):** namespace `trident`, deployment `trident-controller`, DaemonSet `trident-node-linux` — alarmlar namespace-geneli toplama kullandığı için DS adı fark etmez. `trident-operator` deployment'ı bu kümede yok (tridentctl kurulumu); `ClusterTridentOperatorDown` alarmı metrik bulunamayacağı için sessiz kalır, operator'lü kümelerde çalışır — zararsız, kalabilir.

**Durum kontrol komutları:**
```bash
oc get pods -n trident -o wide
oc get tridentbackendconfig -n trident   # veya: tridentctl get backend -n trident
oc get tridentversions -n trident
oc get sc | grep -i trident
oc get pv | awk '{print $5}' | sort | uniq -c        # PV faz dağılımı
oc get pvc -A | grep -v Bound                         # Bound olmayan PVC'ler
# Metrik endpoint testi:
oc exec -n trident deploy/trident-controller -c trident-main -- curl -s localhost:8001/metrics | grep trident_backend
```

---

## 3. Twistlock / Prisma Cloud

**Neden kritik:** Defender DaemonSet'i runtime güvenlik korumasıdır; pod'lar düşerse ilgili node'lar korumasız kalır ve compliance ihlali doğar.

**Ne izleniyor:**

| Alarm | Kaynak | Mantık |
|---|---|---|
| ClusterTwistlockDefenderUnavailable{L/M/H/C} | KSM | Defender DS unavailable % (0/10/25/50) |
| ClusterTwistlockDefenderAbsent | KSM | twistlock namespace'inde hiç DaemonSet yok |
| ClusterTwistlockPodRestarts{M/C} | KSM | restart eşikleri |

**Keşif bulgusu (hedef küme):** Kümede yalnızca `defender` service'i var, Console bu kümede değil (merkezi). Defender'lar kendisi Prometheus metriği sunmadığı ve Console dışarıda olduğu için console tabanlı alarm grubu YAML'dan çıkarıldı; tüm alarmlar kube-state-metrics tabanlı. Defender DS yalnızca worker'larda (17/17) — yüzde tabanlı model bundan etkilenmez. Merkezi Console'un `/api/v1/metrics` endpoint'i ileride merkezi bir Prometheus'a bağlanırsa `twistlock_total_defenders` bazlı kapsama alarmı orada kurulmalıdır (küme içinde değil).

**Durum kontrol komutları:**
```bash
oc get pods -n twistlock -o wide
oc get ds -n twistlock
oc get ds -n twistlock twistlock-defender-ds -o jsonpath='{.status.desiredNumberScheduled} {.status.numberReady}{"\n"}'
oc get events -n twistlock --sort-by=.lastTimestamp | tail -20
```

---

## 4. Dynatrace

**Neden kritik:** OneAgent düşerse APM/infra gözlemlenebilirliği kaybolur; webhook düşerse yeni pod'lar enstrümante edilmeden başlar (failurePolicy'ye göre admission bile başarısız olabilir → bu yüzden webhook kritik seviyede).

**Ne izleniyor:**

| Alarm | Kaynak | Mantık |
|---|---|---|
| ClusterDynatraceOperatorDown | KSM | dynatrace-operator down |
| ClusterDynatraceWebhookDown | KSM | dynatrace-webhook down (high — failurePolicy=Ignore olduğundan admission engellenmez) |
| ClusterDynatraceActiveGateDegraded | KSM | ActiveGate STS ready < desired |
| ClusterDynatraceOneAgentUnavailable{L/M/H/C} | KSM | OneAgent DS unavailable % (0/10/25/50) |
| ClusterDynatraceOneAgentRolloutStuck | KSM | updated < desired 2 saatten uzun → autoUpdate rollout takıldı |
| ClusterDynatracePodRestarts{M/C} | KSM | restart eşikleri |

**Keşif bulgusu (hedef küme):** DynaKube adı küme adıyla aynı → DaemonSet `<dynakube>-oneagent`, StatefulSet `<dynakube>-activegate`. Alarmlar bilinçli olarak namespace-geneli toplama kullanır; küme başına değişen bu adlar filtrelere girmez, aynı YAML her kümede çalışır. Sabit adlar yalnızca `dynatrace-operator` ve `dynatrace-webhook` (operator standardı).

Canlı örnek: keşif anında worker-1'de OneAgent 13 gündür ImagePullBackOff'ta ve rollout 5/20'de takılı (DynaKube phase=Deploying). `ClusterDynatraceOneAgentUnavailableLow` (1/20 = %5) ve `ClusterDynatraceOneAgentRolloutStuck` bu durumu yakalardı.

webhook failurePolicy doğrulama (keşif scriptindeki jsonpath çalışmadı):
```bash
oc get mutatingwebhookconfiguration -o custom-columns=NAME:.metadata.name,POLICY:.webhooks[*].failurePolicy | grep dynatrace
```

**Not:** Dynatrace kendi verisini Dynatrace SaaS/Managed'e gönderir, cluster Prometheus'una metrik sunmaz; bu yüzden tüm alarmlar kube-state-metrics tabanlıdır. Dynatrace tarafında ayrıca "Kubernetes cluster connected" sağlık kuralı açılması önerilir (çift taraflı kontrol).

**Durum kontrol komutları:**
```bash
oc get pods -n dynatrace -o wide
oc get dynakube -n dynatrace -o wide          # durum sütunlarını içerir
oc get dynakube -n dynatrace -o jsonpath='{range .items[*]}{.metadata.name}: {.status.phase}{"\n"}{end}'
oc get sts,deploy,ds -n dynatrace
```

---

## 5. openshift-ingress

**Neden kritik:** Router tüm uygulama trafiğinin giriş noktasıdır. Mevcut `cluster-haproxy-alerts.yaml` trafik kalitesini (5xx, session, backend conn error) izliyor; bu dosya **router'ın kendisinin ayakta olmasını** ve **konfigürasyonun güncel kalmasını** tamamlar.

**Ne izleniyor:**

| Alarm | Kaynak | Mantık |
|---|---|---|
| ClusterIngressRouterAvailability{L/H} + RouterDown | KSM | router-* available % (<100/<75/==0) |
| ClusterIngressHAProxyReloadFail{H/C} | Router | `template_router_reload_failure == 1` (5dk/30dk) — route değişiklikleri uygulanmıyor |
| NamespaceIngressBackendDown | HAProxy | Route'un hiç sağlıklı endpoint'i yok → 503 |
| ClusterIngressRouterRestarts{M/C} | KSM | restart eşikleri |

**Durum kontrol komutları:**
```bash
oc get pods -n openshift-ingress -o wide
oc get ingresscontroller -n openshift-ingress-operator
oc get co ingress
# Reload durumu:
oc exec -n openshift-ingress deploy/router-default -- curl -s -u admin:$(oc get secret router-stats-default -n openshift-ingress -o jsonpath='{.data.statsPassword}' | base64 -d) localhost:1936/metrics | grep template_router_reload
```

---

## 6. NVIDIA GPU Operator

**Neden kritik:** GPU node'ları en pahalı kaynaklardır; driver/device-plugin sorunları GPU'ları schedule edilemez yapar, donanım hataları (XID, ECC DBE) iş kayıplarına yol açar.

**GPU'suz kümeler:** DCGM_* metrikleri bulunmadığından GPU alarmları otomatik pasif kalır; aynı YAML tüm kümelere güvenle uygulanabilir.

**Ne izleniyor:**

| Alarm | Kaynak | Mantık |
|---|---|---|
| ClusterNvidiaGpuOperatorDown | KSM | gpu-operator down |
| ClusterNvidiaDaemonsetUnavailable | KSM | driver/toolkit/plugin/DCGM DS'lerinde unavailable pod |
| ClusterGpuAllocatableBelowCapacity | KSM | allocatable < capacity → GPU scheduling'den düştü |
| ClusterDcgmMetricsAbsentOnGpuCluster | Mixed | GPU var ama DCGM metriği yok → izleme kör |
| NodeGpuTemperature{L/M/H/C} | DCGM | 78/83/88/92 °C |
| NodeGpuMemoryUtilization{L/H/C} | DCGM | FB %80/90/97 |
| NodeGpuXidErrorCritical | DCGM | XID > 0 (48=DBE, 79=bus'tan düştü vb.) |
| NodeGpuDoubleBitEccErrorCritical | DCGM | Yeni DBE → workload drain + donanım kontrolü |
| NodeGpuSingleBitEccErrorMedium | DCGM | 1 saatte >100 SBE → erken uyarı |

**Ön koşul:** NVIDIA kurulum dokümanına göre `nvidia-gpu-operator` namespace'inde `openshift.io/cluster-monitoring=true` label'ı olmalı (NVIDIA resmi olarak önerir). DCGM exporter ve ServiceMonitor operator ile birlikte gelir.

**Durum kontrol komutları (GPU'lu küme):**
```bash
oc get pods -n nvidia-gpu-operator -o wide
oc get clusterpolicy -o jsonpath='{.items[0].status.state}{"\n"}'
oc get ns nvidia-gpu-operator --show-labels
oc get node -l nvidia.com/gpu.present=true -o custom-columns=NAME:.metadata.name,CAP:.status.capacity.nvidia\.com/gpu,ALLOC:.status.allocatable.nvidia\.com/gpu
oc exec -n nvidia-gpu-operator ds/nvidia-driver-daemonset -- nvidia-smi
# DCGM metrik testi:
oc exec -n nvidia-gpu-operator ds/nvidia-dcgm-exporter -- curl -s localhost:9400/metrics | grep -E "DCGM_FI_DEV_(GPU_TEMP|XID)"
```
**GPU'suz küme:** `oc get ns nvidia-gpu-operator` → NotFound beklenir; alarmlar sessiz kalır.

---

## 7. openshift-ovn-kubernetes

**Neden kritik:** OVN-K cluster SDN'idir. ovnkube-node degrade olursa yeni pod'lar network alamaz; control plane düşerse cluster genelinde IP tahsisi ve NetworkPolicy programlama durur.

**Ne izleniyor:**

| Alarm | Kaynak | Mantık |
|---|---|---|
| ClusterOvnControlPlane{Degraded/Down} | KSM | ovnkube-control-plane < desired / == 0 |
| ClusterOvnkubeNodeUnavailable{L/M/H/C} | KSM | ovnkube-node DS unavailable % (0/10/25/50) |
| ClusterOvnCniRequestDuration{L/M/H/C} | Native | CNI p99 latency 2.5/5/10/30 s — pod başlatma gecikmesi |
| ClusterOvnResourceRetryFailuresHigh | Native | `ovnkube_resource_retry_failures_total` artışı → manuel müdahale gereken objeler |
| ClusterOvnPodRestarts{M/C} | KSM | restart eşikleri |

**Not:** OVN native metrikleri platform tarafından zaten scrape edilir (openshift namespace'i). OCP'nin kendi default OVN alarmları (NorthdStale, OVNKubernetesNorthboundDatabaseCPUUsageHigh vb.) ile çakışma yoktur; bu set onları tamamlar. OCP versiyonunuz 4.14+ (interconnect mimarisi) varsayılmıştır — 4.13 ve öncesinde `ovnkube-master` deployment adı kullanılır, o durumda `ovnkube-control-plane` filtresini değiştirin.

**Durum kontrol komutları:**
```bash
oc get pods -n openshift-ovn-kubernetes -o wide
oc get co network
oc get network.operator cluster -o jsonpath='{.spec.defaultNetwork.type}{"\n"}'
# Mevcut default OVN alarmlarını görmek için:
oc get prometheusrule -n openshift-ovn-kubernetes -o yaml | grep "alert:" | sort -u
# CNI latency metriği var mı:
#   Console → Observe → Metrics → ovnkube_node_cni_request_duration_seconds_bucket
```

---

## Çoklu Küme: İsimlendirme Doğrulaması

Alarmlar mümkün olan her yerde namespace-geneli toplama kullanır; kümeden kümeye değişen adlar (Dynatrace DynaKube adı, Trident DS adı vb.) sorun çıkarmaz. Yalnızca aşağıdaki **sabit adlara** bağımlılık vardır; her kümede şu tek blok çalıştırılarak doğrulanır:

```bash
echo "== $(oc get clusterversion version -o jsonpath='{.status.desired.version}') =="
for ns in openshift-logging trident twistlock dynatrace openshift-ingress nvidia-gpu-operator openshift-ovn-kubernetes; do
  oc get ns "$ns" >/dev/null 2>&1 && echo "ns OK : $ns" || echo "ns YOK: $ns"
done
echo "--- alarmlarin bagimli oldugu sabit deployment adlari ---"
oc get deploy -n openshift-logging cluster-logging-operator --no-headers 2>/dev/null || echo "FARKLI: cluster-logging-operator"
oc get deploy -n trident trident-controller --no-headers 2>/dev/null || oc get deploy -n trident trident-csi --no-headers 2>/dev/null || echo "FARKLI: trident-controller/trident-csi"
oc get deploy -n dynatrace dynatrace-operator dynatrace-webhook --no-headers 2>/dev/null || echo "FARKLI: dynatrace-operator/webhook"
oc get deploy -n openshift-ovn-kubernetes ovnkube-control-plane --no-headers 2>/dev/null || echo "FARKLI: ovnkube-control-plane"
oc get deploy -n openshift-ingress --no-headers 2>/dev/null | grep ^router- || echo "FARKLI: router-*"
oc get ds -n twistlock twistlock-defender-ds --no-headers 2>/dev/null || echo "FARKLI: twistlock-defender-ds"
```

"FARKLI" satırı çıkan kümede yalnızca ilgili filtre güncellenir; "ns YOK" çıkan bileşenin alarmları o kümede sessiz kalır (GPU'suz kümede nvidia gibi — sorun değil). Namespace adları tüm kümelerde standartsa (görünüşe göre öyle) ayrı bir aksiyona gerek yok.

## Devreye Alma Sırası (öneri)

1. Tüm kümelerde yukarıdaki durum kontrol komutlarını çalıştırıp namespace/deployment adlarını doğrulayın (özellikle `trident`, `twistlock`, `dynatrace` namespace adları ve Dynatrace DynaKube/DaemonSet adları kurulumunuza göre değişebilir).
2. Workload-sağlık alarmları ek kurulum gerektirmediği için 7 YAML doğrudan uygulanabilir.
3. Trident ServiceMonitor'ünü kurun → `ClusterTridentMetricsAbsent` alarmının sönmesi doğrulama görevi görür.
4. Twistlock Console self-hosted ise Prometheus scrape config'i ekleyin; değilse console alarm grubunu silin.
5. 1–2 hafta gözlemleyip eşikleri (özellikle Vector error rate ve CNI latency) kümenizin baseline'ına göre ayarlayın.

## Bilinçli Tasarım Kararları

- Pod restart eşikleri tüm bileşenlerde aynı (1s'te >3 medium, >10 critical) — tutarlılık için.
- Availability alarmlarında yüzde tabanlı model kullanıldı; böylece 3 node'lu ve 50 node'lu kümelerde aynı YAML çalışır.
- `absent()` tabanlı alarmlar (Trident, DCGM, Twistlock) "izleme körlüğünü" yakalar — bileşen sağlıklı görünürken metrik akışının kesilmesi en sinsi arıza modudur.
- GPU utilization için alarm yerine yalnızca recording rule tanımlandı (yüksek GPU kullanımı hata değil, hedeftir); kapasite planlama panolarında kullanılabilir.
