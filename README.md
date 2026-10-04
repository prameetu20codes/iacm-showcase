# Harness IaCM end-to-end showcase (GCP + Terraform)

One repo that exercises every major Harness IaCM capability: Module Registry, workspaces per environment, Variable Sets, variable files, Harness-managed state, cost estimation, OPA policy gates, approvals, the Queue step, output parameters, PR automation, drift detection, import, and destroy.

## What gets created in GCP (per environment)

- A custom VPC, one subnet, and an IAP-only SSH firewall rule (from the `gcp-network` registry module). Free.
- A hardened Cloud Storage bucket (from the `gcp-bucket` registry module). Effectively free when empty.
- One `e2-micro` VM with no public IP. This is the resource that gives cost estimation a real number and gives OPA something to block.

Destroy both workspaces when you are done. Leaving them running costs a few dollars a month at list price.

## Repo layout

```
modules/gcp-network/        Registry module: VPC + subnet + firewall (with examples/basic for module tests)
modules/gcp-bucket/         Registry module: hardened bucket (with examples/basic for module tests)
infra/                      Workspace root, consumes both modules from the registry
infra/env/{dev,prod}.tfvars Workspace variable files
infra/imports.tf.example    Import-block demo for brownfield adoption
policies/*.rego             OPA policies (entity type: Terraform Plan)
pipelines/*.yaml            Provision (dev -> prod), PR plan, drift, destroy
triggers/*.yaml             PR webhook trigger, 6-hourly drift cron trigger
```

## Version constraints you must respect

- Harness IaCM supports Terraform up to **1.5.x** only. Set the workspace provisioner version to **1.5.7**. `infra/versions.tf` enforces `< 1.6.0`.
- Native `terraform test` (`*.tftest.hcl`) needs Terraform 1.6+, so module testing here uses the registry's **integration testing** (each `examples/` subfolder runs init, plan, apply, destroy).
- `removed` blocks need Terraform 1.7+, so they are not part of this showcase.

---

## Setup runbook

Values used in this repo:

- Harness account ID: `jDOmhrFmSOGZJ1C91UC_hg`
- Harness org ID: `testprameet`
- Harness project ID: `testproj`
- GCP project ID: `customer-success-244100`

Still to fill in: `<GITHUB_CONNECTOR_ID>` in `triggers/pr-plan-trigger.yaml`, and the module `<VERSION>` values in `infra/main.tf` (step 4).

### 1. GCP prerequisites

1. Enable the Compute Engine and Cloud Storage APIs on `customer-success-244100`:

   ```bash
   gcloud services enable compute.googleapis.com storage.googleapis.com --project customer-success-244100
   ```
2. Create a service account (or OIDC workload identity) for Harness with Compute Admin and Storage Admin on the project.

### 2. GitHub repo

Push this folder to a GitHub repo (for example `iacm-showcase`), branch `main`. Then create the module version tags. Each Git tag is a module version:

```bash
git tag gcp-network-v1.0.0
git tag gcp-bucket-v1.0.0
git push origin --tags
```

### 3. Harness connectors

1. **GitHub connector** with API access enabled (needed for PR comments and webhooks).
2. **GCP connector** using the service account key or OIDC.

### 4. Module Registry

Infrastructure as Code Management > Module Registry > New Module, once per module:

| Field | gcp-network | gcp-bucket |
|---|---|---|
| Name | `gcp-network` | `gcp-bucket` |
| Provider | `google` | `google` |
| Git connector / branch | your GitHub connector / `main` | same |
| Folder Path | `modules/gcp-network` | `modules/gcp-bucket` |
| Storage type (Advanced) | Artifact | Artifact |
| Git Tag Pattern | `gcp-network-v*` | `gcp-bucket-v*` |
| Execution pipeline | `iacm_auto_generated_onboarding_pipeline`, auto-sync on | same |

After the onboarding pipeline runs, open each module's **Instructions** tab and copy the `version` into the two `module` blocks in `infra/main.tf`, replacing `<VERSION>`. The `source` is already set to `app.harness.io/jDOmhrFmSOGZJ1C91UC_hg/<module>/google`; confirm it matches the Instructions tab. Commit and push.

Optional: set up **module testing** on each module. A PR targeting `main` then runs the `examples/basic` integration test.

### 5. Variable Set (shared values)

Account Settings > IaCM Settings > Variable Sets > create `gcp-showcase-defaults`:

- Terraform variable `project_id` = `customer-success-244100`
- Terraform variable `owner` = your name in lowercase
- Terraform variable `cost_center` = `demo`

Keep the GCP connector on the workspace itself. A workspace can have only one connector per provider type.

