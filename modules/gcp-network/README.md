# gcp-network

Creates a custom-mode VPC with one regional subnet (Private Google Access on) and a firewall rule that allows SSH only from Google's Identity-Aware Proxy range.

## Usage

```hcl
module "network" {
  source  = "app.harness.io/jDOmhrFmSOGZJ1C91UC_hg/gcp-network/google"
  version = "<VERSION>"

  project_id  = "my-project"
  name        = "iacm-showcase-dev"
  region      = "us-central1"
  subnet_cidr = "10.10.0.0/24"
}
```

Copy the exact `source` and `version` from the module's **Instructions** tab in the Harness Module Registry.

## Resources

- `google_compute_network`
- `google_compute_subnetwork`
- `google_compute_firewall`

## Requirements

- Terraform >= 1.3 (Harness IaCM supports Terraform up to 1.5.x)
- Google provider >= 5.0, < 7.0
- Compute Engine API enabled on the project
