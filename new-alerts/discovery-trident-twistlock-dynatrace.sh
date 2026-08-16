#!/usr/bin/env bash
# Trident / Twistlock / Dynatrace kesif scripti (read-only).
# Kullanim: ./discovery-trident-twistlock-dynatrace.sh > discovery-output.txt 2>&1
# Cikti dosyasini paylasin; alarm YAML'larindaki namespace/deployment filtrelerini
# buna gore kesinlestirecegiz.

section() { echo; echo "########## $1 ##########"; }

section "CLUSTER INFO"
oc version
oc get clusterversion version -o jsonpath='{.status.desired.version}{"\n"}'

# ---------------------------------------------------------------- TRIDENT
section "TRIDENT - namespace tespiti"
oc get ns -o name | grep -iE "trident" || echo "trident namespace bulunamadi"
TNS=$(oc get ns -o name | grep -iE "trident" | head -1 | cut -d/ -f2)

if [ -n "$TNS" ]; then
  section "TRIDENT - workload adlari (alarm filtreleri icin kritik)"
  oc get deploy,ds -n "$TNS" -o wide
  oc get pods -n "$TNS" -o wide

  section "TRIDENT - backend durumu"
  oc get tridentbackendconfig -n "$TNS" 2>/dev/null || echo "tbc CRD yok/erisim yok"
  oc get tridentbackends -n "$TNS" 2>/dev/null

  section "TRIDENT - versiyon ve storage class"
  oc get tridentversions -n "$TNS" 2>/dev/null
  oc get sc

  section "TRIDENT - metrik endpoint testi (ServiceMonitor gerekli mi?)"
  TDEPLOY=$(oc get deploy -n "$TNS" -o name | grep -E "controller|csi" | head -1)
  oc exec -n "$TNS" "$TDEPLOY" -c trident-main -- \
    curl -s --max-time 5 localhost:8001/metrics 2>/dev/null | grep -E "^trident_(backend|volume)" | head -10 \
    || echo "metrik endpointine erisilemedi (container adi/port farkli olabilir)"

  section "TRIDENT - mevcut ServiceMonitor / scrape durumu"
  oc get servicemonitor -A 2>/dev/null | grep -i trident || echo "trident ServiceMonitor yok"
  oc get ns "$TNS" --show-labels
  oc get svc -n "$TNS"
fi

section "TRIDENT - PV/PVC genel durum"
oc get pv --no-headers | awk '{print $5}' | sort | uniq -c
oc get pvc -A --no-headers | grep -v Bound || echo "Bound olmayan PVC yok"

# ---------------------------------------------------------------- TWISTLOCK
section "TWISTLOCK - namespace tespiti"
oc get ns -o name | grep -iE "twistlock|prisma" || echo "twistlock namespace bulunamadi"
WNS=$(oc get ns -o name | grep -iE "twistlock|prisma" | head -1 | cut -d/ -f2)

if [ -n "$WNS" ]; then
  section "TWISTLOCK - workload adlari (DaemonSet adi alarm filtresi icin kritik)"
  oc get ds,deploy,sts -n "$WNS" -o wide
  oc get pods -n "$WNS" -o wide

  section "TWISTLOCK - defender kapsama (desired vs ready)"
  oc get ds -n "$WNS" -o custom-columns=NAME:.metadata.name,DESIRED:.status.desiredNumberScheduled,READY:.status.numberReady,AVAILABLE:.status.numberAvailable

  section "TWISTLOCK - defender versiyonu ve console tipi"
  oc get ds -n "$WNS" -o jsonpath='{range .items[*]}{.metadata.name}: {.spec.template.spec.containers[*].image}{"\n"}{end}'
  # In-cluster Console var mi? (self-hosted ise twistlock-console svc/sts gorunur)
  oc get svc -n "$WNS"

  section "TWISTLOCK - son eventler"
  oc get events -n "$WNS" --sort-by=.lastTimestamp 2>/dev/null | tail -10
fi

# ---------------------------------------------------------------- DYNATRACE
section "DYNATRACE - namespace tespiti"
oc get ns -o name | grep -iE "dynatrace" || echo "dynatrace namespace bulunamadi"
DNS=$(oc get ns -o name | grep -iE "dynatrace" | head -1 | cut -d/ -f2)

if [ -n "$DNS" ]; then
  section "DYNATRACE - DynaKube (ad ve faz alarm filtresi icin kritik)"
  oc get dynakube -n "$DNS" -o wide 2>/dev/null || echo "dynakube CRD yok"
  oc get dynakube -n "$DNS" -o jsonpath='{range .items[*]}{.metadata.name}: phase={.status.phase} oneagent-mode={.spec.oneAgent}{"\n"}{end}' 2>/dev/null

  section "DYNATRACE - workload adlari"
  oc get deploy,sts,ds -n "$DNS" -o wide
  oc get pods -n "$DNS" -o wide

  section "DYNATRACE - webhook failurePolicy (kritiklik seviyesini belirler)"
  oc get mutatingwebhookconfiguration 2>/dev/null | grep -i dynatrace
  oc get mutatingwebhookconfiguration dynatrace-webhook \
    -o jsonpath='{range .webhooks[*]}{.name}: failurePolicy={.failurePolicy}{"\n"}{end}' 2>/dev/null
fi

section "BITTI"
echo "Bu ciktiyi paylasin - alarm YAML'larindaki filtreleri kesinlestirelim."
