# RBAC demo with OPA

1.  Define `TOKEN` and `CLUSTER_URL` environment variables

1.  Show the clusters in the DB

    ```
    select payload -> 'metadata' -> 'labels' as labels from status.managed_clusters ORDER BY payload -> 'metadata' ->>'name';
    ```

    Output:

    ```
    labels
    ---------------------------------------------------------------------
    {"name": "cluster0", "vendor": "Kind", "environment": "prod"}
    {"name": "cluster1", "vendor": "Kind", "environment": "prod"}
    {"name": "cluster2", "vendor": "Kind", "environment": "prod"}
    {"name": "cluster3", "vendor": "Kind", "environment": "dev"}
    {"name": "cluster4", "vendor": "Kind"}
    {"name": "cluster5", "vendor": "Kind", "environment": "prod"}
    {"name": "cluster6", "vendor": "Kind", "environment": "prod"}
    {"name": "cluster7", "vendor": "Kind"}
    {"name": "cluster8", "vendor": "Kind"}
    {"name": "cluster9", "vendor": "Kind", "environment": "dev"}
    ```

1.  Show some SQL queries on the table:

    ```
    SELECT payload -> 'metadata' ->> 'name' FROM status.managed_clusters WHERE
    payload -> 'metadata' -> 'labels' ->> 'environment' = 'dev';
    ```

    ```
    SELECT payload -> 'metadata' ->> 'name' FROM status.managed_clusters WHERE
    payload -> 'metadata' -> 'labels' ->> 'environment' = 'prod';
    ```

1.  Show that there are no managed cluster CRs defined in the Hub-of-Hubs:

    ```
    kubectl config view | grep server
    kubectl get managedcluster -A
    kubectl get ns cluster0
    ```
1.  Show the managed clusters on the leaf hub1:

    ```
    kubectl get managedcluster --kubeconfig $HUB1_CONFIG 
    kubectl get ns cluster0 --kubeconfig $HUB1_CONFIG 
    ```
    
3.  Show the current identity:

    ```
    curl -k https://api.$CLUSTER_URL:6443/apis/user.openshift.io/v1/users/~ -H "Authorization: Bearer $TOKEN"
    ```

1.  Show the managed clusters in the ACM UI.

1.  Show the managed clusters in Non-Kubernetes REST API:

    ```
    curl -ks  https://multicloud-console.apps.$CLUSTER_URL/multicloud/hub-of-hubs-nonk8s-api/managedclusters  -H "Authorization: Bearer $TOKEN" |  jq .[].metadata.name | sort
    ```

1.  Show the SQL query performed by Non-Kubernetes REST API:

    ```
    kubectl logs -l name=hub-of-hubs-nonk8s-api -n open-cluster-management
    ```
    
3.  Edit `role_bindings.yaml`, change your role to be one of: `developer`, `SRE`, `devops`, `highClearance`,
    `highClearanceDevops`, `admin`.

1.  Redefine the secret with the role bindings and restart the RBAC component:

    ```
    kubectl delete secret opa-data -n open-cluster-management --ignore-not-found
    kubectl create secret generic opa-data -n open-cluster-management --from-file=testdata/data.json --from-file=role_bindings.yaml --from-file=opa_authorization.rego
    kubectl rollout restart deployment hub-of-hubs-rbac -n open-cluster-management
    ```

1.  Watch the RBAC pods are recreated:

    ```
    watch kubectl get pod -l name=hub-of-hubs-rbac -n open-cluster-management
    ```
    
3.  Check the SOD violation (for `developer` and `highClearance` roles):

    ```
    kubectl exec -it $(kubectl get pod -l name=hub-of-hubs-rbac -o jsonpath='{.items[0].metadata.name}' -n open-cluster-management) \
    -n open-cluster-management -- curl -ks https://localhost:8181/v1/data/rbac/sod?pretty -H 'Content-Type: application/json'
    ```
