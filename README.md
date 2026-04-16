# AWS Multi-Environment IaC Platform

Terraform modules + Terragrunt orchestration for `dev`, `staging`, and `prod`.

This guide is intentionally practical and step-by-step.

## What this repository contains

- Reusable Terraform modules:
  - `modules/networking`
  - `modules/compute`
  - `modules/databases`
- Environment stacks:
  - `live/dev`
  - `live/staging`
  - `live/prod`
- Shared Terragrunt root configuration:
  - `live/root.hcl`
- Bootstrap stack for remote state:
  - `bootstrap`
- CI workflows:
  - `.github/workflows/iac-validate-plan.yml`
  - `.github/workflows/iac-apply.yml`
  - `.github/workflows/iac-drift-detection.yml`
  - `.github/workflows/_terragrunt-run.yml` (shared runner)

## Prerequisites

- Terraform `>= 1.6`
- Terragrunt `>= 0.67`
- AWS CLI configured with valid credentials
- GitHub Actions enabled for your repository

Optional local tooling:
- `tfsec`

---

## Full implementation guide

### 1) Configure bootstrap variables

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
```

Edit `bootstrap/terraform.tfvars`:

```hcl
state_bucket_name = "your-unique-tfstate-bucket-name"
lock_table_name   = "tfstate-locks"
aws_region        = "eu-central-1"
project_name      = "multi-iac"
```

### 2) Create remote state infrastructure (run once)

```bash
cd bootstrap
terraform init
terraform plan -out bootstrap.plan
terraform apply bootstrap.plan
```

### 3) Configure shared Terragrunt root

Edit `live/root.hcl`:

- Set the S3 `bucket` value to your real state bucket name.
- Ensure `aws_region` matches your target region.

### 4) Configure environment values

Check each environment file:

- `live/dev/env.hcl`
- `live/staging/env.hcl`
- `live/prod/env.hcl`

Validate:

- `availability_zones` match the region in `live/root.hcl`
- `ami_id = ""` to auto-resolve latest Amazon Linux 2023 AMI from SSM (or set a pinned AMI if needed)
- CIDR ranges are correct and non-overlapping

### 5) Set DB password (required before apply)

```bash
export TF_VAR_db_password='use-a-long-random-secret'
```

Generate one automatically if missing:

```bash
export TF_VAR_db_password="${TF_VAR_db_password:-$(openssl rand -base64 32)}"
```

### 6) Optional formatting checks

```bash
terraform fmt -recursive
terragrunt hcl fmt
```

### 7) Initialize and plan

Dev:

```bash
cd live/dev
terragrunt run --all init --working-dir .
terragrunt run --all plan --working-dir .
```

Staging:

```bash
cd live/staging
terragrunt run --all init --working-dir .
terragrunt run --all plan --working-dir .
```

Prod:

```bash
cd live/prod
terragrunt run --all init --working-dir .
terragrunt run --all plan --working-dir .
```

### 8) Apply safely (recommended order)

Promotion order:

1. `dev`
2. `staging`
3. `prod`

For a fresh environment, apply networking first so dependency outputs are real:

```bash
cd live/dev
export TF_VAR_db_password='use-a-long-random-secret'

cd networking
terragrunt apply
cd ..

terragrunt run --all plan --working-dir .
terragrunt run --all apply --working-dir .
```

Notes:

- Early `init/plan` warnings about mock dependency outputs are expected before first networking apply.
- If networking is already applied, full `run --all apply` can proceed directly.

---

## GitHub Actions setup

### 1) Create GitHub environments

Create these environments:

- `dev`
- `staging`
- `prod`

### 2) Add environment protections

- `staging`: add required reviewers.
- `prod`: add required reviewers and stricter protection rules.

### 3) Add required secrets

For each environment (`dev`, `staging`, `prod`), add:

- `TF_VAR_DB_PASSWORD`
- `AWS_ACCESS_KEY_ID``
- `AWS_SECRET_ACCESS_KEY`

Runtime mapping used by workflows:

