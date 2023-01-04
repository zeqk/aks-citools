
https://github.com/prometheus-community/helm-charts
https://shailender-choudhary.medium.com/monitor-azure-kubernetes-service-aks-with-prometheus-and-grafana-8e2fe64d1314
https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml

```bash
kubectl apply -f 01-namespace.yml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm repo list

helm install prometheus prometheus-community/kube-prometheus-stack -n prometheus --set grafana.adminPassword="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"

kubectl get all -n prometheus

kubectl get secret -n prometheus prometheus-grafana -o=jsonpath='{.data.admin-password}' |base64 -d

kubectl --context aks-citools-sbx-ue port-forward -n prometheus prometheus-prometheus-kube-prometheus-prometheus-0 9090

```


```bash
kubectl apply -f 03-ingress.yml
```