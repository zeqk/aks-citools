https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart

```bash
kubectl apply -f 01-namespace.yml
kubectl -n traefik get secret traefik-secrets -o jsonpath="{.data.letsencrypt-email}" | base64 -d; echo
kubectl -n traefik get secret traefik-secrets -o jsonpath="{.data.cloudflare-token}" | base64 -d; echo
kubectl delete secret traefik-secrets -n traefik --ignore-not-found
kubectl create secret generic traefik-secrets -n traefik --from-file=letsencrypt-email=./letsencrypt-email.txt --from-file=cloudflare-token=./cloudflare-token.txt

helm install --namespace=traefik  -f ./values.yml traefik traefik/traefik
helm upgrade --namespace=traefik  -f ./values.yml traefik traefik/traefik

helm uninstall --namespace=traefik traefik
```

```bash
kubectl get all -n traefik
```

```bash
kubectl -n traefik port-forward $(kubectl get pods -n traefik --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000
```

http://localhost:9000/dashboard/#/
