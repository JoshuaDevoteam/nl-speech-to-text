# Intro
Create projects in a Google Cloud Organization under a specific folder.

## Limitations & Design choices
- Skips the default VPC creation.

- Only allows creation under a folder, not under organization

- Uses null-label module to enforce naming conventions

- We currently skip `checkov:skip=CKV2_GCP_5` *"Ensure that Cloud Audit Logging is configured properly across all services and all users from a project"*

- Label keys and values need to be lowercase. This is enforced in the null-label context of this module. More info
  about label requirements in the
  [Google documentation](https://cloud.google.com/resource-manager/docs/creating-managing-labels#requirements).

- The project id can have a maximum of 30 characters. This is enforced in the null-label context of this module. More
  [info](https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin).

## Basic usage
### Usage
```hcl
module "projects" {
  source = ""
  projects = {
    "basic-project-1" = {
      name = "basic-project-1"
    }
  }
  parent_folder   = "217736990038"
  billing_account = "017723-A83AC2-D5500F"
}
```
By default, the null-label module will use the prefix `pj`, resulting in project name `pj-basic-project-1`.

```hcl
  # module.projects.google_project.project["basic-project-1"] will be created
  + resource "google_project" "project" {
    + auto_create_network = false
    + billing_account     = "017723-A83AC2-D5500F"
    + effective_labels    = {
      + "name"      = "pj-basic-project-1"
      + "namespace" = "pj"
    }
    + folder_id           = "217736990038"
    + id                  = (known after apply)
    + labels              = {
      + "name"      = "pj-basic-project-1"
      + "namespace" = "pj"
    }
    + name                = "pj-basic-project-1"
    + number              = (known after apply)
    + project_id          = "pj-basic-project-1"
    + skip_delete         = (known after apply)
    + terraform_labels    = {
      + "name"      = "pj-basic-project-1"
      + "namespace" = "pj"
    }
  }
```

## Advanced usage
### Usage
```hcl
module "projects" {
  source = ""
  projects = {
    "advanced-project-1" = {
      name = "advanced-project-1"
      labels = {
        team = "team1"
      }
    }
    "advanced-project-2" = {
      name = "advanced-project-2"
      labels = {
        team = "team2"
      }
    }
  }
  labels = {
    department = "ml"
  }
  parent_folder   = "217736990038"
  billing_account = "017723-A83AC2-D5500F"
  environment     = "eu"
  stage           = "dev"
  label_order     = ["environment", "stage", "name"]
  labels_as_tags  = ["environment", "stage"]
}
```

By setting the label_order to not include `namespace`, the default `pj` prefix is not used and the resulting projects will
be named `eu-dev-advanced-project-1` and `eu-dev-advanced-project-2`.

By setting the labels_as_tags we can dictate which null label inputs are converted into labels on the project.

We can use the labels within a project or on the whole module to define additional labels. If a label on the project has
the same key as a general label, the project label will overwrite the general label for that project.

```hcl
  # module.projects.google_project.project["advanced-project-1"] will be created
  + resource "google_project" "project" {
    + auto_create_network = false
    + billing_account     = "017723-A83AC2-D5500F"
    + effective_labels    = {
      + "department"  = "ml"
      + "environment" = "eu"
      + "stage"       = "dev"
      + "team"        = "team1"
    }
    + folder_id           = "217736990038"
    + id                  = (known after apply)
    + labels              = {
      + "department"  = "ml"
      + "environment" = "eu"
      + "stage"       = "dev"
      + "team"        = "team1"
    }
    + name                = "eu-dev-advanced-project-1"
    + number              = (known after apply)
    + project_id          = "eu-dev-advanced-project-1"
    + skip_delete         = (known after apply)
    + terraform_labels    = {
      + "department"  = "ml"
      + "environment" = "eu"
      + "stage"       = "dev"
      + "team"        = "team1"
    }
  }

  # module.projects.google_project.project["advanced-project-2"] will be created
  + resource "google_project" "project" {
    + auto_create_network = false
    + billing_account     = "017723-A83AC2-D5500F"
    + effective_labels    = {
      + "department"  = "ml"
      + "environment" = "eu"
      + "stage"       = "dev"
      + "team"        = "team2"
    }
    + folder_id           = "217736990038"
    + id                  = (known after apply)
    + labels              = {
      + "department"  = "ml"
      + "environment" = "eu"
      + "stage"       = "dev"
      + "team"        = "team2"
    }
    + name                = "eu-dev-advanced-project-2"
    + number              = (known after apply)
    + project_id          = "eu-dev-advanced-project-2"
    + skip_delete         = (known after apply)
    + terraform_labels    = {
      + "department"  = "ml"
      + "environment" = "eu"
      + "stage"       = "dev"
      + "team"        = "team2"
    }
  }
```

# Terraform generated docs

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
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | The billing account the project will be linked to | `string` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A set of key/value label pairs to assign to all projects in this module. | `map(string)` | `{}` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_parent_folder"></a> [parent\_folder](#input\_parent\_folder) | The numeric ID of the folder this project should be created under, without folder/ prefix | `string` | `null` | no |
| <a name="input_projects"></a> [projects](#input\_projects) | The projects to create directly under this folder.<br>    Specifying project\_id can be used to preserve project IDs from imported projects. If not, it should not be used<br>    and name (or the key of the project) will be used to generate the ID instead.<br>    Labels for the project can be specified here. If the key matches one of the labels set on project level, it will<br>    be overwritten by this value. | <pre>map(object({<br>    project_id  = optional(string)<br>    name        = optional(string)<br>    namespace   = optional(string, "pj")<br>    tenant      = optional(string)<br>    environment = optional(string)<br>    stage       = optional(string)<br>    labels      = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_objects"></a> [project\_objects](#output\_project\_objects) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
