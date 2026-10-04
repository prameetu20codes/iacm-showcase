package iacm_showcase.required_labels

# Policy set entity type: Terraform Plan, event: After Terraform Plan.

labelled_types := {"google_compute_instance", "google_storage_bucket"}

required_labels := {"owner", "environment", "cost_center"}

deny[msg] {
	rc := input.resource_changes[_]
	labelled_types[rc.type]
	not is_delete(rc)
	labels := object.get(rc.change.after, "labels", {})
	label := required_labels[_]
	not has_label(labels, label)
	msg := sprintf("%s is missing required label '%s'", [rc.address, label])
}

has_label(labels, label) {
	labels[label] != ""
}

is_delete(rc) {
	rc.change.actions == ["delete"]
}
