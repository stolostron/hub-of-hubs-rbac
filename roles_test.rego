package rbac.roles

test_inherited_role_level0 {
   inherited_role[["developer", "developer"]]
}

test_inherited_role_level0_isA_only {
   inherited_role[["devops", "devops"]]
}

test_inherited_role_unknown {
   not inherited_role[["salesman", "salesman"]]
}

test_inherited_role_level1 {
   inherited_role[["devops", "devops"]]
   inherited_role[["devops", "developer"]]
   inherited_role[["devops", "SRE"]]
}

test_inherited_role_level2 {
   inherited_role[["highClearanceDevops", "highClearanceDevops"]]
   inherited_role[["highClearanceDevops", "devops"]]
   inherited_role[["highClearanceDevops", "highClearance"]]	
   inherited_role[["highClearanceDevops", "developer"]]
   inherited_role[["highClearanceDevops", "SRE"]]
}