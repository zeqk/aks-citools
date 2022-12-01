## Gitlab Runner

https://docs.gitlab.com/runner/install/kubernetes.html

```bash
RUNNER_REGISTRATION_TOKEN=aaa
```

```bash
kubectl apply -f 01-namespace.yml
helm repo add gitlab https://charts.gitlab.io
helm install --namespace gitlab-runner gitlab-runner -f ./runner-values.yml --set runnerRegistrationToken="$RUNNER_REGISTRATION_TOKEN" gitlab/gitlab-runner
```

```bash
helm uninstall --namespace gitlab-runner gitlab-runner 
```