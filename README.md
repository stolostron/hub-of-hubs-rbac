# hub-of-hubs-rbac

[Open Policy Agent](https://www.openpolicyagent.org)-based RBAC for [Hub-of-Hubs](https://github.com/open-cluster-management/hub-of-hubs).

## Run the server

```
make run
```

## Run client queries

### Complie API with partial evaluation
```
USER=JACK envsubst < query.json | curl -s localhost:8181/v1/compile?pretty -H 'Content-Type: application/json' -d @-
```

```
USER=JOHN envsubst < query.json | curl -s localhost:8181/v1/compile?pretty -H 'Content-Type: application/json' -d @-
```

### Data API

Allowed cluster:

Specify `USER`, `CLUSTER` and `KUBECONFIG` environment variables:

```
USER=JACK CLUSTER=cluster1 KUBECONFIG=$HUB1_CONFIG ./check_cluster.sh
```

SOD:

```
curl localhost:8181/v1/data/rbac/sod/verify?pretty -H 'Content-Type: application/json'
curl localhost:8181/v1/data/rbac/sod/has_violation?pretty -H 'Content-Type: application/json'
curl localhost:8181/v1/data/rbac/sod/violation?pretty -H 'Content-Type: application/json'
```

Data:

```
curl localhost:8181/v1/data/roles/developer?pretty -H 'Content-Type: application/json'
curl localhost:8181/v1/data/roleBindings/JACK?pretty -H 'Content-Type: application/json'
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

1.  Edit role_bindings.yaml and specify your role bindings

1.  Create a secret for RBAC data

    ```
    kubectl create secret generic opa-data --kubeconfig $TOP_HUB_CONFIG -n open-cluster-management --from-file=testdata/data.json --from-file=role_bindings.yaml
    ```

1.  Deploy the component:

    ```
    COMPONENT=$(basename $(pwd)) envsubst < deploy/operator.yaml.template | kubectl apply --kubeconfig $TOP_HUB_CONFIG -n open-cluster-management -f -
    ```

### Security measures

1. Network policy allows access only from open-cluster-management namespace
1. The opa server runs in TLS mode, with certificates generated/rotated by OpenShift
1. The opa authorization allows only GET methods, so no update of policies/data is possible through REST API
1. The data of the policies is in a secret

### Working with Kubernetes deployment

Show log:

```
kubectl logs -l name=$(basename $(pwd)) --kubeconfig $TOP_HUB_CONFIG -n open-cluster-management
```

Execute commands on the container:

```
kubectl exec -it $(kubectl get pod -l name=$(basename $(pwd)) -o jsonpath='{.items..metadata.name}' -n open-cluster-management) \
-n open-cluster-management -- curl localhost:8181/v1/data/roles/developer?pretty -H 'Content-Type: application/json'
```

## References

* https://blog.openpolicyagent.org/write-policy-in-opa-enforce-policy-in-sql-d9d24db93bf4
* https://github.com/open-policy-agent/contrib/tree/efb4466b7d23ae6356ea8337c3a1e2632e93d7b3/data_filter_elasticsearch
* https://github.com/open-policy-agent/opa/issues/947
