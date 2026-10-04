variable "project_id" {
  description = "GCP project ID that owns the bucket."
  type        = string
}

variable "name" {
  description = "Globally unique bucket name (lowercase, 3-63 characters)."
  type        = string
}

variable "location" {
  description = "Bucket location, for example US-CENTRAL1 or US."
  type        = string
  default     = "US-CENTRAL1"
}

variable "labels" {
  description = "Labels to apply to the bucket."
  type        = map(string)
  default     = {}
}

variable "versioning_enabled" {
  description = "Keep previous versions of overwritten or deleted objects."
  type        = bool
  default     = true
}

variable "delete_after_days" {
  description = "Delete objects older than this many days."
  type        = number
  default     = 30
}

variable "force_destroy" {
  description = "Allow destroy to delete a non-empty bucket. Keep true for demos, false for real data."
  type        = bool
  default     = true
}
