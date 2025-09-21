# Terraform GCP Module

:warning: If using [this module](https://github.com/devoteamgcloud/tf-gcp-modules-artifact-registry) for artifact
registry IAM (or another way of doing in IAM in tandem with this), know that this module uses IAM policy, so will
overwrite any other IAM bindings on a per-registry basis. This is intended for cases when a centralised IAM management
of artifact registries is desired.

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
| [google_artifact_registry_repository_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_policy) | resource |
| [google_iam_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bindings"></a> [bindings](#input\_bindings) | Map of bindings, with the keys being the roles and the values lists withe the members for those roles. | `map(list(string))` | `{}` | no |
| <a name="input_conditional_bindings"></a> [conditional\_bindings](#input\_conditional\_bindings) | A map of objects, with the key as the title for the conditional binding, and as value the role, members, condition, and optionally a description. | <pre>map(object({<br>    title       = string<br>    role        = string<br>    members     = set(string)<br>    condition   = string<br>    description = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_repo_location"></a> [repo\_location](#input\_repo\_location) | The location the Artifact Registry repo resides in. | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Name of the Artifact Registry repo. | `string` | n/a | yes |
| <a name="input_repo_project_id"></a> [repo\_project\_id](#input\_repo\_project\_id) | Project id the Artifact Registry repo belongs to. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
