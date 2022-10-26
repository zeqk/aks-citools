## Config

```bash
az account set --subscription $SUBSCRIPTION_ID
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