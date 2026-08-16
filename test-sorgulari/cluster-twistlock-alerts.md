# cluster-twistlock-alerts — test sorguları

[← Ana sayfa](README.md) · Kaynak: [cluster-twistlock-alerts.yaml](../new-alerts/cluster-twistlock-alerts.yaml)

## Alertler

- [ClusterTwistlockDefenderUnavailableLow](#clustertwistlockdefenderunavailablelow) — low
- [ClusterTwistlockDefenderUnavailableMedium](#clustertwistlockdefenderunavailablemedium) — medium
- [ClusterTwistlockDefenderUnavailableHigh](#clustertwistlockdefenderunavailablehigh) — high
- [ClusterTwistlockDefenderUnavailableCritical](#clustertwistlockdefenderunavailablecritical) — critical
- [ClusterTwistlockDefenderAbsent](#clustertwistlockdefenderabsent) — high
- [ClusterTwistlockPodRestartsMedium](#clustertwistlockpodrestartsmedium) — medium
- [ClusterTwistlockPodRestartsCritical](#clustertwistlockpodrestartscritical) — critical

## Recording rules: cluster-twistlock-recording-rules

**`cluster:twistlock_defender_unavailable:percent`**

```promql
(
  sum(kube_daemonset_status_number_unavailable{namespace="twistlock"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="twistlock"})
) * 100
```

## Grup: cluster-twistlock-defender-alerts

### ClusterTwistlockDefenderUnavailableLow

severity: **low** · for: `10m`
 · _Twistlock Defender unavailability is above 0%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:twistlock_defender_unavailable:percent > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
cluster:twistlock_defender_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="twistlock"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="twistlock"})
) * 100
) > 0
```

### ClusterTwistlockDefenderUnavailableMedium

severity: **medium** · for: `10m`
 · _Twistlock Defender unavailability is above 10%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:twistlock_defender_unavailable:percent > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
cluster:twistlock_defender_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="twistlock"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="twistlock"})
) * 100
) > 10
```

### ClusterTwistlockDefenderUnavailableHigh

severity: **high** · for: `10m`
 · _Twistlock Defender unavailability is above 25%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:twistlock_defender_unavailable:percent > 25
```

Eşiksiz değer sorgusu (eşik: `> 25`):

```promql
cluster:twistlock_defender_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="twistlock"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="twistlock"})
) * 100
) > 25
```

### ClusterTwistlockDefenderUnavailableCritical

severity: **critical** · for: `5m`
 · _Twistlock Defender unavailability is above 50%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:twistlock_defender_unavailable:percent > 50
```

Eşiksiz değer sorgusu (eşik: `> 50`):

```promql
cluster:twistlock_defender_unavailable:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_daemonset_status_number_unavailable{namespace="twistlock"})
  /
  sum(kube_daemonset_status_desired_number_scheduled{namespace="twistlock"})
) * 100
) > 50
```

### ClusterTwistlockDefenderAbsent

severity: **high** · for: `15m`
 · _Twistlock Defender DaemonSet not found_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
absent(kube_daemonset_status_desired_number_scheduled{namespace="twistlock"})
```

## Grup: cluster-twistlock-pod-restart-alerts

### ClusterTwistlockPodRestartsMedium

severity: **medium** · for: `5m`
 · _Twistlock pod restarted more than 3 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="twistlock"}[1h]) > 3
```

Eşiksiz değer sorgusu (eşik: `> 3`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="twistlock"}[1h])
```

### ClusterTwistlockPodRestartsCritical

severity: **critical** · for: `5m`
 · _Twistlock pod restarted more than 10 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="twistlock"}[1h]) > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="twistlock"}[1h])
```
