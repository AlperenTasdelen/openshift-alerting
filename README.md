# OpenShift Alerting

OpenShift kümeleri için PrometheusRule tabanlı alert kuralları.

| Klasör | İçerik |
|---|---|
| [new-alerts/](new-alerts/) | Alert YAML'ları (78 alert: nvidia-gpu, ovn, logging, ingress, trident, twistlock, dynatrace) — detaylar: [new-alerts/README.md](new-alerts/README.md) |
| [test-sorgulari/](test-sorgulari/) | Her alert için Console'da (Observe → Metrics) test edilebilir PromQL sorguları — başlangıç: [test-sorgulari/README.md](test-sorgulari/README.md) |

## Hızlı başlangıç

```bash
oc apply -f new-alerts/cluster-nvidia-gpu-alerts.yaml
```

Alert durumu: Console → Observe → Alerting → Alerting rules. Anlık firing kontrolü:

```promql
ALERTS{alertstate="firing"}
```
