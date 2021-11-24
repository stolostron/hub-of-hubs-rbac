# hub-of-hubs-rbac

[Open Policy Agent](https://www.openpolicyagent.org)-based RBAC for [Hub-of-Hubs](https://github.com/open-cluster-management/hub-of-hubs).

## Run the server

1. Generate a certificate `tls.crt' and a key `tls.key`. For testing purposes only, you can generate self signed certificates:

```
mkdir certs
openssl genrsa -out ./certs/tls.key 2048
openssl req -new -x509 -key ./certs/tls.key -out ./certs/tls.crt -days 365 -subj '/O=example Inc./CN=example.com'
```

```
make run
```

## Run client queries

### Complie API with partial evaluation
```
USER=JACK envsubst < query.json | curl -ks https://localhost:8181/v1/compile?pretty -H 'Content-Type: application/json' -d @-
```

```
USER=JOHN envsubst < query.json | curl -ks https://localhost:8181/v1/compile?pretty -H 'Content-Type: application/json' -d @-
```

### Data API

Allowed cluster:

Specify `USER`, `CLUSTER` and `KUBECONFIG` environment variables:

```
USER=JACK CLUSTER=cluster1 KUBECONFIG=$HUB1_CONFIG ./check_cluster.sh
```

SOD:

```
curl -ks https://localhost:8181/v1/data/rbac/sod/verify?pretty -H 'Content-Type: application/json'
curl -ks https://localhost:8181/v1/data/rbac/sod/has_violation?pretty -H 'Content-Type: application/json'
curl -ks https://localhost:8181/v1/data/rbac/sod/violation?pretty -H 'Content-Type: application/json'
```

Data:

```
curl -ks https://localhost:8181/v1/data/roles/developer?pretty -H 'Content-Type: application/json'
curl -ks https://localhost:8181/v1/data/roleBindings/JACK?pretty -H 'Content-Type: application/json'
```

Update data:

```
ROLE=SRE envsubst < patch_role_binding.json | curl -X PATCH localhost:8181/v1/data/roleBindings/JACK -H 'Content-Type: application/json' -d @-
```

## Evaluate individual rules

```
opa eval -d testdata -d roles.rego --format=pretty 'data.rbac.roles.inherited_role[["highClearanceDevops",r]]'
```

Output:
```
data.rbac.roles.inherited_role[["highClearanceDevops",r]]
+-----------------------+-----------------------------------------------------------+
|           r           | data.rbac.roles.inherited_role[["highClearanceDevops",r]] |
+-----------------------+-----------------------------------------------------------+
| "highClearanceDevops" | ["highClearanceDevops","highClearanceDevops"]             |
| "devops"              | ["highClearanceDevops","devops"]                          |
| "highClearance"       | ["highClearanceDevops","highClearance"]                   |
| "SRE"                 | ["highClearanceDevops","SRE"]                             |
| "developer"           | ["highClearanceDevops","developer"]                       |
+-----------------------+-----------------------------------------------------------+

```

## Test

```
make test
```

## Run in Docker

```
docker run -p 8181:8181 <the docker image>
```

## Deploy to a Kubernetes cluster

The following environment variables are required for the most tasks below:

* `REGISTRY`, for example `docker.io/vadimeisenbergibm`.
* `IMAGE_TAG`, for example `v0.1.0`.

1.  Create a secret for RBAC data

    ```
    kubectl create secret generic opa-data -n open-cluster-management --from-file=data.json --from-file=role_bindings.yaml --from-file=opa_authorization.rego
    ```

1.  Deploy the component:

    ```
    COMPONENT=$(basename $(pwd)) envsubst < deploy/operator.yaml.template | kubectl apply -n open-cluster-management -f -
    ```

## Update role bindings or role definitions

To update role bindings, edit [role_bindings.yaml](role_bindings.yaml) and add your user
(the user name that appears in the top right corner, when you login into OpenShift console).

The role definitions appear in [testdata/data.json](testdata/data.json).

Run the following commands:

```
kubectl delete secret opa-data -n open-cluster-management  --ignore-not-found
kubectl create secret generic opa-data -n open-cluster-management --from-file=testdata/data.json --from-file=role_bindings.yaml --from-file=opa_authorization.rego
kubectl rollout restart deployment hub-of-hubs-rbac -n open-cluster-management
```

### Security measures

1. Network policy allows access only from open-cluster-management namespace
1. The opa server runs in TLS mode, with certificates generated/rotated by OpenShift
1. The opa authorization allows only GET methods (POST are allowed only for /v1/compile paths - partial evaluation, and /v1/data/rbac/clusters/allow), so no update of policies/data is possible through REST API
1. The data of the policies is in a secret

### Working with Kubernetes deployment

Show log:

```
kubectl logs -l name=$(basename $(pwd)) --kubeconfig $TOP_HUB_CONFIG -n open-cluster-management
```

Execute commands on the container:

```
kubectl exec -it $(kubectl get pod -l name=$(basename $(pwd)) -o jsonpath='{.items..metadata.name}' -n open-cluster-management) \
-n open-cluster-management -- curl -ks https://localhost:8181/v1/data/roles/developer?pretty -H 'Content-Type: application/json'
```

## References

* https://blog.openpolicyagent.org/write-policy-in-opa-enforce-policy-in-sql-d9d24db93bf4
* https://github.com/open-policy-agent/contrib/tree/efb4466b7d23ae6356ea8337c3a1e2632e93d7b3/data_filter_elasticsearch
* https://github.com/open-policy-agent/opa/issues/947
