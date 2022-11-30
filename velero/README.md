# Velero + Azure AKS + Azure Blob Storage + External Secrets Operator

- K8S: AKS
- Velero Storage: Azure Blob Storage
- Storage Access: Service Principal (ClientId + ClientSecret)
- Secrets: Secrets (ClientId + ClientSecret) stored in Azure Key Vault
- Secrets Access: External Secrets Operator with Azure Workload Identity

https://velero.io/docs/v1.10.0-rc.1/basic-install/#install-and-configure-the-server-components

## Helm 

https://vmware-tanzu.github.io/helm-charts/
https://github.com/vmware-tanzu/helm-charts/blob/main/charts/velero/README.md
https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup
https://azure.github.io/azure-workload-identity/docs/quick-start.html
https://learn.microsoft.com/en-us/azure/aks/hybrid/backup-workload-cluster

### 0. Load variables

```bash

AZURE_VELERO_ROLE="Velero" && echo "AZURE_VELERO_ROLE $AZURE_VELERO_ROLE" && \
APP_NAME="Velero" && echo "APP_NAME $APP_NAME" && \

AZURE_TENANT_ID=`az account list --query "[?name == 'Sistemas - Production'].tenantId" -o tsv` && echo "AZURE_TENANT_ID $AZURE_TENANT_ID" && \


# Get subscription where is the Blob Storage
BLOBSTORAGE_AZURE_SUBSCRIPTION_ID=`az account list --query "[?name == 'Sistemas - Production'].id" -o tsv` && echo "BLOBSTORAGE_AZURE_SUBSCRIPTION_ID $BLOBSTORAGE_AZURE_SUBSCRIPTION_ID" && \
BLOBSTORAGE_AZURE_RESOURCE_GROUP="rg-backups-iprd-ue" && echo "BLOBSTORAGE_AZURE_RESOURCE_GROUP $BLOBSTORAGE_AZURE_RESOURCE_GROUP" && \
AZURE_STORAGE_ACCOUNT="stbackupsiprdue" && echo "AZURE_STORAGE_ACCOUNT $AZURE_STORAGE_ACCOUNT" && \
AZURE_STORAGE_ACCOUNT_ACCESS_KEY=`az storage account keys list --subscription $BLOBSTORAGE_AZURE_SUBSCRIPTION_ID --resource-group $BLOBSTORAGE_AZURE_RESOURCE_GROUP --account-name $AZURE_STORAGE_ACCOUNT --query "[?keyName == 'key1'].value" -otsv` && echo "AZURE_STORAGE_ACCOUNT_ACCESS_KEY $AZURE_STORAGE_ACCOUNT_ACCESS_KEY" && \

# Get subscription where is the AKS
AKS_AZURE_SUBSCRIPTION_ID=`az account list --query "[?name == 'Sistemas - Non Production'].id" -o tsv` && echo "AKS_AZURE_SUBSCRIPTION_ID $AKS_AZURE_SUBSCRIPTION_ID" && \
AKS_AZURE_RESOURCE_GROUP="rg-sandbox" && echo "AKS_AZURE_RESOURCE_GROUP $AKS_AZURE_RESOURCE_GROUP" && \
AKS_NAME="aks-citools-sbx-ue" && echo "AKS_NAME $AKS_NAME" && \
AKS_SERVICE_ACCOUNT_ISSUER=`az aks show --resource-group $AKS_AZURE_RESOURCE_GROUP --name $AKS_NAME --query "oidcIssuerProfile.issuerUrl" -otsv` && \

K8_VELERO_SERVICE_ACCOUNT_NAMESPACE="velero" && echo "K8_VELERO_SERVICE_ACCOUNT_NAMESPACE $K8_VELERO_SERVICE_ACCOUNT_NAMESPACE" && \
K8_VELERO_SERVICE_ACCOUNT_NAME="velero" && echo "K8_VELERO_SERVICE_ACCOUNT_NAME $K8_VELERO_SERVICE_ACCOUNT_NAME" && \

KV_NAME="kv-backupstorage-iprd-ue" && echo "KV_NAME $KV_NAME" && \
KV_SECRET_NAME="velero-credentials" && echo "KV_SECRET_NAME $KV_SECRET_NAME"
```

### 1. Create Velero Service Principal

```bash
# Get existent SP id
APP_CLIENT_ID=`az ad sp list --display-name "$APP_NAME" --query '[0].appId' -otsv` && echo "APP_CLIENT_ID $APP_CLIENT_ID"
# Or create SP and Get existent SP id
APP_CLIENT_ID=`az ad sp create-for-rbac --name "$APP_NAME" --query 'appId' -o tsv` && echo "APP_CLIENT_ID $APP_CLIENT_ID"

APP_OBJECT_ID=`az ad app show --id ${APP_CLIENT_ID} --query id -otsv`

# Reset (Warning!) SP secret and get 
APP_CLIENT_SECRET=`az ad sp credential reset --id $APP_NAME --query "password"  -otsv`

# Create Velero Role
az role definition create --role-definition '{
   "Name": "'$AZURE_VELERO_ROLE'",
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
   "AssignableScopes": ["/subscriptions/'$AKS_AZURE_SUBSCRIPTION_ID'", "/subscriptions/'$BLOBSTORAGE_AZURE_SUBSCRIPTION_ID'"]
   }'

az role assignment create --assignee $APP_CLIENT_ID \
  --role $AZURE_VELERO_ROLE \
  --scope "/subscriptions/$AKS_AZURE_SUBSCRIPTION_ID"

az role assignment create --assignee $APP_CLIENT_ID \
  --role $AZURE_VELERO_ROLE \
  --scope "/subscriptions/$BLOBSTORAGE_AZURE_SUBSCRIPTION_ID"
```

