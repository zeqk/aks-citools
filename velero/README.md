## Velero

https://velero.io/docs/v1.10.0-rc.1/basic-install/#install-and-configure-the-server-components

### Helm 

https://vmware-tanzu.github.io/helm-charts/
https://github.com/vmware-tanzu/helm-charts/blob/main/charts/velero/README.md
https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup

```
kubectl apply -f 01-namespace.yml
kubectl apply -f 02-secret-store.yml
kubectl apply -f 03-external-secret.yml

kubectl get SecretStores -n velero
kubectl get ExternalSecret -n velero

kubectl -n velero get secret backupstorage-secret -o jsonpath="{.data.primary-access-key}" | base64 -d; echo

helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm install vmware-tanzu/velero --namespace <YOUR NAMESPACE> -f values.yaml --generate-name
```