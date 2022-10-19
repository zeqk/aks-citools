
```bash
export GIT_TOKEN=<YOUR_TOKEN>
export GIT_REPO=https://github.com/octubre-softlab/aks-citools/k8s-argocd

argocd-autopilot repo bootstrap
```


```
kubectl port-forward -n argocd svc/argocd-server 8083:80
```