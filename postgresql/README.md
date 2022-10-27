## Install Operator

https://opensource.zalando.com/postgres-operator/docs/quickstart.html#helm-chart

```bash
# add repo for postgres-operator
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator

# install the postgres-operator
helm install postgres-operator postgres-operator-charts/postgres-operator --namespace postgres

#verify
kubectl --namespace=postgres get pods -l "app.kubernetes.io/name=postgres-operator"
```

## Deploy DB

```bash
kubectl apply -f 02-postgresql.yml 

# get name of master pod of acid-minimal-cluster
export PGMASTER=$(kubectl get pods -o jsonpath={.items..metadata.name} -l application=spilo,cluster-name=acid-minimal-cluster,spilo-role=master -n default)

# set up port forward
kubectl port-forward $PGMASTER 6432:5432 -n default
```

```bash
export PGPASSWORD=$(kubectl get secret postgres.acid-minimal-cluster.credentials.postgresql.acid.zalan.do -o 'jsonpath={.data.password}' | base64 -d)
export PGPASSWORD=$(kubectl get secret dba.acid-minimal-cluster.credentials.postgresql.acid.zalan.do -o 'jsonpath={.data.password}' | base64 -d)
```