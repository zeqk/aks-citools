https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/cloudflare.md

```bash
kubectl create secret generic cloudflare-credentials --from-literal=apitoken=aaaa -n default
kubectl apply -f 01-externaldns.yml -n default
kubectl apply -f 02-randomservice.yml -n default
```

