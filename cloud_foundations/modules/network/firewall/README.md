# Intro
Create Firewall rules in a Google Cloud project.

## Limitations & Design choices
- Uses null-label module to enforce naming conventions

# Usage
## Basic usage
```hcl
module firewall {
  source              = ""
  project             = "pj-nw-be-uat-3"
  network             = "nw-be-uat"
  #the allowed egress, based on target tag (sending) and destination IP (receiving)
  egress_allow_range  = {
    "ping-range" = {
      description = "allow to send ping requests to private IP range"
      protocols = {
        "icmp" = []
      }
      target_tags = []
      destination_ranges = ["10.0.0.0/8"]
    }
  }
  egress_deny_range = {
    "ping-range" = {
      description = "deny ping towards a more dedicated range"
      protocols = {
        "icmp" = []
      }
      target_tags = []
      destination_ranges = ["10.100.12.0/24"]
    }
  }
  #the allowed ingress, based on source tag (sending) and target tag (receiving)
  ingress_allow_tag = {
    "ssh-tag" = {
      description = "allow to get ssh requests from tags"
      protocols = {
        "tcp" = ["22"]
      }
      source_tags = ["ssh-sender"]
      target_tags = []
      #target_tags = ["ssh-receiver"]
    }
  }
  #the allowed ingress, based on source IP range (sending) and target tag (receiving)
  ingress_allow_range = {
    "ping-range" = {
      description = "allow to get ping requests from private IP range"
      protocols = {
        "icmp" = []
      }
      source_ranges = ["10.0.0.0/8"]
      target_tags = ["ping-receiver"]
    }
    "ssh-range" = {
      description = "allow to get ssh requests from private IP range"
      protocols = {
        "tcp" = ["22"]
      }
      source_ranges = ["10.0.0.0/8"]
      target_tags = ["ssh-receiver"]
    }
  }
}
```
By default, the null-label module will use the prefix `fw` with the `operation` (allow/deny) and `direction`
(ingress/egress) resulting in firewall name `fw-ssh-tag-allow-ing`.

```hcl
  # module.firewall.google_compute_firewall.egress_allow_range["ping-range"] will be created
+ resource "google_compute_firewall" "egress_allow_range" {
    + creation_timestamp = (known after apply)
    + description        = "allow to send ping requests to private IP range"
    + destination_ranges = [
    + "10.0.0.0/8",
    ]
    + direction          = "EGRESS"
    + enable_logging     = (known after apply)
    + id                 = (known after apply)
    + name               = "fw-ping-range-allow-egress"
    + network            = "nw-be-uat"
    + priority           = 1000
    + project            = "pj-nw-be-uat-3"
    + self_link          = (known after apply)

    + allow {
    + ports    = []
    + protocol = "icmp"
    }
}

# module.firewall.google_compute_firewall.egress_deny_range["ping-range"] will be created
+ resource "google_compute_firewall" "egress_deny_range" {
    + creation_timestamp = (known after apply)
    + description        = "deny ping towards a more dedicated range"
    + destination_ranges = [
    + "10.100.12.0/24",
    ]
    + direction          = "EGRESS"
    + enable_logging     = (known after apply)
    + id                 = (known after apply)
    + name               = "fw-ping-range-deny-egress"
    + network            = "nw-be-uat"
    + priority           = 1000
    + project            = "pj-nw-be-uat-3"
    + self_link          = (known after apply)

    + deny {
    + ports    = []
    + protocol = "icmp"
    }
}

# module.firewall.google_compute_firewall.ingress_allow_range["ping-range"] will be created
+ resource "google_compute_firewall" "ingress_allow_range" {
    + creation_timestamp = (known after apply)
    + description        = "allow to get ping requests from private IP range"
    + destination_ranges = (known after apply)
    + direction          = "INGRESS"
    + enable_logging     = (known after apply)
    + id                 = (known after apply)
    + name               = "fw-ping-range-allow-ing"
    + network            = "nw-be-uat"
    + priority           = 1000
    + project            = "pj-nw-be-uat-3"
    + self_link          = (known after apply)
    + source_ranges      = [
    + "10.0.0.0/8",
    ]
    + target_tags        = [
    + "ping-receiver",
    ]

    + allow {
    + ports    = []
    + protocol = "icmp"
    }
}

# module.firewall.google_compute_firewall.ingress_allow_range["ssh-range"] will be created
+ resource "google_compute_firewall" "ingress_allow_range" {
    + creation_timestamp = (known after apply)
    + description        = "allow to get ssh requests from private IP range"
    + destination_ranges = (known after apply)
    + direction          = "INGRESS"
    + enable_logging     = (known after apply)
    + id                 = (known after apply)
    + name               = "fw-ssh-range-allow-ing"
    + network            = "nw-be-uat"
    + priority           = 1000
    + project            = "pj-nw-be-uat-3"
    + self_link          = (known after apply)
    + source_ranges      = [
    + "10.0.0.0/8",
    ]
    + target_tags        = [
    + "ssh-receiver",
    ]

    + allow {
    + ports    = [
    + "22",
    ]
    + protocol = "tcp"
    }
}

# module.firewall.google_compute_firewall.ingress_allow_tag["ssh-tag"] will be created
+ resource "google_compute_firewall" "ingress_allow_tag" {
    + creation_timestamp = (known after apply)
    + description        = "allow to get ssh requests from tags"
    + destination_ranges = (known after apply)
    + direction          = "INGRESS"
    + enable_logging     = (known after apply)
    + id                 = (known after apply)
    + name               = "fw-ssh-tag-allow-ing"
    + network            = "nw-be-uat"
    + priority           = 1000
    + project            = "pj-nw-be-uat-3"
    + self_link          = (known after apply)
    + source_tags        = [
    + "ssh-sender",
    ]

    + allow {
    + ports    = [
    + "22",
    ]
    + protocol = "tcp"
    }
}
```

