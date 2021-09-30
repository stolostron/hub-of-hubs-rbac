package rbac.roles

# no recursive definitions in Rego, see https://github.com/open-policy-agent/opa/issues/947

# level 0 for data.roles
inherited_role[[role, inheritedRole]] {
   data.roles[role]
   role = inheritedRole
}

# level 0 for data.isA
inherited_role[[role, inheritedRole]] {
   data.isA[role]
   role = inheritedRole
}

# level 1
inherited_role[[role, inheritedRole]] {
   data.isA[role].roles[_] = inheritedRole
}

# level 2
inherited_role[[role, inheritedRole]] {
   data.isA[role].roles[_] = singleLevelInheritedRole
   data.isA[singleLevelInheritedRole].roles[_] = inheritedRole
}