- GitHub secret: `TF_VAR_DB_PASSWORD`,`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- Terraform runtime env var: `TF_VAR_db_password`

### 4) Understand workflow responsibilities

- `iac-validate-plan.yml`: runs formatting checks, `tfsec`, and plan for `dev`, `staging`, `prod`.
- `iac-apply.yml`: manual apply only (`workflow_dispatch`), with selected environment input.
- `iac-drift-detection.yml`: scheduled and manual drift plans for `dev`, `staging`, `prod`.
- `_terragrunt-run.yml`: shared reusable workflow used by all three workflows to install Terraform/Terragrunt, configure AWS auth, map secrets, and execute Terragrunt commands.

### 5) How environments are selected in CI

- `iac-apply.yml` passes selected input environment to `_terragrunt-run.yml` via `deployment_environment`.
- `iac-validate-plan.yml` and `iac-drift-detection.yml` use matrix environments and pass each one to `_terragrunt-run.yml`.
- Environment approvals/protections are enforced by the reusable workflow job (`environment: ${{ inputs.deployment_environment }}`).

### 6) Dependency output behavior in CI

- Plan/drift workflows enable `TG_SKIP_DEP_OUTPUTS` for CI stability before first full apply.
- Apply workflow keeps real dependency outputs (`skip_dep_outputs: false`).
- It is normal to see mock/skip dependency-output messaging in early plan logs.

### 7) First CI test checklist

- Trigger `iac-validate-plan.yml` on `dev` (PR or push to `main`).
- Confirm `TF_VAR_DB_PASSWORD` is mapped to `TF_VAR_db_password` and remains masked in logs.
- Confirm plan logs complete even when dependency outputs are not yet present.
- Run `iac-apply.yml` manually from Actions and choose `dev` to verify manual apply path.

---

## Secrets management

### Why two names?

- Terraform variable env format: `TF_VAR_db_password`
- GitHub secret naming used here: `TF_VAR_DB_PASSWORD`
- Workflow maps uppercase secret to Terraform env variable name

### Quick mapping reminder

- **Set in local terminal**: `TF_VAR_db_password`
- **Set in GitHub secrets UI**: `TF_VAR_DB_PASSWORD`
- **Execution flow**: GitHub secret -> workflow env mapping -> Terraform variable `db_password`

### Local safety rules

- Never commit secrets in `*.tf`, `*.tfvars`, `*.hcl`, scripts, or docs.
- Export `TF_VAR_db_password` in your shell before `plan/apply`.

### Rotation

1. Rotate secret in GitHub or AWS secret store.
2. Re-apply database stack for target env:

```bash
cd live/<env>/databases
terragrunt apply
```

3. Verify behavior with your RDS maintenance policy.

---

## Teardown (full removal)

Use this only when you want to destroy all managed infrastructure.

### 1) Destroy live stacks per environment

```bash
export TF_VAR_db_password='same-secret-used-for-apply'

cd live/dev
terragrunt run --all destroy --working-dir .

cd ../staging
terragrunt run --all destroy --working-dir .

cd ../prod
terragrunt run --all destroy --working-dir .
```

If dependency order fails, destroy manually:

1. `databases`
2. `compute`
3. `networking`

```bash
cd live/dev/databases && terragrunt destroy
cd ../compute && terragrunt destroy
cd ../networking && terragrunt destroy
```

### 2) Empty remote state bucket

Before bootstrap destroy, remove bucket contents (Bucket-Empty):

```bash
aws s3 rm s3://YOUR_STATE_BUCKET_NAME --recursive
```

If S3 versioning is enabled, also delete non-current versions.

### 3) Destroy bootstrap resources

```bash
cd bootstrap
terraform destroy
```

### 4) Optional final cleanup

- Rotate/remove GitHub secrets
- Disable/remove GitHub workflows if no longer needed
- Archive/delete local repository

---

## Repository layout

```text
.
├── bootstrap/
├── modules/
│   ├── networking/
│   ├── compute/
│   └── databases/
├── live/
│   ├── root.hcl
│   ├── dev/
│   ├── staging/
│   └── prod/
├── docs/
│   ├── state-strategy.md
│   ├── environment-promotion.md
│   └── governance-baseline.md
└── .github/workflows/
```

## Notes and next hardening steps

- `live/*/env.hcl` now uses `ami_id = ""` to auto-resolve the latest Amazon Linux 2023 AMI from AWS SSM; set an explicit `ami_id` only when you need a pinned image.
- For real applies, set `TF_VAR_db_password` explicitly (see [Managing secrets](#managing-secrets-tf_var_db_password)).
- Add NAT gateways, route table associations, and stricter SG rules for production-grade networking.
- Add OIDC role-assumption steps in workflows for keyless AWS auth.
