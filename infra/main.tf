locals {
  name_prefix = "iacm-showcase-${var.environment}"

  common_labels = {
    owner       = var.owner
    environment = var.environment
    cost_center = var.cost_center
    managed_by  = "harness-iacm"
  }
}

# Replace <VERSION> with the version (and confirm the source) from the
# module's Instructions tab in the Harness Module Registry.
# To run before the modules are registered, use: source = "../modules/gcp-network" (and drop version).
module "network" {
  source  = "app.harness.io/jDOmhrFmSOGZJ1C91UC_hg/gcp-network/google"
  version = "<VERSION>"

  project_id  = var.project_id
  name        = local.name_prefix
  region      = var.region
  subnet_cidr = var.subnet_cidr
}

# To run before the modules are registered, use: source = "../modules/gcp-bucket" (and drop version).
module "artifacts_bucket" {
  source  = "app.harness.io/jDOmhrFmSOGZJ1C91UC_hg/gcp-bucket/google"
  version = "<VERSION>"

  project_id        = var.project_id
  name              = "${var.project_id}-${local.name_prefix}"
  location          = upper(var.region)
  labels            = local.common_labels
  delete_after_days = var.bucket_delete_after_days
}

resource "google_compute_instance" "app" {
  name         = "${local.name_prefix}-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = [module.network.ssh_target_tag]
  labels       = local.common_labels

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-standard"
    }
  }

  # No access_config block, so the VM gets no public IP. Reach it with IAP SSH.
  network_interface {
    subnetwork = module.network.subnet_self_link
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}
