https://github.com/prometheus-community/helm-charts/blob/kube-prometheus-stack-43.1.0/charts/kube-prometheus-stack/values.yaml

kubectl --context  aks-itools-iprd-ue port-forward -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0 9091

kubectl --context aks-itools-iprd-ue  -n monitoring get all

## Thanos Sidecar

https://techcommunity.microsoft.com/t5/apps-on-azure-blog/store-prometheus-metrics-with-thanos-azure-storage-and-azure/ba-p/3067849

https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#thanosspec

https://www.youtube.com/watch?v=NfP_8lsHXkU&t=194s