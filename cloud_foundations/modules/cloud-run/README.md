# Cloud Run

Creates a Cloud Run service on a Google project

## Example

```terraform
module "cloud_run" {
   source = ""

   name                    = "hello"
   location                = "europe-west4"
   project                 = "tf-gcp-foundation"
   cpu                     = "2"
   memory                  = "8Gi"
   min_instance_count      = 1
   max_instance_count      = 2
   startup_cpu_boost       = true
   timeout_seconds         = 3600
   port                    = 8080
   service_account_email   = "sa-test-run@tf-gcp-foundation.iam.gserviceaccount.com"
   vpc_access_connector_id = "projects/tf-gcp-foundations/locations/europe-west4/connectors/default"
   env_variables      = {
      "environment" = "prod"
      "NODE_ENV"    = "production"
   }
   iam = {
      "sa-test-run" = {
         member = "serviceAccount:sa-test-run@tf-gcp-foundation.iam.gserviceaccount.com"
         role   = "roles/run.invoker"
      }
   }
   secrets = {}
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
| [google_cloud_run_service_iam_member.member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_cloud_run_v2_service.service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | The container image to deploy in Cloud Run | `string` | `"us-docker.pkg.dev/cloudrun/container/hello"` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The amount of CPU to allocate to the service | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | The environment variables to set for the service | `map(string)` | n/a | yes |
| <a name="input_iam"></a> [iam](#input\_iam) | Map of members and roles to be assigned on the Cloud Run service | <pre>map(object({<br>    member = string<br>    role   = string<br>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of the service | `string` | n/a | yes |
| <a name="input_max_instance_count"></a> [max\_instance\_count](#input\_max\_instance\_count) | The maximum number of instances to spin up for this function | `number` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory to allocate to the service | `string` | n/a | yes |
| <a name="input_min_instance_count"></a> [min\_instance\_count](#input\_min\_instance\_count) | The minimum number of instances to spin up for this function | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the service | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | The port number for the service | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project id on which to deploy the service | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of secret versions and names to pass to the Cloud Run service | <pre>map(object({<br>    version = optional(string, "latest")<br>    name    = string<br>  }))</pre> | n/a | yes |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | The service account to use for the service | `string` | n/a | yes |
| <a name="input_startup_cpu_boost"></a> [startup\_cpu\_boost](#input\_startup\_cpu\_boost) | Boost CPU during instance startup | `bool` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The number of seconds after which a request times out (should end with 's') | `string` | n/a | yes |
| <a name="input_traffic"></a> [traffic](#input\_traffic) | n/a | <pre>object({<br>    type     = string<br>    percent  = optional(number)<br>    revision = optional(string)<br>    tag      = optional(string)<br>  })</pre> | <pre>{<br>  "percent": 100,<br>  "type": "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"<br>}</pre> | no |
| <a name="input_vpc_access_connector_id"></a> [vpc\_access\_connector\_id](#input\_vpc\_access\_connector\_id) | The ID of the vpc access connector id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_location"></a> [location](#output\_location) | Cloud Run service location |
| <a name="output_name"></a> [name](#output\_name) | Cloud Run service name |
| <a name="output_url"></a> [url](#output\_url) | Cloud Run service URL |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Test
There is 1 test for this module so far, which tests the creation of a Cloud Run Service on a Google Project. The test has its own directory and test file inside tests/ directory, anand variables are declared in a terraform.tfvars file inside the tests/test_create_[MODULE_NAME_HERE] directory. Run
```
go test
```
in the tests directory to test all modules. To test a single module, run:
```
go test create_[MODULE_NAME_HERE]_test.go.
```
