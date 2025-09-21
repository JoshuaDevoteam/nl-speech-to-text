# Intro
Create VPC and subnets in a Google Cloud project.

## Limitations & Design choices
- Subnets follow same naming convention as the network they're in.

- A default deny-all egress rule is created with the lowest priority

- Uses null-label module to enforce naming conventions

- we currently skip `#checkov:skip=CKV_GCP_26` *"No VPC flow logs are needed"*

# Usage
## Basic usage
```hcl
module "vpc" {
  source      = ""
  project     = "pj-machinelearning-prod-1"
  description = "Network for hosting ML workloads"
  name        = "ml"
  subnets     = {
        "ml-prod" = {
          name                  = "prod"
          cidr_primary          = "10.20.0.0/16"
          region                = "europe-west1"
        }
      }
  routing_mode = "REGIONAL"
}
```
By default, the null-label module will use the prefix `nw` and `nwr`, resulting in vpc name `nw-ml` and subnet `nwr-prod`.

```hcl
  # module.vpc.google_compute_network.vpc_network will be created
+ resource "google_compute_network" "vpc_network" {
    + auto_create_subnetworks         = false
    + delete_default_routes_on_create = false
    + description                     = "Network for hosting ML workloads"
    + gateway_ipv4                    = (known after apply)
    + id                              = (known after apply)
    + mtu                             = (known after apply)
    + name                            = "nw-ml"
    + project                         = "pj-machinelearning-prod-1"
    + routing_mode                    = "REGIONAL"
    + self_link                       = (known after apply)
}

# module.vpc.google_compute_subnetwork.vpc_subnet["ml-prod"] will be created
+ resource "google_compute_subnetwork" "vpc_subnet" {
    + creation_timestamp         = (known after apply)
    + external_ipv6_prefix       = (known after apply)
    + fingerprint                = (known after apply)
    + gateway_address            = (known after apply)
    + id                         = (known after apply)
    + ip_cidr_range              = "10.20.0.0/16"
    + ipv6_cidr_range            = (known after apply)
    + name                       = "nwr-prod"
    + network                    = (known after apply)
    + private_ip_google_access   = false
    + private_ipv6_google_access = (known after apply)
    + project                    = "pj-machinelearning-prod-1"
    + purpose                    = (known after apply)
    + region                     = "europe-west1"
    + secondary_ip_range         = (known after apply)
    + self_link                  = (known after apply)
    + stack_type                 = (known after apply)
}
# module.vpc.google_compute_firewall.default will be created
+ resource "google_compute_firewall" "default" {
    + creation_timestamp = (known after apply)
    + description        = "default deny all egress"
    + destination_ranges = (known after apply)
    + direction          = "EGRESS"
    + enable_logging     = (known after apply)
    + id                 = (known after apply)
    + name               = "deny-all-egress"
    + network            = (known after apply)
    + priority           = 65534
    + project            = "pj-machinelearning-prod-1"
    + self_link          = (known after apply)

    + deny {
    + ports    = []
    + protocol = "all"
    }
}
```

## Advanced usage

```hcl
module "vpc" {
  source      = ""
  source      = "git@github.com:devoteamgcloud/tf-gcp-modules-network-vpc.git"
  project     = "pj-machinelearning-dev-1"
  description = "Network for hosting ML workloads"
  name        = "ml"
  subnets     = {
    "belgium-development" = {
      name                  = "gke-nodes"
      cidr_primary          = "10.20.0.0/16"
      region                = "europe-west1"
      private_google_access = true
      secondary_ranges      = {
        "k8s-pods" = {
          name       = "pods"
          cidr_range = "100.64.0.0/16"
        }
        "k8s-services" = {
          name       = "services"
          cidr_range = "10.30.0.0/20"
        }
      }
    }
  }
  routing_mode = "REGIONAL"

  environment = "eu"
  stage       = "dev"
  label_order = ["environment", "stage", "name"]
}
```

By setting the label_order to not include `namespace`, the default `nw` prefix is not used and the resulting vpc and subnets will
be named `eu-dev-ml` and `eu-dev-gke-nodes` respectively.

