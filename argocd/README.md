# Instalación manual

https://argo-cd.readthedocs.io/en/stable/getting_started/

Deployar argocd

```bash
kubectl apply -f 01-namespace.yml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Exponer argocd

```
kubectl port-forward svc/argocd-server -n argocd 8083:443
```


```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Desinstalar

```
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```