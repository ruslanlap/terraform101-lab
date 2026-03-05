# terraform-lab
This is a repository for my Terraform practice
# terraform-101-lab

## Potential Budget (ec2-assignment-2)

Estimated monthly cost in `eu-central-1` for the current setup:

| Resource | Monthly estimate (USD) |
| --- | ---: |
| 1 x `t2.micro` (730 hours) | 9.75 |
| 10 GB gp3 root volume | 1.00 |
| 1 x public IPv4 address | 3.60 |
| **Estimated total** | **14.35** |

Recommended budget cap for CI checks: **20 USD / month**.

Notes:
- Estimate excludes outbound data transfer spikes, snapshots, and additional resources.
- Budget workflow uses Infracost and fails the CI run if estimate exceeds the configured cap.