```hcl
  # module.vpc.google_compute_network.vpc_network will be created
+ resource "google_compute_network" "vpc_network" {
    + auto_create_subnetworks         = false
    + delete_default_routes_on_create = false
    + description                     = "Network for hosting ML workloads"
    + gateway_ipv4                    = (known after apply)
    + id                              = (known after apply)
    + mtu                             = (known after apply)
    + name                            = "eu-dev-ml"
    + project                         = "pj-machinelearning-dev-1"
    + routing_mode                    = "REGIONAL"
    + self_link                       = (known after apply)
}

# module.vpc.google_compute_subnetwork.vpc_subnet["belgium-development"] will be created
+ resource "google_compute_subnetwork" "vpc_subnet" {
    + creation_timestamp         = (known after apply)
    + external_ipv6_prefix       = (known after apply)
    + fingerprint                = (known after apply)
    + gateway_address            = (known after apply)
    + id                         = (known after apply)
    + ip_cidr_range              = "10.20.0.0/16"
    + ipv6_cidr_range            = (known after apply)
    + name                       = "eu-dev-gke-nodes"
    + network                    = (known after apply)
    + private_ip_google_access   = true
    + private_ipv6_google_access = (known after apply)
    + project                    = "pj-machinelearning-dev-1"
    + purpose                    = (known after apply)
    + region                     = "europe-west1"
    + secondary_ip_range         = [
      + {
          + ip_cidr_range = "100.64.0.0/16"
          + range_name    = "eu-dev-pods"
        },
      + {
          + ip_cidr_range = "10.30.0.0/20"
          + range_name    = "eu-dev-services"
        },
    ]
    + self_link                  = (known after apply)
    + stack_type                 = (known after apply)
}
# module.vpc.google_compute_firewall.default will be created
+ resource "google_compute_firewall" "default" {
    + creation_timestamp = (known after apply)
    + description        = "default deny all egress"
    + destination_ranges = (known after apply)
    + direction          = "EGRESS"
    + enable_logging     = (known after apply)
    + id                 = (known after apply)
    + name               = "deny-all-egress"
    + network            = (known after apply)
    + priority           = 65534
    + project            = "pj-machinelearning-dev-1"
    + self_link          = (known after apply)

    + deny {
    + ports    = []
    + protocol = "all"
    }
}
```

# TODO
- See code level #TODO's.


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
| <a name="module_labels_default_fw"></a> [labels\_default\_fw](#module\_labels\_default\_fw) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_labels_subnet"></a> [labels\_subnet](#module\_labels\_subnet) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_labels_subnet_secondaries"></a> [labels\_subnet\_secondaries](#module\_labels\_subnet\_secondaries) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_labels_vpc"></a> [labels\_vpc](#module\_labels\_vpc) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.vpc_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.vpc_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delete_default_route_on_create"></a> [delete\_default\_route\_on\_create](#input\_delete\_default\_route\_on\_create) | If set to true, deletes the default route to the internet on create. Does nothing after initial creation. | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | The description for the VPC | `string` | n/a | yes |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_firewall_logging_mode"></a> [firewall\_logging\_mode](#input\_firewall\_logging\_mode) | n/a | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | The project id for the VPC | `string` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_routing_mode"></a> [routing\_mode](#input\_routing\_mode) | The routing mode for the VPC (GLOBAL or REGIONAL) | `string` | n/a | yes |
| <a name="input_skip_default_deny_fw"></a> [skip\_default\_deny\_fw](#input\_skip\_default\_deny\_fw) | By default, deny all egress (overrules the allow all egress rule implied in the root vpc network resource). | `bool` | `false` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The subnets for the VPC | <pre>map(object({<br>    name                  = optional(string)<br>    cidr_primary          = string<br>    region                = string<br>    private_google_access = optional(bool)<br>    secondary_ranges = optional(map(object({<br>      name       = optional(string)<br>      cidr_range = string<br>    })))<br>    purpose = optional(string, "PRIVATE")<br>    role    = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_link"></a> [network\_link](#output\_network\_link) | n/a |
| <a name="output_sub_networks"></a> [sub\_networks](#output\_sub\_networks) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
