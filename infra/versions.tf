terraform {
  # Harness IaCM supports MPL-licensed Terraform only (up to 1.5.x).
  required_version = ">= 1.5.0, < 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
  }

  # No backend block: Harness-managed state (encrypted, versioned, locked, RBAC-protected).
}
