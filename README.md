# dora-infrastructure

Terraform infrastructure-as-code for the DORA Incident Management platform on AWS.

## Future role

This repo will contain **Terraform modules** for all AWS resources: ECS Fargate (API), RDS PostgreSQL Multi-AZ, S3, SES, Cognito, and the supporting network/IAM layer. It is populated in LLD-16 as part of the cloud migration.

Until LLD-16, this repo contains no runnable code.

## Quickstart

No runnable code yet — see the linked LLD.

## Planned module structure

```
dora-infrastructure/
├── envs/
│   ├── dev/
│   ├── uat/
│   └── prod/
└── modules/
    ├── network/
    ├── ecs/
    ├── rds/
    ├── s3/
    ├── secrets/
    └── cicd/
```

## Roadmap

| LLD | Change |
|---|---|
| LLD-16 | Full Terraform scaffold: ECS, RDS, S3, SES, Cognito, GitHub OIDC |

## Relevant LLDs

- [LLD-01 — Local Dev Baseline](../dora-docs/low-level-design/LLD-01-local-dev-baseline.md)
- LLD-16 — AWS Migration (not yet written)
