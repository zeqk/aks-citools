https://bitnami.com/stack/redis/helm

https://github.com/bitnami/charts/blob/main/bitnami/redis/values.yaml

```
kubectl apply -f 01-namespace.yml
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-redis bitnami/redis -n redis -f ./values.yml 
helm uninstall my-redis -n redis

helm template my-redis bitnami/redis -n redis -f ./values.yml 
```