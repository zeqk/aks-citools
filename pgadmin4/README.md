https://gist.github.com/zeqk/2dede9e8a41915787118c6ff03bde631

```bash
kubectl apply -f 01-pgadmin.yml  
kubectl port-forward svc/pgadmin 8080:8080
```