package rbac.clusters

default allow = false # unless otherwise defined, allow is false

allow {
      user := input.user
#     not data.rbac.sod.has_violation[user]
      userRoles := data.roleBindings[user].roles
      some role
      data.roles[role]
      data.rbac.roles.inherited_role[[userRoles[_], role]]
      role_allowed[role]
}


role_allowed[roleId] {
      role := data.roles[roleId]

      label := object.get(role, "clusterHasLabel", "*")
      labels_match[label]

      clusterSet := object.get(role, "inClusterSet", "default")
      clusters := data.clusterSets[clusterSet]
      names_match[clusters]

      notInClusterSet := object.get(role, "notInClusterSet", "")
      notInClusters := object.get(data.clusterSets, notInClusterSet, [])
      not names_match[notInClusters]
}

labels_match["*"]

labels_match[label] {
     val := input.cluster.metadata.labels[key]
     label := data.roles[_].clusterHasLabel
     label[key] == val
}

names_match[["*"]]

names_match[clusters] {
    clusters := data.clusterSets[_]
    clusters != ["*"]
    clusters[_] == input.cluster.metadata.name
}
