# External Secrets Operator

https://external-secrets.io/v0.6.1/guides/getting-started/

```bash
helm repo add external-secrets https://charts.external-secrets.io

helm install external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true
```