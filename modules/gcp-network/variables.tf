variable "project_id" {
  description = "GCP project ID to create the network in."
  type        = string
}

variable "name" {
  description = "Name of the VPC network. Also used as a prefix for the subnet and firewall rule."
  type        = string
}

variable "region" {
  description = "Region for the subnet."
  type        = string
  default     = "us-central1"
}

variable "subnet_cidr" {
  description = "Primary IPv4 CIDR range of the subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "ssh_source_ranges" {
  description = "Source ranges allowed to SSH. Defaults to Google's Identity-Aware Proxy range, so no public SSH is opened."
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "ssh_target_tag" {
  description = "Network tag that instances must carry to receive the SSH firewall rule."
  type        = string
  default     = "allow-iap-ssh"
}
