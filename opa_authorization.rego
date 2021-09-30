package system.authz

# Deny access by default.
default allow = false

# Allow GET only
allow {
    input.method = "GET"
}