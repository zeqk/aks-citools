## Velero

https://velero.io/docs/v1.10.0-rc.1/basic-install/#install-and-configure-the-server-components

### Helm 

https://vmware-tanzu.github.io/helm-charts/
https://github.com/vmware-tanzu/helm-charts/blob/main/charts/velero/README.md
https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup
https://azure.github.io/azure-workload-identity/docs/quick-start.html
https://learn.microsoft.com/en-us/azure/aks/hybrid/backup-workload-cluster

```bash
kubectl apply -f 01-namespace.yml

helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm install vmware-tanzu/velero velero --namespace velero -f values.yml
helm list -n velero
helm uninstall --namespace velero velero

# Add the federated identity credential:
cat <<EOF > params.json
{
  "name": "kubernetes-federated-credential",
  "issuer": "${SERVICE_ACCOUNT_ISSUER}",
  "subject": "system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}",
  "description": "Kubernetes service account federated credential",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}
EOF

az ad app federated-credential create --id ${APPLICATION_OBJECT_ID} --parameters @params.json
```

## Install client

https://github.com/vmware-tanzu/velero/releases

```bash
wget https://github.com/vmware-tanzu/velero/releases/download/v1.9.3/velero-v1.9.3-linux-amd64.tar.gz -O velero-linux-amd64.tar.gz
mkdir velero-linux-amd64 && tar -xzf velero-linux-amd64.tar.gz -C velero-linux-amd64 --strip-components 1
chmod +x velero-linux-amd64/velero
sudo chown root:root velero-linux-amd64/velero
sudo mv velero-linux-amd64/velero /usr/local/bin/velero
```

## Usage

```bash
velero backup create gitlabrunner-backup --include-namespaces=gitlab-runner
velero backup describe gitlabrunner-backup
velero backup logs gitlabrunner-backup
```

## Server install with client

```bash

AZURE_ROLE="Velero"
AZURE_SUBSCRIPTION_ID="$(az account list --query "[?name == 'Sistemas - Production'].id" -o tsv)"
AZURE_NONPROD_SUBSCRIPTION_ID="$(az account list --query "[?name == 'Sistemas - Non Production'].id" -o tsv)"
AZURE_TENANT_ID="$(az account list --query "[?name == 'Sistemas - Production'].tenantId" -o tsv)"
AZURE_CLIENT_ID="$(az ad sp list --display-name "Velero" --query '[0].appId' -otsv)"
AZURE_CLIENT_SECRET="$(az ad sp credential reset --id $AZURE_CLIENT_ID --query "password"  -otsv)"
AZURE_RESOURCE_GROUP="rg-backups-iprd-ue"
AZURE_STORAGE_ACCOUNT="stbackupsiprdue"
AZURE_STORAGE_ACCOUNT_ACCESS_KEY="$(az storage account keys list --subscription $AZURE_SUBSCRIPTION_ID --resource-group $AZURE_RESOURCE_GROUP --account-name $AZURE_STORAGE_ACCOUNT --query "[?keyName == 'key1'].value" -otsv)"

az role definition list --name $AZURE_ROLE
az role definition create --role-definition '{
   "Name": "'$AZURE_ROLE'",
   "Description": "Velero related permissions to perform backups, restores and deletions",
   "Actions": [
       "Microsoft.Compute/disks/read",
       "Microsoft.Compute/disks/write",
       "Microsoft.Compute/disks/endGetAccess/action",
       "Microsoft.Compute/disks/beginGetAccess/action",
       "Microsoft.Compute/snapshots/read",
       "Microsoft.Compute/snapshots/write",
       "Microsoft.Compute/snapshots/delete",
       "Microsoft.Storage/storageAccounts/listkeys/action",
       "Microsoft.Storage/storageAccounts/regeneratekey/action"
   ],
   "AssignableScopes": ["/subscriptions/'$AZURE_SUBSCRIPTION_ID'", "/subscriptions/'$AZURE_NONPROD_SUBSCRIPTION_ID'"]
   }'

az role assignment create --assignee $AZURE_CLIENT_ID \
  --role $AZURE_ROLE \
  --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID"

az role assignment create --assignee $AZURE_CLIENT_ID \
  --role $AZURE_ROLE \
  --scope "/subscriptions/$AZURE_NONPROD_SUBSCRIPTION_ID"


# AZURE_STORAGE_ACCOUNT_ACCESS_KEY=${AZURE_STORAGE_ACCOUNT_ACCESS_KEY}

cat << EOF  > ./credentials-velero 
AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}
AZURE_TENANT_ID=${AZURE_TENANT_ID}
AZURE_CLIENT_ID=${AZURE_CLIENT_ID}
AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}
AZURE_RESOURCE_GROUP=${AZURE_RESOURCE_GROUP}
AZURE_CLOUD_NAME=AzurePublicCloud
EOF


velero install \
    --provider azure \
    --plugins velero/velero-plugin-for-microsoft-azure:v1.5.0 \
    --bucket velero \
    --secret-file ./credentials-velero \
    --use-restic \
    --backup-location-config resourceGroup=${AZURE_RESOURCE_GROUP},storageAccount=${AZURE_STORAGE_ACCOUNT},subscriptionId=${AZURE_SUBSCRIPTION_ID}

k get all -n velero
kubectl logs deployment/velero -n velero
```