https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart

```bash
helm install --namespace=traefik-v2  traefik traefik/traefik
```

kubectl -n traefik-v2 port-forward $(kubectl get pods -n traefik-v2 --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000

http://localhost:9000/dashboard/#/
