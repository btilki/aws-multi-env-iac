# Remote State Strategy (S3 + DynamoDB)

## Design

- Single S3 bucket for Terraform state: `REPLACE_WITH_STATE_BUCKET`
- DynamoDB lock table: `tfstate-locks`
- Per-environment keys are derived from Terragrunt relative path:
  - `dev/networking/terraform.tfstate`
  - `staging/compute/terraform.tfstate`
  - `prod/databases/terraform.tfstate`

## Security Controls

- S3 bucket encryption enabled (SSE-S3 AES256).
- S3 bucket versioning enabled.
- Public access fully blocked.
- DynamoDB table lock key: `LockID`.

## Naming Guidance

- Bucket: `<org>-<project>-tfstate-<region>-<account-id>` (globally unique).
- Lock table: `<project>-tfstate-locks`.
- Keep environment in key prefix, not in bucket name, unless strict account separation is required.

## Operations

- Bootstrap once from `bootstrap/`.
- Never delete old object versions in prod without a recovery policy.
- Use `terragrunt run-all state pull` for investigation, not manual object edits.
