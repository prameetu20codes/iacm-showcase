output "network_id" {
  description = "ID of the VPC network."
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "Name of the VPC network."
  value       = google_compute_network.this.name
}

output "subnet_name" {
  description = "Name of the subnet."
  value       = google_compute_subnetwork.this.name
}

output "subnet_self_link" {
  description = "Self link of the subnet, used when attaching instances."
  value       = google_compute_subnetwork.this.self_link
}

output "ssh_target_tag" {
  description = "Network tag to put on instances that should accept IAP SSH."
  value       = var.ssh_target_tag
}
