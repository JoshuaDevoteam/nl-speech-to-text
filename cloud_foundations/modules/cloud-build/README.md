# Cloud Build

Creates a Cloud Build trigger on a Google project

## Example

```terraform
module "cloud_build" {
   source = ""

   project       = "tf-gcp-foundation"
   trigger_name  = "trigger"
   branch_regex  = "^dev$"
   repo_name     = "tf-gcp-modules-cloud-build"
   repo_owner    = "devoteamgcloud"
   substitutions = {}
   config_path   = "./cloudbuild.yaml"
   included      = ["cloudbuild/**"]
   disabled      = false
   description   = "Short description"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.66.0, < 5.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.66.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.66.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloudbuild_trigger.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_path"></a> [config\_path](#input\_config\_path) | Path to build config file | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the trigger | `string` | `""` | no |
| <a name="input_disabled"></a> [disabled](#input\_disabled) | Whether the trigger is disabled | `bool` | `false` | no |
| <a name="input_ignored_files"></a> [ignored\_files](#input\_ignored\_files) | List of paths to files that will be ignored by the trigger | `list(string)` | n/a | yes |
| <a name="input_included_files"></a> [included\_files](#input\_included\_files) | List of paths to files that will trigger builds | `list(string)` | n/a | yes |
| <a name="input_invert_regex"></a> [invert\_regex](#input\_invert\_regex) | Match on everything EXCEPT the Regex. | `bool` | `false` | no |
| <a name="input_on"></a> [on](#input\_on) | Action to fire the trigger | `string` | `"PUSH_BRANCH"` | no |
| <a name="input_project"></a> [project](#input\_project) | The project id on which to create the trigger | `string` | n/a | yes |
| <a name="input_pull_request_comment_control"></a> [pull\_request\_comment\_control](#input\_pull\_request\_comment\_control) | One of `COMMENTS_DISABLED`, `COMMENTS_ENABLED` or `COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY` must be provided. | `string` | `"COMMENTS_DISABLED"` | no |
| <a name="input_regex"></a> [regex](#input\_regex) | Regex to match the Tag or branch name. | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Name of the github repository | `string` | n/a | yes |
| <a name="input_repo_owner"></a> [repo\_owner](#input\_repo\_owner) | Name of the github repository owner | `string` | n/a | yes |
| <a name="input_substitutions"></a> [substitutions](#input\_substitutions) | Substitution variables for the build | `map(string)` | n/a | yes |
| <a name="input_trigger_name"></a> [trigger\_name](#input\_trigger\_name) | The name of the trigger | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_trigger_id"></a> [trigger\_id](#output\_trigger\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
