

```bash
APPLICATION_NAME="Velero"
SERVICE_ACCOUNT_NAME="velero"
SERVICE_ACCOUNT_NAMESPACE="velero"

TENANT_ID="$(az account list --query "[?name == 'Sistemas - Production'].tenantId" -o tsv)"

# create an AAD application
az ad sp create-for-rbac --name "${APPLICATION_NAME}"

APPLICATION_CLIENT_ID="$(az ad sp list --display-name "${APPLICATION_NAME}" --query '[0].appId' -otsv)"


cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${APPLICATION_CLIENT_ID}
    azure.workload.identity/tenant-id: ${TENANT_ID}
  labels:
    azure.workload.identity/use: "true"
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
EOF

# Output the OIDC issuer URL
SERVICE_ACCOUNT_ISSUER="$(az aks show --resource-group rg-sandbox --name aks-citools-sbx-ue --query "oidcIssuerProfile.issuerUrl" -otsv)"

# Get the object ID of the AAD application
APPLICATION_OBJECT_ID="$(az ad app show --id ${APPLICATION_CLIENT_ID} --query id -otsv)"

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