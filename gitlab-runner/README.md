
```bash
RUNNER_REGISTRATION_TOKEN=aaa
```

```bash
kubectl create ns gitlab-runners
helm install --namespace gitlab-runner gitlab-runner -f ./runner-values.yml --set runnerRegistrationToken="$RUNNER_REGISTRATION_TOKEN" gitlab/gitlab-runner
```

```bash
helm uninstall --namespace gitlab-runner gitlab-runner 
```