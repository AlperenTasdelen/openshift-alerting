# cluster-dynatrace-alerts — test sorguları

[← Ana sayfa](README.md) · Kaynak: [cluster-dynatrace-alerts.yaml](../new-alerts/cluster-dynatrace-alerts.yaml)

## Alertler

- [ClusterDynatraceOperatorDown](#clusterdynatraceoperatordown) — high
- [ClusterDynatraceWebhookDown](#clusterdynatracewebhookdown) — high
- [ClusterDynatraceActiveGateDegraded](#clusterdynatraceactivegatedegraded) — high
- [ClusterDynatraceOneAgentUnavailableLow](#clusterdynatraceoneagentunavailablelow) — low
- [ClusterDynatraceOneAgentUnavailableMedium](#clusterdynatraceoneagentunavailablemedium) — medium
- [ClusterDynatraceOneAgentUnavailableHigh](#clusterdynatraceoneagentunavailablehigh) — high
- [ClusterDynatraceOneAgentUnavailableCritical](#clusterdynatraceoneagentunavailablecritical) — critical
- [ClusterDynatraceOneAgentRolloutStuck](#clusterdynatraceoneagentrolloutstuck) — medium
- [ClusterDynatracePodRestartsMedium](#clusterdynatracepodrestartsmedium) — medium
- [ClusterDynatracePodRestartsCritical](#clusterdynatracepodrestartscritical) — critical

## Recording rules: cluster-dynatrace-recording-rules

**`cluster:dynatrace_oneagent_unavailable:percent`**

```promql
(
  sum(kube_daemonset_status_number_unavailable{namespace="dynatrace"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="dynatrace"})
) * 100
```

## Grup: cluster-dynatrace-operator-alerts

### ClusterDynatraceOperatorDown

severity: **high** · for: `15m`
 · _Dynatrace operator is down_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_deployment_status_replicas_available{namespace="dynatrace",deployment="dynatrace-operator"} == 0
```

Eşiksiz değer sorgusu (eşik: `== 0`):

```promql
kube_deployment_status_replicas_available{namespace="dynatrace",deployment="dynatrace-operator"}
```

### ClusterDynatraceWebhookDown

severity: **high** · for: `10m`
 · _Dynatrace webhook is down_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_deployment_status_replicas_available{namespace="dynatrace",deployment="dynatrace-webhook"} == 0
```

Eşiksiz değer sorgusu (eşik: `== 0`):

```promql
kube_deployment_status_replicas_available{namespace="dynatrace",deployment="dynatrace-webhook"}
```

## Grup: cluster-dynatrace-activegate-alerts

### ClusterDynatraceActiveGateDegraded

severity: **high** · for: `10m`
 · _Dynatrace ActiveGate has unready replicas_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_statefulset_status_replicas_ready{namespace="dynatrace"}
<
kube_statefulset_replicas{namespace="dynatrace"}
```

## Grup: cluster-dynatrace-oneagent-alerts

### ClusterDynatraceOneAgentUnavailableLow

severity: **low** · for: `10m`
 · _OneAgent unavailability is above 0%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:dynatrace_oneagent_unavailable:percent > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
cluster:dynatrace_oneagent_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="dynatrace"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="dynatrace"})
) * 100
) > 0
```

### ClusterDynatraceOneAgentUnavailableMedium

severity: **medium** · for: `10m`
 · _OneAgent unavailability is above 10%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:dynatrace_oneagent_unavailable:percent > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
cluster:dynatrace_oneagent_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="dynatrace"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="dynatrace"})
) * 100
) > 10
```

### ClusterDynatraceOneAgentUnavailableHigh

severity: **high** · for: `10m`
 · _OneAgent unavailability is above 25%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:dynatrace_oneagent_unavailable:percent > 25
```

Eşiksiz değer sorgusu (eşik: `> 25`):

```promql
cluster:dynatrace_oneagent_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="dynatrace"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="dynatrace"})
) * 100
) > 25
```

### ClusterDynatraceOneAgentUnavailableCritical

severity: **critical** · for: `5m`
 · _OneAgent unavailability is above 50%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:dynatrace_oneagent_unavailable:percent > 50
```

Eşiksiz değer sorgusu (eşik: `> 50`):

```promql
cluster:dynatrace_oneagent_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="dynatrace"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="dynatrace"})
) * 100
) > 50
```

## Grup: cluster-dynatrace-rollout-alerts

### ClusterDynatraceOneAgentRolloutStuck

severity: **medium** · for: `2h`
 · _Dynatrace OneAgent rollout is stuck_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_daemonset_status_updated_number_scheduled{namespace="dynatrace"}
<
kube_daemonset_status_desired_number_scheduled{namespace="dynatrace"}
```

## Grup: cluster-dynatrace-pod-restart-alerts

### ClusterDynatracePodRestartsMedium

severity: **medium** · for: `5m`
 · _Dynatrace pod restarted more than 3 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="dynatrace"}[1h]) > 3
```

Eşiksiz değer sorgusu (eşik: `> 3`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="dynatrace"}[1h])
```

### ClusterDynatracePodRestartsCritical

severity: **critical** · for: `5m`
 · _Dynatrace pod restarted more than 10 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="dynatrace"}[1h]) > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="dynatrace"}[1h])
```
