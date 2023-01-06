<!-- https://github.com/grafana/helm-charts/blob/fluent-bit-2.3.2/charts/fluent-bit/values.yaml -->

https://github.com/fluent/helm-charts/blob/fluent-bit-0.21.7/charts/fluent-bit/values.yaml

```bash
helm repo add fluent https://fluent.github.io/helm-charts
helm install --dry-run --debug  fluent-bit fluent/fluent-bit --namespace monitoring -f ./values.yml > output2.yml
helm install fluent-bit fluent/fluent-bit --namespace monitoring -f ./values.yml

helm upgrade fluent-bit fluent/fluent-bit --namespace monitoring -f ./values.yml
```

`kubectl kustomize --enable-helm | kubectl apply -n monitoring -f - ` doesn't work because `Capabilities.APIVersions`