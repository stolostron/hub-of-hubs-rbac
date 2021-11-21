#!/bin/bash

# Copyright (c) 2021 Red Hat, Inc.
# Copyright Contributors to the Open Cluster Management project

set -o errexit
set -o nounset

kubectl get managedcluster "$CLUSTER" -o json |
    jq "{ \"input\": { \"user\": \"$USER\", \"cluster\": . }}" |
    curl -ks https://localhost:8181/v1/data/rbac/clusters/allow -H 'Content-Type: application/json' -d @-
