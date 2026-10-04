package iacm_showcase.allowed_machine_types

# Policy set entity type: Terraform Plan, event: After Terraform Plan.

allowed_machine_types := {"e2-micro", "e2-small"}

deny[msg] {
	rc := input.resource_changes[_]
	rc.type == "google_compute_instance"
	not is_delete(rc)
	machine_type := rc.change.after.machine_type
	not allowed_machine_types[machine_type]
	msg := sprintf("%s uses machine type '%s'. Allowed: %v", [rc.address, machine_type, allowed_machine_types])
}

is_delete(rc) {
	rc.change.actions == ["delete"]
}
