# cluster-trident-alerts — test sorguları

[← Ana sayfa](README.md) · Kaynak: [cluster-trident-alerts.yaml](../new-alerts/cluster-trident-alerts.yaml)

## Alertler

- [ClusterTridentControllerDown](#clustertridentcontrollerdown) — critical
- [ClusterTridentOperatorDown](#clustertridentoperatordown) — high
- [ClusterTridentNodeUnavailableLow](#clustertridentnodeunavailablelow) — low
- [ClusterTridentNodeUnavailableHigh](#clustertridentnodeunavailablehigh) — high
- [ClusterTridentNodeUnavailableCritical](#clustertridentnodeunavailablecritical) — critical
- [ClusterTridentBackendNotOnline](#clustertridentbackendnotonline) — critical
- [ClusterTridentMetricsAbsent](#clustertridentmetricsabsent) — medium
- [ClusterPersistentVolumeFailed](#clusterpersistentvolumefailed) — high
- [NamespacePersistentVolumeClaimPending](#namespacepersistentvolumeclaimpending) — medium
- [ClusterTridentPodRestartsMedium](#clustertridentpodrestartsmedium) — medium
- [ClusterTridentPodRestartsCritical](#clustertridentpodrestartscritical) — critical

## Recording rules: cluster-trident-recording-rules

**`cluster:trident_node_unavailable:percent`**

```promql
(
  sum(kube_daemonset_status_number_unavailable{namespace="trident"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="trident"})
) * 100
```

## Grup: cluster-trident-controller-alerts

### ClusterTridentControllerDown

severity: **critical** · for: `5m`
 · _Trident CSI controller is down_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_deployment_status_replicas_available{namespace="trident",deployment=~"trident-controller|trident-csi"} == 0
```

Eşiksiz değer sorgusu (eşik: `== 0`):

```promql
kube_deployment_status_replicas_available{namespace="trident",deployment=~"trident-controller|trident-csi"}
```

### ClusterTridentOperatorDown

severity: **high** · for: `15m`
 · _Trident operator is down_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_deployment_status_replicas_available{namespace="trident",deployment="trident-operator"} == 0
```

Eşiksiz değer sorgusu (eşik: `== 0`):

```promql
kube_deployment_status_replicas_available{namespace="trident",deployment="trident-operator"}
```

## Grup: cluster-trident-node-alerts

### ClusterTridentNodeUnavailableLow

severity: **low** · for: `10m`
 · _Trident node pod unavailability is above 0%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:trident_node_unavailable:percent > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
cluster:trident_node_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="trident"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="trident"})
) * 100
) > 0
```

### ClusterTridentNodeUnavailableHigh

severity: **high** · for: `10m`
 · _Trident node pod unavailability is above 25%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:trident_node_unavailable:percent > 25
```

Eşiksiz değer sorgusu (eşik: `> 25`):

```promql
cluster:trident_node_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="trident"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="trident"})
) * 100
) > 25
```

### ClusterTridentNodeUnavailableCritical

severity: **critical** · for: `5m`
 · _Trident node pod unavailability is above 50%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:trident_node_unavailable:percent > 50
```

Eşiksiz değer sorgusu (eşik: `> 50`):

```promql
cluster:trident_node_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="trident"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="trident"})
) * 100
) > 50
```

## Grup: cluster-trident-backend-alerts

### ClusterTridentBackendNotOnline

severity: **critical** · for: `5m`
 · _Trident storage backend is not online_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
trident_backend_state != 1
```

Eşiksiz değer sorgusu (eşik: `!= 1`):

```promql
trident_backend_state
```

### ClusterTridentMetricsAbsent

severity: **medium** · for: `30m`
 · _Trident metrics are not being scraped_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
absent(trident_backend_count)
```

## Grup: cluster-trident-volume-alerts

### ClusterPersistentVolumeFailed

severity: **high** · for: `5m`
 · _One or more PersistentVolumes are in Failed state_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
sum(kube_persistentvolume_status_phase{phase="Failed"}) > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
sum(kube_persistentvolume_status_phase{phase="Failed"})
```

### NamespacePersistentVolumeClaimPending

severity: **medium** · for: `15m`
 · _PVC stuck in Pending state_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_persistentvolumeclaim_status_phase{phase="Pending"} == 1
```

Eşiksiz değer sorgusu (eşik: `== 1`):

```promql
kube_persistentvolumeclaim_status_phase{phase="Pending"}
```

## Grup: cluster-trident-pod-restart-alerts

### ClusterTridentPodRestartsMedium

severity: **medium** · for: `5m`
 · _Trident pod restarted more than 3 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="trident"}[1h]) > 3
```

Eşiksiz değer sorgusu (eşik: `> 3`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="trident"}[1h])
```

### ClusterTridentPodRestartsCritical

severity: **critical** · for: `5m`
 · _Trident pod restarted more than 10 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="trident"}[1h]) > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="trident"}[1h])
```
