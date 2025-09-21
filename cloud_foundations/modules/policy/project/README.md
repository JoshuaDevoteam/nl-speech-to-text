# tf-gcp-modules-policy-project

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
| [google_project_organization_policy.project_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_organization_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boolean_policy"></a> [boolean\_policy](#input\_boolean\_policy) | n/a | `bool` | n/a | yes |
| <a name="input_constraint"></a> [constraint](#input\_constraint) | n/a | `string` | n/a | yes |
| <a name="input_list_policy"></a> [list\_policy](#input\_list\_policy) | n/a | `any` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_restore_policy"></a> [restore\_policy](#input\_restore\_policy) | n/a | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
