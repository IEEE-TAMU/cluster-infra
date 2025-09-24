# Under Construction

```bash
flux bootstrap github \
--owner=ieee-tamu \
--repository=cluster-infra \
--branch=main \
--path=./cluster \
--private=false
```

```bash
helm install flux-operator oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
  --namespace flux-system --create-namespacea
```

bootstrap:

```
kubectl apply -f bootstrap.yaml
```

```yaml
apiVersion: fluxcd.controlplane.io/v1
kind: FluxInstance
metadata:
  name: flux
  namespace: flux-system
spec:
  sync:
    kind: GitRepository
    url: "https://github.com/ieee-tamu/cluster-infra.git"
    ref: "refs/heads/main"
    path: "cluster"
```

