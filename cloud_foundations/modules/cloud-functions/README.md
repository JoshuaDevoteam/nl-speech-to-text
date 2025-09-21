# Cloud Function factory

This module creates a Cloud Function. Below you will find an example of proper usage.

## Examples

This is an example of Cloud Function with Cloud Build Trigger

```
module "cloud_function" {
  source = "./tf-gcp-cloud-function"

  project_id                 = "PROJECT_ID"
  region                     = "REGION_NAME"
  cloud_function_name        = "CLOUD_FUNCTION_NAME"
  cloud_function_description = "A simple Hello World Function"

  cloud_function_runtime             = "RUNTIME; EX: python37"
  cloud_function_timeout             = 320
  cloud_function_available_memory_mb = 256

  cloud_function_entry_point = "ENTRYPOINT_CODE_FUNCTION"

  cloud_function_source_type           = "REPOSITORY"
  cloud_function_source_repository_url = "REPO_URL"
  cloud_function_trigger_type          = "HTTP"

  iam_binding_role_group_map = {
    "roles/editor" = ["user:email@example.com"]
  }
  cloud_function_labels      = {
    "label_key" = "label_value"
  }

  cloud_function_failure_policy_retry = true
}

```

Example where a repository holds the cloud function's source code; This is the reccomended way to use this module. This
example creates http-triggered function (`cloud_function_trigger_type = "HTTP"`).

```terraform
module "cloud_function" {
  source                     = ""
  project_id                 = "your_project_id"
  cloud_function_name        = "your_cloud_function_name"
  cloud_function_description = "A simple Hello World Function"

  cloud_function_runtime             = "python39"
  cloud_function_timeout             = 60
  cloud_function_available_memory_mb = 256

  cloud_function_entry_point = "python_function_name"

  cloud_function_source_type           = "REPOSITORY"
  cloud_function_source_repository_url = "repo.url.com"

  cloud_function_trigger_type = "HTTP"

  iam_binding_role_group_map = {
    "roles/bucket.role.here" = ["serviceAccount:email1@domain.com", "group:email2@domain.com"]
  }
  cloud_function_labels      = {
    "label_key" = "label_value"
  }

  cloud_function_failure_policy_retry = true
}
```

Here is an example of am event-triggered cloud function (`cloud_function_trigger_type = "EVENT"`) that is triggered
whenever an object is uploaded/overwritten (`cloud_function_event_type = "google.storage.object.finalize"`) to a cloud
storage bucket with "bucket_id" (`cloud_function_resource = "bucket_id"`).

Note also that the source code of this function comes from a bucket (instead of a repository)
because `cloud_function_source_type = "BUCKET"`.

```terraform
module "cloud_function" {
  source                     = ""
  project_id                 = "your_project_id"
  cloud_function_name        = "your_cloud_function_name"
  cloud_function_description = "A simple Hello World Function"

  cloud_function_runtime             = "python39"
  cloud_function_timeout             = 60
  cloud_function_available_memory_mb = 256

  cloud_function_entry_point = "python_function_name"

  cloud_function_source_type           = "BUCKET"
  cloud_function_source_archive_bucket = "bucket_name"
  cloud_function_source_archive_object = "name_of_zip_archive_in_bucket"

  cloud_function_trigger_type = "EVENT"
  cloud_function_event_type   = "google.storage.object.finalize"
  cloud_function_resource     = "bucket_id"

  iam_binding_role_group_map = {
    "roles/bucket.role.here" = ["serviceAccount:email1@domain.com", "group:email2@domain.com"]
  }
  cloud_function_labels      = {
    "label_key" = "label_value"
  }

  cloud_function_failure_policy_retry = true
}
```

## Requirements

