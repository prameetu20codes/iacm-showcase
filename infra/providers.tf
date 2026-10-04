# Credentials are injected at runtime from the GCP connector attached to the workspace.
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
