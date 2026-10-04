variable "project_id" {
  type = string
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

module "network" {
  source = "../.."

  project_id  = var.project_id
  name        = "iacm-module-test-net"
  subnet_cidr = "10.99.0.0/24"
}

output "network_name" {
  value = module.network.network_name
}
