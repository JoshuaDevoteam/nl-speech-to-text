# tf-gcp-modules-iam-subnet

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.49 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.18.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_subnetwork_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_policy) | resource |
| [google_iam_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bindings"></a> [bindings](#input\_bindings) | n/a | `any` | n/a | yes |
| <a name="input_conditional_bindings"></a> [conditional\_bindings](#input\_conditional\_bindings) | A map of objects, with the key as the title for the conditional binding, and as value the role, members, condition, and optionally a description. | <pre>map(object({<br>    title       = string<br>    role        = string<br>    members     = set(string)<br>    condition   = string<br>    description = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of the subnet | `string` | n/a | yes |
| <a name="input_subnet_project_id"></a> [subnet\_project\_id](#input\_subnet\_project\_id) | Project id the subnet belongs to | `string` | n/a | yes |
| <a name="input_subnet_region"></a> [subnet\_region](#input\_subnet\_region) | Region the subnet belongs to | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
