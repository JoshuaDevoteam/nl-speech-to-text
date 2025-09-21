# Cloud VPN Route-based Module

## Example

```hcl
module "addresses" {
  source     = "./fabric/modules/net-address"
  project_id = var.project_id
  external_addresses = {
    vpn = "europe-west1"
  }
}

module "vpn" {
  source          = "./fabric/modules/net-vpn-static"
  project_id      = var.project_id
  region          = var.region
  network         = var.vpc.self_link
  name            = "remote"
  gateway_address_create = false
  gateway_address        = module.addresses.external_addresses["vpn"].address
  remote_ranges   = ["10.10.0.0/24"]
  tunnels = {
    remote-0 = {
      ike_version       = 2
      peer_ip           = "1.1.1.1"
      shared_secret     = "mysecret"
      traffic_selectors = { local = ["0.0.0.0/0"], remote = ["0.0.0.0/0"] }
    }
  }
}
# tftest modules=2 resources=8
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.49 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.49 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.18.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.esp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.udp-4500](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.udp-500](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_route.route](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_vpn_gateway.gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_gateway) | resource |
| [google_compute_vpn_tunnel.tunnels](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel) | resource |
| [random_id.secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gateway_address"></a> [gateway\_address](#input\_gateway\_address) | Optional address assigned to the VPN gateway. Ignored unless gateway\_address\_create is set to false. | `string` | `""` | no |
| <a name="input_gateway_address_create"></a> [gateway\_address\_create](#input\_gateway\_address\_create) | Create external address assigned to the VPN gateway. Needs to be explicitly set to false to use address in gateway\_address variable. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | VPN gateway name, and prefix used for dependent resources. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | VPC used for the gateway and routes. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project where resources will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region used for resources. | `string` | n/a | yes |
| <a name="input_remote_ranges"></a> [remote\_ranges](#input\_remote\_ranges) | Remote IP CIDR ranges. | `list(string)` | `[]` | no |
| <a name="input_route_priority"></a> [route\_priority](#input\_route\_priority) | Route priority, defaults to 1000. | `number` | `1000` | no |
| <a name="input_tunnels"></a> [tunnels](#input\_tunnels) | VPN tunnel configurations. | <pre>map(object({<br>    ike_version   = number<br>    peer_ip       = string<br>    shared_secret = string<br>    traffic_selectors = object({<br>      local  = list(string)<br>      remote = list(string)<br>    })<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | VPN gateway address. |
| <a name="output_gateway"></a> [gateway](#output\_gateway) | VPN gateway resource. |
| <a name="output_name"></a> [name](#output\_name) | VPN gateway name. |
| <a name="output_random_secret"></a> [random\_secret](#output\_random\_secret) | Generated secret. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | VPN gateway self link. |
| <a name="output_tunnel_names"></a> [tunnel\_names](#output\_tunnel\_names) | VPN tunnel names. |
| <a name="output_tunnel_self_links"></a> [tunnel\_self\_links](#output\_tunnel\_self\_links) | VPN tunnel self links. |
| <a name="output_tunnels"></a> [tunnels](#output\_tunnels) | VPN tunnel resources. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
