# Environment Promotion Model

## Branch Flow

- Feature branches: run validate, security, and plan checks.
- Pull request into `main`: plan summaries posted per environment.
- Merge to `main`: eligible for deployment workflows.

## Promotion Path

1. Apply to `dev`.
2. Validate smoke checks and functional verification.
3. Apply to `staging` with manual approval gate.
4. Apply to `prod` with manual approval gate and protected environment rules.

## Controls

- GitHub environments: `dev`, `staging`, `prod`.
- Required reviewers for `staging` and `prod`.
- Concurrency group by environment to prevent overlapping applies.

## Rollback Approach

- Revert change in code, then apply forward.
- If needed, restore previous state object version as controlled break-glass only.
