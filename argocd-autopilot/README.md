# ArgoCD Autopilot

https://argocd-autopilot.readthedocs.io/en/stable/

## Bootstrap

```bash
export GIT_TOKEN=<YOUR_TOKEN>
export GIT_REPO=https://github.com/octubre-softlab/aks-citools/k8s-argocd

argocd-autopilot repo bootstrap
```

```bash
kubectl port-forward -n argocd svc/argocd-server 8083:80
```

## Recover

````bash
export GIT_TOKEN=$(cat github-token) && \
export GIT_REPO=https://github.com/zeqk/aks-citools/k8s-argocd/

argocd-autopilot repo bootstrap --recover

kubectl get secrets argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d;
 echo

kubectl port-forward -n argocd svc/argocd-server 8083:80
```