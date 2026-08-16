# cluster-nvidia-gpu-alerts — test sorguları

[← Ana sayfa](README.md) · Kaynak: [cluster-nvidia-gpu-alerts.yaml](../new-alerts/cluster-nvidia-gpu-alerts.yaml)

## Alertler

- [ClusterNvidiaGpuOperatorDown](#clusternvidiagpuoperatordown) — high
- [ClusterNvidiaDaemonsetUnavailable](#clusternvidiadaemonsetunavailable) — high
- [ClusterGpuAllocatableBelowCapacity](#clustergpuallocatablebelowcapacity) — high
- [ClusterDcgmMetricsAbsentOnGpuCluster](#clusterdcgmmetricsabsentongpucluster) — medium
- [NodeGpuTemperatureLow](#nodegputemperaturelow) — low
- [NodeGpuTemperatureMedium](#nodegputemperaturemedium) — medium
- [NodeGpuTemperatureHigh](#nodegputemperaturehigh) — high
- [NodeGpuTemperatureCritical](#nodegputemperaturecritical) — critical
- [NodeGpuMemoryUtilizationLow](#nodegpumemoryutilizationlow) — low
- [NodeGpuMemoryUtilizationHigh](#nodegpumemoryutilizationhigh) — high
- [NodeGpuMemoryUtilizationCritical](#nodegpumemoryutilizationcritical) — critical
- [NodeGpuXidErrorCritical](#nodegpuxiderrorcritical) — critical
- [NodeGpuDoubleBitEccErrorCritical](#nodegpudoublebiteccerrorcritical) — critical
- [NodeGpuSingleBitEccErrorMedium](#nodegpusinglebiteccerrormedium) — medium

## Recording rules: cluster-nvidia-gpu-recording-rules

**`cluster:gpu_utilization:avg`**

```promql
avg(DCGM_FI_DEV_GPU_UTIL)
```

**`node:gpu_utilization:avg`**

```promql
avg by (Hostname, gpu) (DCGM_FI_DEV_GPU_UTIL)
```

**`node:gpu_memory_utilization:percent`**

```promql
(
  sum by (Hostname, gpu) (DCGM_FI_DEV_FB_USED)
  /
  (
    sum by (Hostname, gpu) (DCGM_FI_DEV_FB_USED)
    +
    sum by (Hostname, gpu) (DCGM_FI_DEV_FB_FREE)
  )
) * 100
```

**`cluster:gpu_allocatable:count`**

```promql
sum(kube_node_status_allocatable{resource="nvidia_com_gpu"})
```

**`cluster:gpu_capacity:count`**

```promql
sum(kube_node_status_capacity{resource="nvidia_com_gpu"})
```

## Grup: cluster-nvidia-operator-alerts

### ClusterNvidiaGpuOperatorDown

severity: **high** · for: `15m`
 · _NVIDIA GPU operator is down_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_deployment_status_replicas_available{namespace="nvidia-gpu-operator",deployment="gpu-operator"} == 0
```

Eşiksiz değer sorgusu (eşik: `== 0`):

```promql
kube_deployment_status_replicas_available{namespace="nvidia-gpu-operator",deployment="gpu-operator"}
```

### ClusterNvidiaDaemonsetUnavailable

severity: **high** · for: `15m`
 · _NVIDIA GPU stack DaemonSet has unavailable pods_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
kube_daemonset_status_number_unavailable{namespace="nvidia-gpu-operator"} > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
kube_daemonset_status_number_unavailable{namespace="nvidia-gpu-operator"}
```

## Grup: cluster-nvidia-gpu-capacity-alerts

### ClusterGpuAllocatableBelowCapacity

severity: **high** · for: `15m`
 · _Allocatable GPUs below hardware capacity_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:gpu_allocatable:count < cluster:gpu_capacity:count
```

Genişletilmiş (recording rule'suz):

```promql
(
sum(kube_node_status_allocatable{resource="nvidia_com_gpu"})
) < (
sum(kube_node_status_capacity{resource="nvidia_com_gpu"})
)
```

### ClusterDcgmMetricsAbsentOnGpuCluster

severity: **medium** · for: `30m`
 · _DCGM metrics missing on a GPU cluster_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
(cluster:gpu_capacity:count > 0)
and
absent(DCGM_FI_DEV_GPU_UTIL)
```

Genişletilmiş (recording rule'suz):

```promql
((
sum(kube_node_status_capacity{resource="nvidia_com_gpu"})
) > 0)
and
absent(DCGM_FI_DEV_GPU_UTIL)
```

## Grup: node-nvidia-gpu-temperature-alerts

### NodeGpuTemperatureLow

severity: **low** · for: `10m`
 · _GPU temperature is above 78C_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
DCGM_FI_DEV_GPU_TEMP > 78
```

Eşiksiz değer sorgusu (eşik: `> 78`):

```promql
DCGM_FI_DEV_GPU_TEMP
```

### NodeGpuTemperatureMedium

severity: **medium** · for: `10m`
 · _GPU temperature is above 83C_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
DCGM_FI_DEV_GPU_TEMP > 83
```

Eşiksiz değer sorgusu (eşik: `> 83`):

```promql
DCGM_FI_DEV_GPU_TEMP
```

### NodeGpuTemperatureHigh

severity: **high** · for: `5m`
 · _GPU temperature is above 88C_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
DCGM_FI_DEV_GPU_TEMP > 88
```

Eşiksiz değer sorgusu (eşik: `> 88`):

```promql
DCGM_FI_DEV_GPU_TEMP
```

### NodeGpuTemperatureCritical

severity: **critical** · for: `2m`
 · _GPU temperature is above 92C_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
DCGM_FI_DEV_GPU_TEMP > 92
```

Eşiksiz değer sorgusu (eşik: `> 92`):

```promql
DCGM_FI_DEV_GPU_TEMP
```

## Grup: node-nvidia-gpu-memory-alerts

### NodeGpuMemoryUtilizationLow

severity: **low** · for: `15m`
 · _GPU memory utilization is above 80%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
node:gpu_memory_utilization:percent > 80
```

Eşiksiz değer sorgusu (eşik: `> 80`):

```promql
node:gpu_memory_utilization:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum by (Hostname, gpu) (DCGM_FI_DEV_FB_USED)
  /
  (
    sum by (Hostname, gpu) (DCGM_FI_DEV_FB_USED)
    +
    sum by (Hostname, gpu) (DCGM_FI_DEV_FB_FREE)
  )
) * 100
) > 80
```

### NodeGpuMemoryUtilizationHigh

severity: **high** · for: `10m`
 · _GPU memory utilization is above 90%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
node:gpu_memory_utilization:percent > 90
```

Eşiksiz değer sorgusu (eşik: `> 90`):

```promql
node:gpu_memory_utilization:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum by (Hostname, gpu) (DCGM_FI_DEV_FB_USED)
  /
  (
    sum by (Hostname, gpu) (DCGM_FI_DEV_FB_USED)
    +
    sum by (Hostname, gpu) (DCGM_FI_DEV_FB_FREE)
  )
) * 100
) > 90
```

### NodeGpuMemoryUtilizationCritical

severity: **critical** · for: `5m`
 · _GPU memory utilization is above 97%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
node:gpu_memory_utilization:percent > 97
```

Eşiksiz değer sorgusu (eşik: `> 97`):

```promql
node:gpu_memory_utilization:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum by (Hostname, gpu) (DCGM_FI_DEV_FB_USED)
  /
  (
    sum by (Hostname, gpu) (DCGM_FI_DEV_FB_USED)
    +
    sum by (Hostname, gpu) (DCGM_FI_DEV_FB_FREE)
  )
) * 100
) > 97
```

## Grup: node-nvidia-gpu-error-alerts

### NodeGpuXidErrorCritical

severity: **critical** · for: `1m`
 · _GPU reported an XID error_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
DCGM_FI_DEV_XID_ERRORS > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
DCGM_FI_DEV_XID_ERRORS
```

### NodeGpuDoubleBitEccErrorCritical

severity: **critical** · for: `1m`
 · _GPU double-bit ECC errors detected_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(DCGM_FI_DEV_ECC_DBE_VOL_TOTAL[5m]) > 0
```

Eşiksiz değer sorgusu (eşik: `> 0`):

```promql
increase(DCGM_FI_DEV_ECC_DBE_VOL_TOTAL[5m])
```

### NodeGpuSingleBitEccErrorMedium

severity: **medium** · for: `5m`
 · _GPU single-bit ECC error rate is elevated_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(DCGM_FI_DEV_ECC_SBE_VOL_TOTAL[1h]) > 100
```

Eşiksiz değer sorgusu (eşik: `> 100`):

```promql
increase(DCGM_FI_DEV_ECC_SBE_VOL_TOTAL[1h])
```
