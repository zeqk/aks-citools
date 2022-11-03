This project is to test the use of kubernetes in an AKS (Azure Kubernetes Service)
## Config

Set kube.config

```bash
az account set --subscription $SUBSCRIPTION_ID
az aks get-credentials --resource-group rg-sandbox --name aks-citools-sbx-ue
```

Set context

```bash
kubectl config set-context --current --namespace=helloworld
kubectl config view --minify | grep namespace:
```

## Cluster Management

Stop

`./stop-aks-if-running.sh rg-sandbox aks-citools-sbx-ue`

```bash
az aks stop \
		--resource-group "rg-sandbox" \
		--name "aks-citools-sbx-ue" \
		--no-wait
```

Start

```bash
az aks start \
	--resource-group "rg-sandbox" \
	--name "aks-citools-sbx-ue" --no-wait
```

Get status

```bash
az aks show \
	--resource-group "rg-sandbox" \
	--name "aks-citools-sbx-ue" \
	--query "powerState.code" -o tsv
```
