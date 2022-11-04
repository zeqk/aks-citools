https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/cloudflare.md

```bash
kubectl apply -f 01-namespace.yml
kubectl delete secret cloudflare-credentials -n external-dns --ignore-not-found
kubectl create secret generic cloudflare-credentials -n external-dns --from-file=apitoken=./token.txt
kubectl apply -f 02-externaldns.yml
kubectl apply -f 03-randomservice.yml -n default
```

