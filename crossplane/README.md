## Install

https://crossplane.io/docs/v1.10/getting-started/install-configure.html

```bash
kubectl apply -f 01-namespace.yml 
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane --namespace crossplane-system crossplane-stable/crossplane

helm list -n crossplane-system

kubectl get all -n crossplane-system
```

```bash
helm uninstall --namespace crossplane-system crossplane
```

```bash
az ad sp create-for-rbac --display-name "Sistemas Crossplane" --sdk-auth --role Contributor --scopes /subscriptions/dbfe8c3f-dc20-468e-85db-e92325113098 > "creds.json"
kubectl delete secret azure-creds -n crossplane-system --ignore-not-found
kubectl create secret generic azure-creds -n crossplane-system --from-file=creds=./creds.json

kubectl apply -f 02-az-provider.yml 
```

https://doc.crds.dev/github.com/crossplane/provider-azure@v0.19.0