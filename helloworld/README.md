```bash
kubectl apply -f 00-deployment.yml
kubectl get all -n helloworld
kubectl port-forward deployment.apps/hello -n helloworld 8080:8080
```

https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/