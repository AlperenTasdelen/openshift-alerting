# cluster-logging-alerts — test sorguları

[← Ana sayfa](README.md) · Kaynak: [cluster-logging-alerts.yaml](../new-alerts/cluster-logging-alerts.yaml)

## Alertler

- [ClusterLoggingOperatorDown](#clusterloggingoperatordown) — critical
- [ClusterLoggingCollectorUnavailableLow](#clusterloggingcollectorunavailablelow) — low
- [ClusterLoggingCollectorUnavailableMedium](#clusterloggingcollectorunavailablemedium) — medium
- [ClusterLoggingCollectorUnavailableHigh](#clusterloggingcollectorunavailablehigh) — high
- [ClusterLoggingCollectorUnavailableCritical](#clusterloggingcollectorunavailablecritical) — critical
- [ClusterLoggingVectorComponentErrorsLow](#clusterloggingvectorcomponenterrorslow) — low
- [ClusterLoggingVectorComponentErrorsMedium](#clusterloggingvectorcomponenterrorsmedium) — medium
- [ClusterLoggingVectorComponentErrorsHigh](#clusterloggingvectorcomponenterrorshigh) — high
- [ClusterLoggingVectorComponentErrorsCritical](#clusterloggingvectorcomponenterrorscritical) — critical
- [ClusterLoggingSinkErrorsHigh](#clusterloggingsinkerrorshigh) — high
- [ClusterLoggingForwardingStalled](#clusterloggingforwardingstalled) — critical
- [ClusterLoggingBufferDiscardedEventsHigh](#clusterloggingbufferdiscardedeventshigh) — high
- [ClusterLoggingBufferDiscardedEventsCritical](#clusterloggingbufferdiscardedeventscritical) — critical
- [ClusterLoggingPodRestartsMedium](#clusterloggingpodrestartsmedium) — medium
- [ClusterLoggingPodRestartsCritical](#clusterloggingpodrestartscritical) — critical

## Recording rules: cluster-logging-recording-rules

**`cluster:logging_collector_unavailable:percent`**

```promql
(
  sum(kube_daemonset_status_number_unavailable{namespace="openshift-logging"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="openshift-logging"})
) * 100
```

**`cluster:vector_component_errors:rate5m`**

```promql
sum(rate(vector_component_errors_total{namespace="openshift-logging"}[5m]))
```

**`cluster:vector_sink_errors:rate5m`**

```promql
sum(rate(vector_component_errors_total{namespace="openshift-logging",component_kind="sink"}[5m]))
```

**`cluster:vector_received_events:rate5m`**

```promql
sum(rate(vector_component_received_events_total{namespace="openshift-logging"}[5m]))
```

**`cluster:vector_sent_events:rate5m`**

```promql
sum(rate(vector_component_sent_events_total{namespace="openshift-logging",component_kind="sink"}[5m]))
```

**`cluster:vector_buffer_discarded_events:rate5m`**

```promql
sum(rate(vector_buffer_discarded_events_total{namespace="openshift-logging"}[5m]))
```

## Grup: cluster-logging-operator-alerts

### ClusterLoggingOperatorDown

severity: **critical** · for: `10m`
 · _Cluster Logging Operator is down_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_deployment_status_replicas_available{namespace="openshift-logging",deployment="cluster-logging-operator"} == 0
```

Eşiksiz değer sorgusu (eşik: `== 0`):

```promql
kube_deployment_status_replicas_available{namespace="openshift-logging",deployment="cluster-logging-operator"}
```

## Grup: cluster-logging-collector-availability-alerts

### ClusterLoggingCollectorUnavailableLow

severity: **low** · for: `10m`
 · _Logging collector unavailability is above 0%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:logging_collector_unavailable:percent > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
cluster:logging_collector_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="openshift-logging"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="openshift-logging"})
) * 100
) > 0
```

### ClusterLoggingCollectorUnavailableMedium

severity: **medium** · for: `10m`
 · _Logging collector unavailability is above 10%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:logging_collector_unavailable:percent > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
cluster:logging_collector_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="openshift-logging"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="openshift-logging"})
) * 100
) > 10
```

### ClusterLoggingCollectorUnavailableHigh

severity: **high** · for: `10m`
 · _Logging collector unavailability is above 25%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:logging_collector_unavailable:percent > 25
```

Eşiksiz değer sorgusu (eşik: `> 25`):

```promql
cluster:logging_collector_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="openshift-logging"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="openshift-logging"})
) * 100
) > 25
```

### ClusterLoggingCollectorUnavailableCritical

severity: **critical** · for: `5m`
 · _Logging collector unavailability is above 50%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:logging_collector_unavailable:percent > 50
```

Eşiksiz değer sorgusu (eşik: `> 50`):

```promql
cluster:logging_collector_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="openshift-logging"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="openshift-logging"})
) * 100
) > 50
```

## Grup: cluster-logging-collector-error-alerts

### ClusterLoggingVectorComponentErrorsLow

severity: **low** · for: `15m`
 · _Vector component error rate is above 0.1 errors/sec_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:vector_component_errors:rate5m > 0.1
```

Eşiksiz değer sorgusu (eşik: `> 0.1`):

```promql
cluster:vector_component_errors:rate5m
```

Genişletilmiş (recording rule'suz):

```promql
(
sum(rate(vector_component_errors_total{namespace="openshift-logging"}[5m]))
) > 0.1
```

### ClusterLoggingVectorComponentErrorsMedium

severity: **medium** · for: `15m`
 · _Vector component error rate is above 1 errors/sec_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:vector_component_errors:rate5m > 1
```

Eşiksiz değer sorgusu (eşik: `> 1`):

```promql
cluster:vector_component_errors:rate5m
```

Genişletilmiş (recording rule'suz):

```promql
(
sum(rate(vector_component_errors_total{namespace="openshift-logging"}[5m]))
) > 1
```

### ClusterLoggingVectorComponentErrorsHigh

severity: **high** · for: `10m`
 · _Vector component error rate is above 5 errors/sec_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:vector_component_errors:rate5m > 5
```

Eşiksiz değer sorgusu (eşik: `> 5`):

```promql
cluster:vector_component_errors:rate5m
```

Genişletilmiş (recording rule'suz):

```promql
(
sum(rate(vector_component_errors_total{namespace="openshift-logging"}[5m]))
) > 5
```

### ClusterLoggingVectorComponentErrorsCritical

severity: **critical** · for: `5m`
 · _Vector component error rate is above 20 errors/sec_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:vector_component_errors:rate5m > 20
```

Eşiksiz değer sorgusu (eşik: `> 20`):

```promql
cluster:vector_component_errors:rate5m
```

Genişletilmiş (recording rule'suz):

```promql
(
sum(rate(vector_component_errors_total{namespace="openshift-logging"}[5m]))
) > 20
```

## Grup: cluster-logging-forwarding-alerts

### ClusterLoggingSinkErrorsHigh

severity: **high** · for: `10m`
 · _Log forwarding output errors are above 0.1 errors/sec_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:vector_sink_errors:rate5m > 0.1
```

Eşiksiz değer sorgusu (eşik: `> 0.1`):

```promql
cluster:vector_sink_errors:rate5m
```

Genişletilmiş (recording rule'suz):

```promql
(
sum(rate(vector_component_errors_total{namespace="openshift-logging",component_kind="sink"}[5m]))
) > 0.1
```

### ClusterLoggingForwardingStalled

severity: **critical** · for: `10m`
 · _Log forwarding to outputs has stalled_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:vector_sent_events:rate5m == 0
and
cluster:vector_received_events:rate5m > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
cluster:vector_sent_events:rate5m == 0
and
cluster:vector_received_events:rate5m
```

Genişletilmiş (recording rule'suz):

```promql
(
sum(rate(vector_component_sent_events_total{namespace="openshift-logging",component_kind="sink"}[5m]))
) == 0
and
(
sum(rate(vector_component_received_events_total{namespace="openshift-logging"}[5m]))
) > 0
```

### ClusterLoggingBufferDiscardedEventsHigh

severity: **high** · for: `10m`
 · _Log events are being discarded from collector buffers_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:vector_buffer_discarded_events:rate5m > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
cluster:vector_buffer_discarded_events:rate5m
```

Genişletilmiş (recording rule'suz):

```promql
(
sum(rate(vector_buffer_discarded_events_total{namespace="openshift-logging"}[5m]))
) > 0
```

### ClusterLoggingBufferDiscardedEventsCritical

severity: **critical** · for: `5m`
 · _Log events are being discarded at a high rate (above 100 events/sec)_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:vector_buffer_discarded_events:rate5m > 100
```

Eşiksiz değer sorgusu (eşik: `> 100`):

```promql
cluster:vector_buffer_discarded_events:rate5m
```

Genişletilmiş (recording rule'suz):

```promql
(
sum(rate(vector_buffer_discarded_events_total{namespace="openshift-logging"}[5m]))
) > 100
```

## Grup: cluster-logging-pod-restart-alerts

### ClusterLoggingPodRestartsMedium

severity: **medium** · for: `5m`
 · _Logging pod restarted more than 3 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-logging"}[1h]) > 3
```

Eşiksiz değer sorgusu (eşik: `> 3`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-logging"}[1h])
```

### ClusterLoggingPodRestartsCritical

severity: **critical** · for: `5m`
 · _Logging pod restarted more than 10 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-logging"}[1h]) > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-logging"}[1h])
```