### 6. Workspace template (optional, shows standardization)

Create a workspace template with provisioner Terraform 1.5.7, the GitHub repo, folder path `infra`, cost estimation enabled, and the GCP connector. Template values have the highest variable precedence, and template connectors are locked in workspaces.

### 7. Workspaces

Create two workspaces (from the template if you made one). Both use Terraform **1.5.7**, the GitHub repo, branch `main`, folder path `infra`, the GCP connector, **Cloud Cost Estimation on**, and the `gcp-showcase-defaults` Variable Set.

| | `showcase_dev` | `showcase_prod` |
|---|---|---|
| Terraform variable `environment` | `dev` | `prod` |
| Terraform variable `machine_type` | (none, HCL default `e2-micro`) | `e2-small` (shows workspace beats HCL default) |
| Variable file (Git) | `infra/env/dev.tfvars` | `infra/env/prod.tfvars` |

The workspace identifiers must be exactly `showcase_dev` and `showcase_prod`, because the pipelines and output expressions reference them.

### 8. OPA policies

Project Settings > Policies:

1. Create one policy per file in `policies/`.
2. Create a policy set `iacm-showcase-plan-guardrails` with **Entity type: Terraform Plan**, **Event: After Terraform Plan**, add all three policies with severity **Error and exit**.
3. Optional: add the built-in library policy **Terraform Plan Cost – Total Cost Estimate** in a second policy set (Entity type: Terraform Plan Cost).

Plan policy sets run automatically on every plan. They do not appear in the plan step's policy dropdown. That is expected.

### 9. Pipelines and triggers

1. In org `testprameet`, project `testproj`, paste each file in `pipelines/` into a new pipeline's YAML editor. If the editor flags a field, generate the same stage from the UI (Infrastructure stage > Provision / Pull Request / Detect Drift / Destroy operation) and compare.
2. Create the triggers from `triggers/*.yaml` (replace `<GITHUB_CONNECTOR_ID>`).
3. Project Settings > IaCM Settings > **Default Pipelines**: set Plan = `iacm-showcase-pr-plan`, Provision = `iacm-showcase-provision`, Drift = `iacm-showcase-drift`, Destroy = `iacm-showcase-destroy`. The workspace action buttons then use them.

---

## Demo script (what to show, in order)

1. **Module Registry**: open `gcp-network`. Show the Readme, Inputs, Outputs, Dependencies, Resources and Examples tabs, all parsed from the module files.
2. **Provision**: run `iacm-showcase-provision`.
   - Dev stage: Queue serializes runs on the workspace. Plan shows cost estimation and OPA results. The approval auto-approves only if the plan has no changes, so the first run still waits for you. Apply runs, then `show-outputs` prints `<+workspace.showcase_dev.*>` output parameters.
   - Prod stage: manual approval is always required, and the plan shows `e2-small`, which proves variable precedence.
3. **Workspace tabs**: Resources (resources, data sources, outputs), State (versioned history), Activity history with cost change.
4. **OPA block**: set `machine_type = e2-standard-4` on `showcase_dev`, run the PR plan or provision pipeline, and watch the plan step fail with the policy message. Remove the variable.
5. **PR automation**: open a PR that changes something under `infra/` (for example `bucket_delete_after_days = 14`). The trigger runs `iacm-showcase-pr-plan` and the plan is posted as a PR comment.
6. **Drift**: in the GCP console, edit a label on the dev bucket. Run `iacm-showcase-drift` with workspace `showcase_dev`. The pipeline fails and the bucket is flagged in the Resources tab. Re-run provision to put it back. The cron trigger checks prod every 6 hours.
7. **Import**: follow the steps in `infra/imports.tf.example`. The plan shows "1 to import".
8. **Module upgrade**: change the bucket module, push tag `gcp-bucket-v1.1.0`. Auto-sync onboards the new version. Bump `version` in `infra/main.tf` via a PR to show the plan diff.
9. **Destroy**: run `iacm-showcase-destroy` for `showcase_prod`, then `showcase_dev`. Review the plan-destroy before approving.

## Known gotchas

- PR plan comments are not posted for public repositories unless you add the workspace environment variable `HARNESS_PASSWORD_API` with a GitHub token secret.
- Approval steps keep the build machine running until resolved. Max timeout is 60 minutes.
- Drift detection runs a refresh-only plan, so it can report more changes than a normal plan (for example label metadata).
- For a Kubernetes build infrastructure instead of Harness Cloud, change each stage's `runtime` to your cluster. The plugin downloads Terraform, providers and modules at runtime, so the cluster needs egress or custom images.
