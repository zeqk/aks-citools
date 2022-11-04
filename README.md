This project is to test the use of kubernetes in an AKS (Azure Kubernetes Service)
## Config

Set kube.config

```bash
az account set --subscription "$(az account list --query "[?name == \`Sistemas - Non Production\`].id" -o tsv)"
az aks get-credentials --resource-group rg-sandbox --name aks-citools-sbx-ue
```

Set context

```bash
kubectl config set-context --current --namespace=default
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
## Other commands

### DB

```bash
# Get status
az postgres flexible-server show --resource-group "rg-sandbox" --name "psql-wa01-sbx-ue" --query "state"  --no-wait
# Stop
az postgres flexible-server stop --resource-group "rg-sandbox" --name "psql-wa01-sbx-ue"
# Start
az postgres flexible-server stop --resource-group "rg-sandbox" --name "psql-wa01-sbx-ue"  --no-wait
```