# gcp-bucket

Creates a hardened Cloud Storage bucket: uniform bucket-level access, public access prevention enforced, object versioning, and an age-based delete lifecycle rule.

## Usage

```hcl
module "bucket" {
  source  = "app.harness.io/<HARNESS_ACCOUNT_ID>/gcp-bucket/google"
  version = "<VERSION>"

  project_id = "my-project"
  name       = "my-project-iacm-showcase-dev"
  labels     = { owner = "platform", environment = "dev", cost_center = "demo" }
}
```

Copy the exact `source` and `version` from the module's **Instructions** tab in the Harness Module Registry.

## Resources

- `google_storage_bucket`

## Requirements

- Terraform >= 1.3 (Harness IaCM supports Terraform up to 1.5.x)
- Google provider >= 5.0, < 7.0
- Cloud Storage API enabled on the project
