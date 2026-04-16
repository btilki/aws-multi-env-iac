# Governance and Security Baseline

## IAM and Access

- Prefer GitHub OIDC role assumption over long-lived access keys.
- Use separate deploy roles per environment with least privilege.
- Restrict `prod` role assumption to protected branch and approved workflows.

## Version Pinning

- Terraform pinned in workflows (`1.6.6`).
- Terragrunt pinned in workflows (`0.67.10`).
- AWS provider pinned in `versions.tf` (`~> 5.0`).

## Required Tags

Every resource should include:

- `Project`
- `Environment`
- `ManagedBy`
- `Owner`

## CI Policy Gates

- Required checks: validate, security, plan.
- Block merge when any stage fails.
- Enable drift detection workflow on schedule.

## Secret Management

- Keep sensitive values in GitHub environment secrets.
- Never commit database passwords or private keys.
