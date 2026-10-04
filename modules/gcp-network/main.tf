resource "google_compute_network" "this" {
  project                 = var.project_id
  name                    = var.name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "this" {
  project                  = var.project_id
  name                     = "${var.name}-${var.region}"
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_firewall" "iap_ssh" {
  project       = var.project_id
  name          = "${var.name}-allow-iap-ssh"
  network       = google_compute_network.this.name
  direction     = "INGRESS"
  source_ranges = var.ssh_source_ranges
  target_tags   = [var.ssh_target_tag]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
