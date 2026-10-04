variable "project_id" {
  type    = string
  default = "customer-success-244100"
}

provider "google" {
  project = var.project_id
}

module "bucket" {
  source = "../.."

  project_id = var.project_id
  name       = "${var.project_id}-iacm-module-test"
  labels = {
    owner       = "iacm-module-test"
    environment = "test"
    cost_center = "demo"
  }
}

output "bucket_name" {
  value = module.bucket.name
}
