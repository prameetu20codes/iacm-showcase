package iacm_showcase.bucket_hardening

# Policy set entity type: Terraform Plan, event: After Terraform Plan.

deny[msg] {
	rc := buckets[_]
	rc.change.after.public_access_prevention != "enforced"
	msg := sprintf("%s must set public_access_prevention = \"enforced\"", [rc.address])
}

deny[msg] {
	rc := buckets[_]
	rc.change.after.uniform_bucket_level_access != true
	msg := sprintf("%s must set uniform_bucket_level_access = true", [rc.address])
}

buckets[rc] {
	rc := input.resource_changes[_]
	rc.type == "google_storage_bucket"
	rc.change.actions != ["delete"]
}
