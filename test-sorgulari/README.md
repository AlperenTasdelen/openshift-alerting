# Prometheus Test Sorguları

`new-alerts/` klasöründeki **78 alert** için OpenShift arayüzünde
(Administrator → **Observe → Metrics**) test edilebilir PromQL sorguları:

| Dosya | Alert sayısı |
|---|---|
| [cluster-dynatrace-alerts](cluster-dynatrace-alerts.md) | 10 |
| [cluster-ingress-alerts](cluster-ingress-alerts.md) | 8 |
| [cluster-logging-alerts](cluster-logging-alerts.md) | 15 |
| [cluster-nvidia-gpu-alerts](cluster-nvidia-gpu-alerts.md) | 14 |
| [cluster-ovn-alerts](cluster-ovn-alerts.md) | 13 |
| [cluster-trident-alerts](cluster-trident-alerts.md) | 11 |
| [cluster-twistlock-alerts](cluster-twistlock-alerts.md) | 7 |

## Nasıl kullanılır

1. **Metriği görmek:** "Eşiksiz değer sorgusu"nu Observe → Metrics'e yapıştır; metriğin güncel değerini görürsün, eşiğe uzaklığını anlarsın.
2. **Firing olur muydu?:** "Alarm ifadesi"ni yapıştır. Sonuç **boş değilse** koşul şu an sağlanıyor demektir (`for:` süresi kadar sürerse alert firing olur).
3. **Kural uygulanmışsa:** Observe → Alerting → **Alerting rules** ekranında alert adıyla arat; state (inactive/pending/firing) görünür.

Genel durum sorguları:

```promql
ALERTS{alertstate="firing"}
```

```promql
count by (alertname) (ALERTS)
```

**Recording rule notu:** `cluster:...` / `node:...` isimleri PrometheusRule kümede uygulanmadıysa Prometheus'ta yoktur;
o durumda ilgili alertin "Genişletilmiş (recording rule'suz)" sorgusunu kullan.

**GPU kümesi notu:** DCGM metrikleri yalnızca GPU operator + dcgm-exporter kurulu kümede vardır.
Önce `DCGM_FI_DEV_GPU_UTIL` ile veri geldiğini doğrula; boşsa `kube_node_status_capacity{resource="nvidia_com_gpu"}` ile kapasiteyi kontrol et.
