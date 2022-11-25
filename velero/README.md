## Velero

https://velero.io/docs/v1.10.0-rc.1/basic-install/#install-and-configure-the-server-components

### Helm 

https://vmware-tanzu.github.io/helm-charts/
https://github.com/vmware-tanzu/helm-charts/blob/main/charts/velero/README.md
https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup

```bash

helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm install vmware-tanzu/velero --namespace <YOUR NAMESPACE> -f values.yaml --generate-name
```