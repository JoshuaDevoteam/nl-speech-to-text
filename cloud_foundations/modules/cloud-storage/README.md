# Cloud Storage factory

This module creates a Cloud Storage Bucket. Below you will find an example of proper usage.

Note that you may require both `bucket_location` and `storage_class` to define the availability of a given Bucket. For example, if you want a MULTI_REGIONAL  and COLDLINE bucket, you might be tempted to set `bucket_storage_class=["COLDLINE", "MULTI_REGIONAL"]`  since the available options for `bucket_location` are STANDARD,
MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, and ARCHIVE. However, the correct usage in such a case would be to set the storage class to `bucket_storage_class = "COLDLINE"` and to set the location to a multi-region like `bucket_location = "EU"`. Here's a complete list of [locations](https://cloud.google.com/storage/docs/locations) for regions, dual-regions, and multi-regions.

## Example

```terraform
module "bucket" {
  source = ""
  project_id    = "your-project-id-here"
  bucket_name   = "your-bucket-name-here"
  bucket_location = "EUROPE-WEST4"
  bucket_storage_class = "STANDARD"
  bucket_force_destroy        = false
  bucket_uniform_level_access = true
  iam_binding_role_group_map = {
    "roles/bucket.role.here" = ["serviceAccount:email1@domain.com","group:email2@domain.com"]
  }
  bucket_labels = {
    "label key" = "label value"
  }
  bucket_lifecycle_rules = [
    {
      condition = {
        age = 3
      }
      action = {
        type = "Delete"
      }
    }
  ]
}
```

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_bucket_force_destroy"></a> [bucket\_force\_destroy](#input\_bucket\_force\_destroy) | If set to true, when a bucket is deleted all contained objects are also deleted. If set to false, any bucket with objects inside will not be deleted. | `bool` | `false` | no |
| <a name="input_bucket_labels"></a> [bucket\_labels](#input\_bucket\_labels) | (Optional) A label is a key-value pair in the form of a map that helps you organize your Google Cloud resources. | `map(string)` | `{}` | no |
| <a name="input_bucket_lifecycle_rules"></a> [bucket\_lifecycle\_rules](#input\_bucket\_lifecycle\_rules) | action:<br>  type: The type of action taken by the Lifecycle Rule. Possible values are: Delete and SetStorageClass.<br>  storage\_class: (Required only for action type SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.<br>condition:<br>  age: (Optional) Minimum age in days.<br>  created\_before: (Optional) Object creation date in YYYY-MM-DD (a.k.a RFC 3339).<br>  with\_state: (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".<br>  matches\_storage\_class: (Optional) Storage Class of objects to match on. Possible values: MULTI\_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE\_REDUCED\_AVAILABILITY.<br>  num\_newer\_versions: (Optional) Only for versioned objects; The total number of newer versions of an object to trigger the condition. | <pre>list(object({<br>    action    = any<br>    condition = any<br>  }))</pre> | `[]` | no |
| <a name="input_bucket_location"></a> [bucket\_location](#input\_bucket\_location) | Location of the bucket created by this terraform module. You can select a region, dual-region, or multi-region. | `string` | n/a | yes |
| <a name="input_bucket_object_versioning"></a> [bucket\_object\_versioning](#input\_bucket\_object\_versioning) | When set to true, objects versioning is enabled for this bucket. | `bool` | `true` | no |
| <a name="input_bucket_storage_class"></a> [bucket\_storage\_class](#input\_bucket\_storage\_class) | Storage class of the bucket created by this terraform module. | `string` | `"STANDARD"` | no |
| <a name="input_bucket_uniform_level_access"></a> [bucket\_uniform\_level\_access](#input\_bucket\_uniform\_level\_access) | Cloud Storage offers two systems for granting users permission to access your buckets and objects: IAM and Access Control Lists (ACLs). Enabling Uniform bucket-level access allows you to administer buckets using IAM. | `bool` | `true` | no |
| <a name="input_cloud_function_available_memory_mb"></a> [cloud\_function\_available\_memory\_mb](#input\_cloud\_function\_available\_memory\_mb) | (Optional) Memory (in MB), available to the function. Default value is 256. Possible values include 128, 256, 512, 1024, etc. | `number` | `256` | no |
| <a name="input_cloud_function_description"></a> [cloud\_function\_description](#input\_cloud\_function\_description) | (Optional) Description of the function. | `string` | `null` | no |
| <a name="input_cloud_function_entry_point"></a> [cloud\_function\_entry\_point](#input\_cloud\_function\_entry\_point) | (Optional) Name of the function that will be executed when the Google Cloud Function is triggered. | `string` | `null` | no |
| <a name="input_cloud_function_event_type"></a> [cloud\_function\_event\_type](#input\_cloud\_function\_event\_type) | (Required) The type of event to observe. | `string` | `"google.storage.object.finalize"` | no |
| <a name="input_cloud_function_failure_policy_retry"></a> [cloud\_function\_failure\_policy\_retry](#input\_cloud\_function\_failure\_policy\_retry) | (Required) Whether the function should be retried on failure. Defaults to false. | `bool` | `false` | no |
| <a name="input_cloud_function_labels"></a> [cloud\_function\_labels](#input\_cloud\_function\_labels) | (Optional) A label is a key-value pair in the form of a map that helps you organize your Google Cloud resources. | `map(string)` | `{}` | no |
| <a name="input_cloud_function_name"></a> [cloud\_function\_name](#input\_cloud\_function\_name) | (Required) A user-defined name of the function. Function names must be unique globally. | `string` | `null` | no |
| <a name="input_cloud_function_resource"></a> [cloud\_function\_resource](#input\_cloud\_function\_resource) | (Required) Required. The name or partial URI of the resource from which to observe events. | `string` | `null` | no |
| <a name="input_cloud_function_runtime"></a> [cloud\_function\_runtime](#input\_cloud\_function\_runtime) | (Required) The runtime in which the function is going to run. Eg. nodejs10, nodejs12, nodejs14, python37, python38, python39, dotnet3, go113, java11, ruby27, etc. Check the official doc for the up-to-date list. | `string` | `null` | no |
| <a name="input_cloud_function_source_repository_url"></a> [cloud\_function\_source\_repository\_url](#input\_cloud\_function\_source\_repository\_url) | (Optional) Represents the URL pointing to a source repository where a function is hosted. | `string` | `null` | no |
| <a name="input_cloud_function_source_type"></a> [cloud\_function\_source\_type](#input\_cloud\_function\_source\_type) | (Required) Says whether the cloud function will take source code from a bucket or a repository. | `string` | `"REPOSITORY"` | no |
| <a name="input_cloud_function_timeout"></a> [cloud\_function\_timeout](#input\_cloud\_function\_timeout) | (Optional) Timeout (in seconds) for the function. Default value is 60 seconds. Cannot be more than 540 seconds. | `number` | `60` | no |
| <a name="input_cloud_function_trigger_type"></a> [cloud\_function\_trigger\_type](#input\_cloud\_function\_trigger\_type) | (Required) The type of event to observe. | `string` | `"EVENT"` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_cors"></a> [cors](#input\_cors) | (Optional) CORS configuration for the bucket if it is used to host a static website. | <pre>object({<br>    origin          = list(string)<br>    method          = list(string)<br>    response_header = list(string)<br>    max_age_seconds = number<br>  })</pre> | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | (Optional) A set of key/value environment variable pairs to assign to the function. | `map(string)` | `{}` | no |
| <a name="input_iam_binding_role_group_map"></a> [iam\_binding\_role\_group\_map](#input\_iam\_binding\_role\_group\_map) | A map with each role as key and lists of members or groups as values. | `map(list(string))` | `{}` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the project. | `string` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | (Optional) If provided, the self-provided service account to run the function with | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_website"></a> [website](#input\_website) | (Optional) Website configuration for the bucket if it is used to host a static website. | <pre>object({<br>    main_page_suffix = string<br>    not_found_page   = string<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The GCS bucket's ID. |
| <a name="output_bucket_url"></a> [bucket\_url](#output\_bucket\_url) | The GCS bucket's URL |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Test
# TODO: check the tests
There are 2 tests for this module, which test the creation of storage and a storage-triggered cloud function. Note that each test has its own directory and test file inside `tests/` directory, and the value of declared variables are defined in a `terraform.tfvars` file in side these directories. Run `go test` in the `tests` directory.

Note that the cloud function uses source code on Source Repository, which normally has the structure like `https://source.developers.google.com/projects/<project-name>/repos/<repo-name>/moveable-aliases/master/paths/`
