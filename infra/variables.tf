# Supplied by the "gcp-showcase-defaults" Variable Set.
variable "project_id" {
  description = "GCP project ID to provision into."
  type        = string
}

variable "owner" {
  description = "Value of the owner label on every labelled resource."
  type        = string
}

variable "cost_center" {
  description = "Value of the cost_center label on every labelled resource."
  type        = string
}

# Supplied per workspace.
variable "environment" {
  description = "Environment name, for example dev or prod."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

# Supplied by the workspace variable file (env/<environment>.tfvars).
variable "subnet_cidr" {
  description = "CIDR of the environment subnet."
  type        = string
}

# HCL defaults. The prod workspace overrides machine_type to show variable precedence.
variable "region" {
  description = "Default region."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone for the VM."
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "VM machine type. The OPA policy only allows e2-micro and e2-small."
  type        = string
  default     = "e2-micro"
}

variable "bucket_delete_after_days" {
  description = "Lifecycle age for objects in the artifacts bucket."
  type        = number
  default     = 30
}
