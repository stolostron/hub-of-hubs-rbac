package rbac.sod

test_direct_violation {
   violation[["MARY", "developer", "highClearance"]]
}

test_inherited_violation {
   violation[["JANE", "developer", "highClearance"]]
}

test_has_violation_negative {
    not has_violation["VADIME"]
    not has_violation["JOHN"]
}

test_has_violation {
    has_violation["MARY"]
    has_violation["JANE"]
}

test_any_violation {
   any_violation
}

test_verify {
  not verify
}