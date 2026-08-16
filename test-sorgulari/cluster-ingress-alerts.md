# cluster-ingress-alerts — test sorguları

[← Ana sayfa](README.md) · Kaynak: [cluster-ingress-alerts.yaml](../new-alerts/cluster-ingress-alerts.yaml)

## Alertler

- [ClusterIngressRouterAvailabilityLow](#clusteringressrouteravailabilitylow) — low
- [ClusterIngressRouterAvailabilityHigh](#clusteringressrouteravailabilityhigh) — high
- [ClusterIngressRouterDown](#clusteringressrouterdown) — critical
- [ClusterIngressHAProxyReloadFailHigh](#clusteringresshaproxyreloadfailhigh) — high
- [ClusterIngressHAProxyReloadFailCritical](#clusteringresshaproxyreloadfailcritical) — critical
- [NamespaceIngressBackendDown](#namespaceingressbackenddown) — medium
- [ClusterIngressRouterRestartsMedium](#clusteringressrouterrestartsmedium) — medium
- [ClusterIngressRouterRestartsCritical](#clusteringressrouterrestartscritical) — critical

## Recording rules: cluster-ingress-recording-rules

**`cluster:ingress_router_available:percent`**

```promql
(
  sum(kube_deployment_status_replicas_available{namespace="openshift-ingress",deployment=~"router-.*"})
  /
  sum(kube_deployment_spec_replicas{namespace="openshift-ingress",deployment=~"router-.*"})
) * 100
```

## Grup: cluster-ingress-router-availability-alerts

### ClusterIngressRouterAvailabilityLow

severity: **low** · for: `10m`
 · _Ingress router availability is below 100%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ingress_router_available:percent < 100
```

Eşiksiz değer sorgusu (eşik: `< 100`):

```promql
cluster:ingress_router_available:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_deployment_status_replicas_available{namespace="openshift-ingress",deployment=~"router-.*"})
  /
  sum(kube_deployment_spec_replicas{namespace="openshift-ingress",deployment=~"router-.*"})
) * 100
) < 100
```

### ClusterIngressRouterAvailabilityHigh

severity: **high** · for: `10m`
 · _Ingress router availability is below 75%_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
cluster:ingress_router_available:percent < 75
```

Eşiksiz değer sorgusu (eşik: `< 75`):

```promql
cluster:ingress_router_available:percent
```

Genişletilmiş (recording rule'suz):

```promql
(
(
  sum(kube_deployment_status_replicas_available{namespace="openshift-ingress",deployment=~"router-.*"})
  /
  sum(kube_deployment_spec_replicas{namespace="openshift-ingress",deployment=~"router-.*"})
) * 100
) < 75
```

### ClusterIngressRouterDown

severity: **critical** · for: `3m`
 · _All ingress router replicas are down_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
sum(kube_deployment_status_replicas_available{namespace="openshift-ingress",deployment=~"router-.*"}) == 0
```

Eşiksiz değer sorgusu (eşik: `== 0`):

```promql
sum(kube_deployment_status_replicas_available{namespace="openshift-ingress",deployment=~"router-.*"})
```

## Grup: cluster-ingress-reload-alerts

### ClusterIngressHAProxyReloadFailHigh

severity: **high** · for: `5m`
 · _HAProxy reload failing on a router pod_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
template_router_reload_failure == 1
```

Eşiksiz değer sorgusu (eşik: `== 1`):

```promql
template_router_reload_failure
```

### ClusterIngressHAProxyReloadFailCritical

severity: **critical** · for: `30m`
 · _HAProxy reload failing for more than 30 minutes_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
template_router_reload_failure == 1
```

Eşiksiz değer sorgusu (eşik: `== 1`):

```promql
template_router_reload_failure
```

## Grup: namespace-ingress-backend-alerts

### NamespaceIngressBackendDown

severity: **medium** · for: `10m`
 · _Route backend has no healthy endpoints_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
max by (exported_namespace, route) (haproxy_backend_up) == 0
```

Eşiksiz değer sorgusu (eşik: `== 0`):

```promql
max by (exported_namespace, route) (haproxy_backend_up)
```

## Grup: cluster-ingress-pod-restart-alerts

### ClusterIngressRouterRestartsMedium

severity: **medium** · for: `5m`
 · _Ingress router pod restarted more than 3 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-ingress"}[1h]) > 3
```

Eşiksiz değer sorgusu (eşik: `> 3`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-ingress"}[1h])
```

### ClusterIngressRouterRestartsCritical

severity: **critical** · for: `5m`
 · _Ingress router pod restarted more than 10 times in 1 hour_

Alarm ifadesi (boş dönmüyorsa koşul sağlanıyor):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-ingress"}[1h]) > 10
```

Eşiksiz değer sorgusu (eşik: `> 10`):

```promql
increase(kube_pod_container_status_restarts_total{namespace="openshift-ingress"}[1h])
```
