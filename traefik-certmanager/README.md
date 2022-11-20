## Traefik

```bash
kubectl apply -f 01-namespace.yml
helm install --namespace=traefik -f ./traefik-values.yml traefik traefik/traefik
helm upgrade --namespace=traefik -f ./traefik-values.yml traefik traefik/traefik
```

## Cert Manager

https://cert-manager.io/docs/installation/helm/


```bash
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.10.0 \
  --set installCRDs=true
```


```
kubectl delete secret certmanager-secrets -n cert-manager --ignore-not-found
kubectl create secret generic certmanager-secrets -n cert-manager --from-file=letsencrypt-email=./letsencrypt-email.txt --from-file=cloudflare-token=./cloudflare-token.txt
```