### 2. Create secret

```bash

# Create key vault secret
cat << EOF  > ./credentials-velero 
AZURE_CLOUD_NAME=AzurePublicCloud
AZURE_TENANT_ID=${AZURE_TENANT_ID}
AZURE_SUBSCRIPTION_ID=${BLOBSTORAGE_AZURE_SUBSCRIPTION_ID}
AZURE_RESOURCE_GROUP=${BLOBSTORAGE_AZURE_RESOURCE_GROUP}
AZURE_CLIENT_ID=${APP_CLIENT_ID}
AZURE_CLIENT_SECRET=${APP_CLIENT_SECRET}
EOF

az keyvault secret set --name $KV_SECRET_NAME --vault-name $KV_NAME --file credentials-velero
```

### 3. Create Workload Identity for External Secret Operator

```bash
AKS_SERVICE_ACCOUNT_ISSUER=`az aks show --resource-group rg-sandbox --name aks-citools-sbx-ue --query "oidcIssuerProfile.issuerUrl" -otsv`

# Add the federated identity credential:
cat <<EOF > params.json
{
  "name": "kubernetes-federated-credential",
  "issuer": "${AKS_SERVICE_ACCOUNT_ISSUER}",
  "subject": "system:serviceaccount:${K8_VELERO_SERVICE_ACCOUNT_NAMESPACE}:${K8_VELERO_SERVICE_ACCOUNT_NAME}",
  "description": "Kubernetes service account federated credential",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}
EOF

az ad app federated-credential create --id ${APP_OBJECT_ID} --parameters @params.json
```

### 3. Install Velero

```bash
kubectl apply -f 01-namespace.yml

helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts

helm install velero \
    --namespace velero \
    --set-json "configuration.backupStorageLocation.config={\"subscriptionId\":\"$BLOBSTORAGE_AZURE_SUBSCRIPTION_ID\",\"resourceGroup\":\"$BLOBSTORAGE_AZURE_RESOURCE_GROUP\",\"storageAccount\":\"$AZURE_STORAGE_ACCOUNT\"}" \
    --set-json "serviceAccount.server.annotations={\"azure.workload.identity/tenant-id\":\"$AZURE_TENANT_ID\",\"azure.workload.identity/client-id\":\"$APP_CLIENT_ID\"}" \
    -f values.yml \
    vmware-tanzu/velero

helm upgrade velero \
    --namespace velero \
    -f values.yml \
    vmware-tanzu/velero

# Verify
helm list -n velero
kubectl get all -n velero 
kubectl get deployment/velero -n velero
kubectl logs deployment/velero -n velero
kubectl get secrets backupstorage-secret -n velero -o jsonpath="{.data.cloud}" | base64 -d 

# Uninstall
kubectl delete -f 01-namespace.yml

helm uninstall --namespace velero velero

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

AZURE_ROLE="Velero" && \
AZURE_SUBSCRIPTION_ID="$(az account list --query "[?name == 'Sistemas - Production'].id" -o tsv)" && \
AZURE_NONPROD_SUBSCRIPTION_ID="$(az account list --query "[?name == 'Sistemas - Non Production'].id" -o tsv)" && \
AZURE_TENANT_ID="$(az account list --query "[?name == 'Sistemas - Production'].tenantId" -o tsv)" && \
AZURE_CLIENT_ID="$(az ad sp list --display-name "Velero" --query '[0].appId' -otsv)" && \
AZURE_RESOURCE_GROUP="rg-backups-iprd-ue" && \
AZURE_STORAGE_ACCOUNT="stbackupsiprdue" && \
AZURE_STORAGE_ACCOUNT_ACCESS_KEY="$(az storage account keys list --subscription $AZURE_SUBSCRIPTION_ID --resource-group $AZURE_RESOURCE_GROUP --account-name $AZURE_STORAGE_ACCOUNT --query "[?keyName == 'key1'].value" -otsv)"

AZURE_CLIENT_SECRET="$(az ad sp credential reset --id $AZURE_CLIENT_ID --query "password"  -otsv)"

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
    --dry-run -o yaml \
    --backup-location-config resourceGroup=${AZURE_RESOURCE_GROUP},storageAccount=${AZURE_STORAGE_ACCOUNT},subscriptionId=${AZURE_SUBSCRIPTION_ID}

k get all -n velero
kubectl logs deployment/velero -n velero

kubectl -n velero get secret cloud-credentials -o jsonpath="{.data.cloud}" | base64 -d; echo
```