package rbac.clusters

test_developer_allowed {
   allow with input as { "user": "JOHN", "cluster": {
	 "metadata": { "name": "cluster7", "labels": {"environment": "dev"}},  "notOneOf": ["cluster0", "cluster1"]}}
}

test_developer_not_allowed_sensitive {
   not allow with input as { "user": "JOHN", "cluster": {
	 "metadata": { "name": "cluster1", "labels": {"environment": "dev"}},  "notOneOf": ["cluster0", "cluster1"]}}
}

test_developer_not_allowed_production {
   not allow with input as { "user": "JOHN", "cluster": { "metadata": { "name": "cluster7", "labels": {"environment": "production"}},  "notOneOf": ["cluster0", "cluster1"]}}
}

test_allowed_all_labels {
   allow with input as { "user": "BRUNO", "cluster": { "metadata": { "name": "cluster7", "labels": {"environment": "production"}},  "notOneOf": []}}
}

test_devops_allowed_dev {
   allow with input as { "user": "JACK", "cluster": { "metadata": { "name": "cluster7", "labels": {"environment": "dev"}},  "notOneOf": ["cluster0", "cluster1"]}}
}

test_devops_not_allowed_sensitive {
   not allow with input as { "user": "JACK", "cluster": { "metadata": { "name": "cluster0", "labels": {"environment": "production"}},  "notOneOf": ["cluster0", "cluster1"]}}
}

test_devops_not_allowed_staging {
   not allow with input as { "user": "JACK", "cluster": { "hasLabel": { "environment=staging": true },  "notOneOf": ["cluster0", "cluster1"]}}
}

test_high_clearance_devops_allowed_dev {
   allow with input as { "user": "JANE", "cluster": { "metadata": { "name": "cluster0", "labels": {"environment": "dev"}},  "notOneOf": ["cluster0", "cluster1"]}}
}

test_high_clearance_devops_allowed_production {
   allow with input as { "user": "JANE", "cluster": { "metadata": { "name": "cluster7", "labels": {"environment": "production"}},  "notOneOf": ["cluster0", "cluster1"]}}
}

test_high_clearance_devops_allowed_sensitive {
   allow with input as { "user": "JANE", "cluster": { "metadata": { "name": "cluster7", "labels": {"environment": "production"}}, "notOneOf": []}}
}

test_high_clearance_allowed_sensitive {
   allow with input as { "user": "RICHARD", "cluster": { "metadata": { "name": "cluster1", "labels": {"environment": "production"}}, "notOneOf": []}}
}

test_high_clearance_devops_not_allowed_staging {
   not allow with input as { "user": "JANE", "cluster": { "hasLabel": { "environment=staging": true },  "notOneOf": ["cluster0", "cluster1"]}}
}
