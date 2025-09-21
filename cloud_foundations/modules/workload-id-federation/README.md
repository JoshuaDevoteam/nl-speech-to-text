# Google Cloud Workload identity federation module

With identity federation, you can use Identity and Access Management (IAM) to grant external identities IAM roles,
including the ability to impersonate service accounts. This approach eliminates the maintenance and security burden
associated with service account keys.

[Google documentation](https://cloud.google.com/iam/docs/workload-identity-federation)

# Usage

This can be used to set up IAM authentication to a service without providing it with a Service Account key. Some
external services, like Terraform Cloud, do this by impersonating a service account (achieved by giving the principal(
set) workload identity user on the service account), others, like GitHub Actions, can be assigned IAM permissions
directly on their principal(set). Not all APIs in Google Cloud support IAM through principal(set) however, so they might
need to still impersonate a service account.

The attribute mappings and issuer ID are specific to the service you're trying to authenticate.

After creating the workload identity pool and provider(s), you can assign permissions using a principal, e.g.
`principal://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/subject/SUBJECT_ATTRIBUTE_VALUE`
or a principalSet, e.g.
`principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/attribute.ATTRIBUTE_NAME/ATTRIBUTE_VALUE`

If a service account has to be impersonated, give the workload identity pool the Workload Identity User role on the
service account.

Some setup is needed on the service side as well. Two examples are given.

GitHub Actions using [auth](https://github.com/google-github-actions/auth), where you add

```yaml
jobs:
  job_id:
    # Add "id-token" with the intended permissions.
    permissions:
      contents: 'read'
      id-token: 'write'

    steps:
      - uses: 'actions/checkout@v4'

      - uses: 'google-github-actions/auth@v2'
        with:
          project_id: 'my-project'
          workload_identity_provider: 'projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider'
```

to authenticate.

On Terraform Cloud you would add the following environment variables to the workspace:

- TFC_GCP_PROVIDER_AUTH = true
- TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL = < name of the SA to impersonate >
- TFC_GCP_WORKLOAD_PROVIDER_NAME = < the workload provider name, like
  projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider >

## Terraform usage

Example module call for setting up with Terraform Cloud:

```
module "workload_identity" {
    display_name     = "Test TFC pool"
    name             = "tfc"
    environment      = "tst"
    description      = "A workload identity pool for Terraform Cloud"
    workload_enabled = true
    project_id       = "pj-tst-tf-master"
    workload_providers = {
      tfc = {
        attribute_mapping = {
          "google.subject"                        = "assertion.sub",
          "attribute.terraform_organization_id"   = "assertion.terraform_organization_id",
          "attribute.terraform_organization_name" = "assertion.terraform_organization_name",
          "attribute.terraform_project_id"        = "assertion.terraform_project_id",
          "attribute.terraform_project_name"      = "assertion.terraform_project_name",
          "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id",
          "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name",
          "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace",
          "attribute.terraform_run_id"            = "assertion.terraform_run_id",
          "attribute.terraform_run_phase"         = "assertion.terraform_run_phase",
        }
        attribute_condition = "attribute.terraform_organization_id=='org-xxxxxxxxxxxxxxxx'"
        oidc = {
          issuer_uri = "https://app.terraform.io"
        }
      }
    }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.18.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pool_label"></a> [pool\_label](#module\_pool\_label) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_provider_labels"></a> [provider\_labels](#module\_provider\_labels) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |

## Resources

| Name | Type |
|------|------|
| [google_iam_workload_identity_pool.pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.providers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_secret_manager_secret_version.idp_metadata_xml](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | The description for the Workload pool | `string` | `""` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The display name for the Workload pool | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID for this Workload pool | `string` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_workload_enabled"></a> [workload\_enabled](#input\_workload\_enabled) | Whether the Workload pool is enabled | `bool` | `true` | no |
| <a name="input_workload_providers"></a> [workload\_providers](#input\_workload\_providers) | n/a | <pre>map(object({<br>    display_name        = optional(string)<br>    description         = optional(string)<br>    enabled             = optional(bool, true)<br>    attribute_mapping   = optional(map(string))<br>    attribute_condition = optional(string)<br>    aws_account_id      = optional(string)<br>    oidc = optional(object({<br>      allowed_audiences = optional(list(string))<br>      issuer_uri        = string<br>      jwks_json         = optional(string)<br>    }))<br>    saml = optional(object({<br>      secret_project = string<br>      secret         = string<br>      secret_version = string<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workload_pool_name"></a> [workload\_pool\_name](#output\_workload\_pool\_name) | The name of the Workload Identity pool with format projects/{project\_number}/locations/global/workloadIdentityPools/{workload\_identity\_pool\_id} |
| <a name="output_workload_pool_state"></a> [workload\_pool\_state](#output\_workload\_pool\_state) | The state of the Workload Identity pool |
| <a name="output_workload_provider_names"></a> [workload\_provider\_names](#output\_workload\_provider\_names) | A map of all Workload Identity provider names with format projects/{project\_number}/locations/global/workloadIdentityPools/{workload\_identity\_pool\_id}/providers/{workload\_identity\_pool\_provider\_id} |
| <a name="output_workload_provider_states"></a> [workload\_provider\_states](#output\_workload\_provider\_states) | A map of all Workload Identity provider states |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
