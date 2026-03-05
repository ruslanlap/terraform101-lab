# terraform-lab
This is a repository for my Terraform practice
# terraform-101-lab

<!-- budget:start -->
## Potential Budget (ec2-assignment-2)

Estimated monthly cost in `eu-central-1` for the current setup:

| Metric | Value |
| --- | ---: |
| **Estimated total (hourly)** | **0.016400 USD / hour** |
| **Estimated total (daily)** | **0.3936 USD / day** |
| **Estimated total (monthly)** | **11.972 USD / month** |
| Budget cap | 20 USD / month |
| Last updated | 2026-03-05 15:42 UTC |

### Service breakdown

| Service | Hourly (USD) | Daily (USD) | Monthly (USD) |
| --- | ---: | ---: | ---: |
| `aws_instance` | 0.015030 | 0.3607 | 10.972 |
| `aws_kms_key` | 0.001370 | 0.0329 | 1.000 |
| `aws_cloudwatch_log_group` | 0.000000 | 0.0000 | 0.000 |

Notes:
- Generated automatically by `.github/workflows/budget.yaml` using Infracost.
- Estimate excludes outbound data transfer spikes, snapshots, and additional resources.

<!-- budget:end -->
