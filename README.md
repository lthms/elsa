# `elsa`

Terraform-managed k3s cluster on Vultr with observability and
coordinated upgrades.

## Prerequisites

- `terraform`
- `yq`
- `butane`
- `mustache`
- `vendir`

Tools are managed by [mise](https://mise.jdx.dev); run `mise install`
to set them up.

## Usage

| Target | Description |
| --- | --- |
| `make deploy` | Apply the Terraform configuration |
| `make plan` | Preview infrastructure changes |
| `make destroy` | Tear down all infrastructure |
| `make kubeconfig` | Generate a local kubeconfig for the cluster |
| `make setup` | Configure local git hooks |
| `make readme` | Regenerate README.md from its template |

## Configuration

Variables are defined in `variables.tf` and supplied via a
`main.tfvars` file.

### Required

| Variable | Description |
| --- | --- |
| `region` | Region to deploy this stack |
| `vultr_api_key` | API key used to configure the provider |
| `betterstack_source_token` | Source token for Betterstack ingestion |
| `betterstack_ingesting_host` | Host endpoint for Betterstack log ingestion |
| `k3s_token` | Token for k3s agents to join the cluster |
| `betterstack_api_token` | API token for Betterstack Uptime provider |
| `ssh_authorized_key` | SSH public key for the core user |
| `status_page_company_name` | Company name shown on the Betterstack status page |
| `status_page_company_url` | Company URL shown on the Betterstack status page |
| `status_page_subdomain` | Subdomain for the Betterstack status page |
| `status_page_timezone` | Timezone for the Betterstack status page |
| `acme_email` | Email address for Let&#39;s Encrypt ACME registration |

### Optional

| Variable | Description | Default |
| --- | --- | --- |
| `control_plane_plan` | Vultr instance plan for the control plane node | `vc2-1c-2gb` |
| `agent_plan` | Vultr instance plan for agent nodes | `vc2-1c-2gb` |
| `control_plane_storage_gb` | Block storage size in GB for the control plane | `10` |
| `agent_count` | Number of k3s agent nodes to deploy | `0` |
| `control_plane_vpc_ip` | Static VPC IP for the control plane node | `10.0.0.3` |
