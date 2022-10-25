## Config

```bash
az account set --subscription dbfe8c3f-dc20-468e-85db-e92325113098 
az aks get-credentials --resource-group rg-sandbox --name aks-citools-sbx-ue
```

```bash

```

## Stop Cluster

./stop-aks-if-running.sh rg-sandbox aks-citools-sbx-ue

```bash
az aks show \
	--resource-group "rg-sandbox" \
	--name "aks-citools-sbx-ue" \
	--query "powerState.code" -o tsv
```

```bash
az aks start \
	--resource-group "rg-sandbox" \
	--name "aks-citools-sbx-ue" --no-wait
```

```bash
kubectl config set-context --current --namespace=helloworld
kubectl config view --minify | grep namespace:
```