## Advanced usage

The `attributes` label is used in the module to specify the direction and operation.
These can be skipped or extended.

```hcl
module firewall {
  source              = ""
  project             = "pj-nw-be-uat-3"
  network             = "nw-be-uat"
  environment         = "cloud"
  stage               = "dev"
  #the allowed egress, based on target tag (sending) and destination IP (receiving)
  egress_allow_range  = {
    "ping-range" = {
      description         = "allow to send ping requests to private IP range"
      protocols           = {
        "icmp" = []
      }
      target_tags         = []
      destination_ranges  = ["10.0.0.0/8"]
      priority            = 99
    }
  }
  ingress_allow_tag   = {}
  ingress_allow_range = {}
  egress_deny_range   = {}
  label_order         = ["environment","stage","name"]
}
```
By setting the label_order to not include `namespace`, the default `fw` prefix is not used and the resulting firewall
rule will be named `cloud-dev-ping-range`.

```hcl
  # module.firewall.google_compute_firewall.egress_allow_range["ping-range"] will be created
  + resource "google_compute_firewall" "egress_allow_range" {
      + creation_timestamp = (known after apply)
      + description        = "allow to send ping requests to private IP range"
      + destination_ranges = [
          + "10.0.0.0/8",
        ]
      + direction          = "EGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "cloud-dev-ping-range"
      + network            = "nw-be-uat"
      + priority           = 99
      + project            = "pj-nw-be-uat-3"
      + self_link          = (known after apply)

      + allow {
          + ports    = []
          + protocol = "icmp"
        }
    }
```

# TODO
- See code level #TODO's.

# Terraform autogenerated docs

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
| <a name="module_labels_egress_allow"></a> [labels\_egress\_allow](#module\_labels\_egress\_allow) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_labels_egress_deny"></a> [labels\_egress\_deny](#module\_labels\_egress\_deny) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_labels_ingress_allow_range"></a> [labels\_ingress\_allow\_range](#module\_labels\_ingress\_allow\_range) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_labels_ingress_allow_tag"></a> [labels\_ingress\_allow\_tag](#module\_labels\_ingress\_allow\_tag) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.egress_allow_range](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.egress_deny_range](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ingress_allow_range](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ingress_allow_tag](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_default_logging_mode"></a> [default\_logging\_mode](#input\_default\_logging\_mode) | n/a | `string` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_egress_allow_range"></a> [egress\_allow\_range](#input\_egress\_allow\_range) | the allowed egress, based on target tag (sending) and destination IP (receiving) | <pre>map(object({<br>    description        = string<br>    protocols          = map(list(string))<br>    target_tags        = list(string)<br>    destination_ranges = list(string)<br>    priority           = optional(number)<br>    logging_mode       = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_egress_deny_range"></a> [egress\_deny\_range](#input\_egress\_deny\_range) | n/a | <pre>map(object({<br>    description        = string<br>    protocols          = map(list(string))<br>    target_tags        = list(string)<br>    destination_ranges = list(string)<br>    priority           = optional(number)<br>    logging_mode       = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_ingress_allow_range"></a> [ingress\_allow\_range](#input\_ingress\_allow\_range) | the allowed ingress, based on source IP range (sending) and target tag (receiving) | <pre>map(object({<br>    description   = string<br>    protocols     = map(list(string))<br>    source_ranges = list(string)<br>    target_tags   = list(string)<br>    logging_mode  = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_ingress_allow_tag"></a> [ingress\_allow\_tag](#input\_ingress\_allow\_tag) | the allowed ingress, based on source tag (sending) and target tag (receiving) | <pre>map(object({<br>    description  = string<br>    protocols    = map(list(string))<br>    source_tags  = list(string)<br>    target_tags  = list(string)<br>    logging_mode = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | the network in which to deploy the firewall rule | `any` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | the project hosting the VPC where the firewall rule will be deployed | `any` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
