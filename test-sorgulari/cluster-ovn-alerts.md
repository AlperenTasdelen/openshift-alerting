# cluster-ovn-alerts — test sorguları

[← Ana sayfa](README.md) · Kaynak: [cluster-ovn-alerts.yaml](../new-alerts/cluster-ovn-alerts.yaml)

## Alertler

- [ClusterOvnControlPlaneDegraded](#clusterovncontrolplanedegraded) — high
- [ClusterOvnControlPlaneDown](#clusterovncontrolplanedown) — critical
- [ClusterOvnkubeNodeUnavailableLow](#clusterovnkubenodeunavailablelow) — low
- [ClusterOvnkubeNodeUnavailableMedium](#clusterovnkubenodeunavailablemedium) — medium
- [ClusterOvnkubeNodeUnavailableHigh](#clusterovnkubenodeunavailablehigh) — high
- [ClusterOvnkubeNodeUnavailableCritical](#clusterovnkubenodeunavailablecritical) — critical
- [ClusterOvnCniRequestDurationLow](#clusterovncnirequestdurationlow) — low
- [ClusterOvnCniRequestDurationMedium](#clusterovncnirequestdurationmedium) — medium
- [ClusterOvnCniRequestDurationHigh](#clusterovncnirequestdurationhigh) — high
- [ClusterOvnCniRequestDurationCritical](#clusterovncnirequestdurationcritical) — critical
- [ClusterOvnResourceRetryFailuresHigh](#clusterovnresourceretryfailureshigh) — high
- [ClusterOvnPodRestartsMedium](#clusterovnpodrestartsmedium) — medium
- [ClusterOvnPodRestartsCritical](#clusterovnpodrestartscritical) — critical

## Recording rules: cluster-ovn-recording-rules

**`cluster:ovnkube_node_unavailable:percent`**

```promql
(
  sum(kube_daemonset_status_number_unavailable{namespace="openshift-ovn-kubernetes",daemonset="ovnkube-node"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="openshift-ovn-kubernetes",daemonset="ovnkube-node"})
) * 100
```

**`cluster:ovn_cni_request_duration_p99:seconds`**

```promql
histogram_quantile(0.99,
  sum by (le) (
    rate(ovnkube_node_cni_request_duration_seconds_bucket[5m])
  )
)
```

**`cluster:ovn_resource_retry_failures:increase10m`**

```promql
sum(increase(ovnkube_resource_retry_failures_total[10m]))
```

## Grup: cluster-ovn-control-plane-alerts

### ClusterOvnControlPlaneDegraded

severity: **high** · for: `10m`
 · _OVN control plane has unavailable replicas_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_deployment_status_replicas_available{namespace="openshift-ovn-kubernetes",deployment="ovnkube-control-plane"}
<
kube_deployment_spec_replicas{namespace="openshift-ovn-kubernetes",deployment="ovnkube-control-plane"}
```

### ClusterOvnControlPlaneDown

severity: **critical** · for: `5m`
 · _OVN control plane is down_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_deployment_status_replicas_available{namespace="openshift-ovn-kubernetes",deployment="ovnkube-control-plane"} == 0
```

Eşiksiz değer sorgusu (eşik: `== 0`):

```promql
kube_deployment_status_replicas_available{namespace="openshift-ovn-kubernetes",deployment="ovnkube-control-plane"}
```

## Grup: cluster-ovn-node-alerts

### ClusterOvnkubeNodeUnavailableLow

severity: **low** · for: `10m`
 · _ovnkube-node unavailability is above 0%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ovnkube_node_unavailable:percent > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
cluster:ovnkube_node_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="openshift-ovn-kubernetes",daemonset="ovnkube-node"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="openshift-ovn-kubernetes",daemonset="ovnkube-node"})
) * 100
) > 0
```

### ClusterOvnkubeNodeUnavailableMedium

severity: **medium** · for: `10m`
 · _ovnkube-node unavailability is above 10%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ovnkube_node_unavailable:percent > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
cluster:ovnkube_node_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="openshift-ovn-kubernetes",daemonset="ovnkube-node"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="openshift-ovn-kubernetes",daemonset="ovnkube-node"})
) * 100
) > 10
```

### ClusterOvnkubeNodeUnavailableHigh

severity: **high** · for: `5m`
 · _ovnkube-node unavailability is above 25%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ovnkube_node_unavailable:percent > 25
```

Eşiksiz değer sorgusu (eşik: `> 25`):

```promql
cluster:ovnkube_node_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="openshift-ovn-kubernetes",daemonset="ovnkube-node"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="openshift-ovn-kubernetes",daemonset="ovnkube-node"})
) * 100
) > 25
```

### ClusterOvnkubeNodeUnavailableCritical

severity: **critical** · for: `5m`
 · _ovnkube-node unavailability is above 50%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ovnkube_node_unavailable:percent > 50
```

Eşiksiz değer sorgusu (eşik: `> 50`):

```promql
cluster:ovnkube_node_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="openshift-ovn-kubernetes",daemonset="ovnkube-node"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="openshift-ovn-kubernetes",daemonset="ovnkube-node"})
) * 100
) > 50
```

## Grup: cluster-ovn-cni-latency-alerts

### ClusterOvnCniRequestDurationLow

severity: **low** · for: `15m`
 · _OVN CNI p99 latency is above 2.5s_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ovn_cni_request_duration_p99:seconds > 2.5
```

Eşiksiz değer sorgusu (eşik: `> 2.5`):

```promql
cluster:ovn_cni_request_duration_p99:seconds
```

Genişletilmiş (recording rule'suz):

```promql
(
histogram_quantile(0.99,
  sum by (le) (
    rate(ovnkube_node_cni_request_duration_seconds_bucket[5m])
  )
)
) > 2.5
```

### ClusterOvnCniRequestDurationMedium

severity: **medium** · for: `15m`
 · _OVN CNI p99 latency is above 5s_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ovn_cni_request_duration_p99:seconds > 5
```

Eşiksiz değer sorgusu (eşik: `> 5`):

```promql
cluster:ovn_cni_request_duration_p99:seconds
```

Genişletilmiş (recording rule'suz):

```promql
(
histogram_quantile(0.99,
  sum by (le) (
    rate(ovnkube_node_cni_request_duration_seconds_bucket[5m])
  )
)
) > 5
```

### ClusterOvnCniRequestDurationHigh

severity: **high** · for: `10m`
 · _OVN CNI p99 latency is above 10s_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ovn_cni_request_duration_p99:seconds > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
cluster:ovn_cni_request_duration_p99:seconds
```

Genişletilmiş (recording rule'suz):

```promql
(
histogram_quantile(0.99,
  sum by (le) (
    rate(ovnkube_node_cni_request_duration_seconds_bucket[5m])
  )
)
) > 10
```

### ClusterOvnCniRequestDurationCritical

severity: **critical** · for: `5m`
 · _OVN CNI p99 latency is above 30s_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ovn_cni_request_duration_p99:seconds > 30
```

Eşiksiz değer sorgusu (eşik: `> 30`):

```promql
cluster:ovn_cni_request_duration_p99:seconds
```

Genişletilmiş (recording rule'suz):

```promql
(
histogram_quantile(0.99,
  sum by (le) (
    rate(ovnkube_node_cni_request_duration_seconds_bucket[5m])
  )
)
) > 30
```

## Grup: cluster-ovn-retry-alerts

### ClusterOvnResourceRetryFailuresHigh

severity: **high** · for: `5m`
 · _OVN resource retry failures detected_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ovn_resource_retry_failures:increase10m > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
cluster:ovn_resource_retry_failures:increase10m
```

Genişletilmiş (recording rule'suz):

```promql
(
sum(increase(ovnkube_resource_retry_failures_total[10m]))
) > 0
```

## Grup: cluster-ovn-pod-restart-alerts

### ClusterOvnPodRestartsMedium

severity: **medium** · for: `5m`
 · _OVN pod restarted more than 3 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-ovn-kubernetes"}[1h]) > 3
```

Eşiksiz değer sorgusu (eşik: `> 3`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-ovn-kubernetes"}[1h])
```

### ClusterOvnPodRestartsCritical

severity: **critical** · for: `5m`
 · _OVN pod restarted more than 10 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-ovn-kubernetes"}[1h]) > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-ovn-kubernetes"}[1h])
```
