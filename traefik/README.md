https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart

```bash
kubectl create secret generic cloudflare-credentials --from-literal=apitoken=aaaa -n traefik-v2
kubectl create secret generic letsencrypt --from-literal=email=aaaa -n traefik-v2

helm install --namespace=traefik-v2  -f ./values.yml  traefik traefik/traefik
helm upgrade --namespace=traefik-v2  -f ./values.yml  traefik traefik/traefik
```

kubectl -n traefik-v2 port-forward $(kubectl get pods -n traefik-v2 --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000

http://localhost:9000/dashboard/#/
