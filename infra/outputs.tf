output "network_name" {
  value = module.network.network_name
}

output "subnet_name" {
  value = module.network.subnet_name
}

output "instance_name" {
  value = google_compute_instance.app.name
}

output "instance_internal_ip" {
  value = google_compute_instance.app.network_interface[0].network_ip
}

output "bucket_name" {
  value = module.artifacts_bucket.name
}

output "bucket_url" {
  value = module.artifacts_bucket.url
}