| Name                                                                      | Version      |
| ------------------------------------------------------------------------- | ------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > = 1, < 2    |
| <a name="requirement_google"></a> [google](#requirement\_google)          | > = 3.50, < 4 |

## Providers

| Name                                                       | Version      |
| ---------------------------------------------------------- | ------------ |
| <a name="provider_google"></a> [google](#provider\_google) | > = 3.50, < 4 |

## Modules

No modules.

## Resources

| Name                                                                                                                          | Type     |
| ----------------------------------------------------------------------------------------------------------------------------- | -------- |
| [google_storage_bucket.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |

## Inputs

| Name                                                                                                                                   | Description                                                                    | Type     | Default      | Required |
| ---------------------------------------------------------------------------------------------------------------------------------------| ------------------------------------------------------------------------------ | -------- | ------------ |:--------:|
| <a name="input_project_id"></a>[project_id](#project_id)                                                                               | Id of the project                                                              | `string` | n/a          | yes      |
| <a name="input_cloud_function_name"></a>[cloud_function_name](#cloud_function_name)                                                    | Name of the function.                                                          | `string` | n/a          | yes      |
| <a name="input_cloud_function_description"></a>[cloud_function_description ](#cloud_function_description)                              | Description of the cloud function.                                             | `string` | n/a          | yes      |
| <a name="input_cloud_function_runtime"></a>[cloud_function_runtime](#cloud_function_runtime)                                           | The runtime in which the function is going to run. Eg. nodejs10, or python38   | `string` | n/a          | yes      |
| <a name="input_cloud_function_timeout"></a>[cloud_function_timeout](#cloud_function_timeout)                                           | Max amount of time cloud function can run.                                     | `number` | 60           | no       |
| <a name="input_cloud_function_available_memory_mb"></a>[cloud_function_available_memory_mb](#cloud_function_available_memory_mb)       | Memory (in MB), available to the function.                                     | `number` | 256          | no       |
| <a name="input_cloud_function_entry_point"></a>[cloud_function_entry_point](#cloud_function_entry_point)                               | Name of the function that will be executed when function is triggered.         | `string` | n/a          | no       |
| <a name="input_cloud_function_source_type"></a>[cloud_function_source_type](#cloud_function_source_type)                               | Says whether the function will take source code from a bucket or a repository. | `string` | n/a          | yes      |
| <a name="input_cloud_function_source_archive_bucket"></a>[cloud_function_source_archive_bucket](#cloud_function_source_archive_bucket) | The GCS bucket containing the zip archive which contains the function.         | `string` | n/a          | no       |
| <a name="input_cloud_function_source_archive_object"></a>[cloud_function_source_archive_object](#cloud_function_source_archive_object) | The source archive object (usually a zip file) in archive bucket.              | `string` | n/a          | no       |
| <a name="input_cloud_function_source_repository_url"></a>[cloud_function_source_repository_url](#cloud_function_source_repository_url) | URL pointing to a git repository where function source can be found.           | `string` | n/a          | no       |
| <a name="input_cloud_function_trigger_type"></a>[cloud_function_trigger_type](#cloud_function_trigger_type)                            | Says whether function will be triggered by an HTTP request or an event.        | `string` | n/a          | yes      |
| <a name="input_cloud_function_event_type"></a>[cloud_function_event_type](#cloud_function_event_type)                                  | The type of event to observe. For example: google.storage.object.finalize      | `string` | n/a          | yes      |
| <a name="input_cloud_function_resource"></a>[cloud_function_resource](#cloud_function_resource)                                        | The name or partial URI of the resource from which to observe events.          | `string` | n/a          | yes      |
| <a name="input_iam_binding_role_group_map"></a>[iam_binding_role_group_map ](#iam_binding_role_group_map)                              | A map with each role as key and lists of members or groups as values. Sets IAM | `map(list(string))` | `{}`         | no      |
| <a name="input_cloud_function_labels"></a>[cloud_function_labels](#cloud_function_labels)                                              | A label is a key-value pair that helps you organize  Google Cloud resources.   | `map(string)`       |  `{}`        |  no     |
| <a name="input_cloud_function_failure_policy_retry"></a>[cloud_function_failure_policy_retry](#cloud_function_failure_policy_retry)    | Whether the function should be retried on failure.                             | `bool`   | false        | no       |
| <a name="service_account_email"></a>[service_account_email](#service_account_email)    | Alternative service account to run cloud function                            | `string`   | false        | no       |

## Outputs

| Name                                                                 | Description           |
| -------------------------------------------------------------------- | --------------------- |
| <a name="output_function_id"></a> [bucket\_id](#output\_bucket\_id)  | ID of the GCS bucket  |
| <a name="output_bucket_url"></a> [bucket\_url](#output\_bucket\_url) | URL of the GCS bucket |

| Name                                                                                                                        | Description                                                                                              |
| --------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <a name="output_cloud_function_id"></a>[cloud_function_id](#cloud_function_id)                                              | ID of the cloud function.                                                                                |
| <a name="output_cloud_function_https_trigger_url"></a>[cloud_function_https_trigger_url](#cloud_function_https_trigger_url) | URL which triggers function execution. Only returned if cloud_function_trigger_type is set to "HTTP".    |
| <a name="output_cloud_function_source_repository"></a>[cloud_function_source_repository](#cloud_function_source_repository) | URL pointing to the repository where the function was defined at the time of deployment.                 |
| <a name="output_cloud_function_project"></a>[cloud_function_project](#cloud_function_project)                               | Project of the function. If it is not provided, the provider project is used.                            |
| <a name="output_cloud_function_region"></a>[cloud_function_region](#cloud_function_region)                                  | Region of function. If it is not provided, the provider region is used.                                  |
