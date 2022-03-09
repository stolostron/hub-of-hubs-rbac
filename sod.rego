package rbac.sod

default verify = false

verify {
 not any_violation
}

any_violation {
   some user
   data.roleBindings[user]
   has_violation[user]
}

has_violation[user] {
   some user
   data.roleBindings[user]
   some role1, role2
   data.roles[role1]
   data.roles[role2]
   violation[[user, role1, role2]]
}

# Find users violating SOD
violation[[user, role1, role2]] {
  some user
  userRoles := data.roleBindings[user].roles

# grab one role (including inherited) for a user
  some role1
  data.roles[role1]
  data.rbac.roles.inherited_role[[userRoles[_], role1]]

# grab another role (including inherited) for a user
  some role2
  data.roles[role2]
  data.rbac.roles.inherited_role[[userRoles[_], role2]]

  data.sodRoles[_] == [role1, role2]
}
