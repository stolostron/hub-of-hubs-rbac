# Copyright Contributors to the Open Cluster Management project

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
ENV USER_UID=1001
ENV USER_NAME=opa


COPY clusters.rego clusters.rego
COPY roles.rego roles.rego
COPY sod.rego sod.rego

RUN curl -L -o opa https://openpolicyagent.org/downloads/v0.32.1/opa_linux_amd64_static
RUN chmod 755 ./opa

COPY build/scripts/user_setup /usr/local/scripts/user_setup
RUN  /usr/local/scripts/user_setup

RUN microdnf update && \
    microdnf clean all

USER ${USER_UID}
ENTRYPOINT ["./opa", "run", "--server", "./clusters.rego", "./roles.rego", "./sod.rego", "/data/data.json", "/data/role_bindings.yaml"]
