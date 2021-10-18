package system.authz

# Deny access by default.
default allow = false


# Allow GET only
allow {
    input.method = "GET"
}

# Allow POST to /v1/compile - partial evaluations
allow {
    input.method = "POST"
    input.path[0] = "v1"
    input.path[1] = "compile"
}
