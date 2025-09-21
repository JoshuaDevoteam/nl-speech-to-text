# Artifact Registry factory

This module creates a repository in Artifact Registry. Below you will find an example of proper usage.

Note that you may require both `artifact_registry_format` to define the type of registry. For example, if you want a DOCKER registry `artifact_registry_format=DOCKER`  since the available options for `artifact_registry_format` are DOCKER, MAVEN, REGIONAL, NPM, PYTHON, APT (in Preview) and YUM (in Preview). Here's a complete list of [formats](https://cloud.google.com/storage/docs/locations)

## Example

```terraform
module "artifact_repository" {
  source = ""
  project_id    = "your-project-id-here"
  artifact_registry_format   = "your-artifact-registry-format"
  location = "your-location"
  description = ""
  iam_binding_role_group_map = {
    "roles/bucket.role.here" = ["serviceAccount:email1@domain.com","group:email2@domain.com"]
  }
}
```

## Requirements

| Name                                                                      | Version      |
| ------------------------------------------------------------------------- | ------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 2    |
| <a name="requirement_google"></a> [google](#requirement\_google)          | >= 4.12.0 |

## Providers

| Name                                                       | Version      |
| ---------------------------------------------------------- | ------------ |
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.12.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                          | Type     |
| ----------------------------------------------------------------------------------------------------------------------------- | -------- |
| [google_artifact_registry_repository.repository](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |

## Inputs

| Name                                                                                                                  | Description                                                           | Type     | Default      | Required |
| --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | -------- | ------------ |:--------:|
| <a name="input_project_id"></a> [project_id](#input\_project\_id)                                                     | ID of the project.                                                    | `string` | n/a          | yes      |
| <a name="input_artifact_registry_repository_id"></a> [artifact_registry_repository_id](#input\_name)                  | Id of the Repository.                                                 | `string` | n/a          | yes      |
| <a name="input_artifact_registry_location"></a> [artifact_registry_location](#input\_location)                        | Location of the artifact registry repo.                               | `string` | n/a          | yes      |
| <a name="input_artifact_registry_format"></a> [artifact_registry_format](#input\_repository\_format)                      | Format of the repository.                                             | `string` | `"DOCKER"`   | no       |
| <a name="input_artifact_registry_description"></a>[artifact_registry_description ](#artifact_registry_description)    | Description of the Artifact Registry.                                 | `string` | n/a          | no       |
| <a name="input_iam_binding_role_group_map"></a> [iam_binding_role_group_map](#input\_iam\_binding\_role\_group\_map)  | A map with each role as key and lists of members or groups as values. | `string` | n/a          | no       |

## Outputs

| Name                                                                          | Description                    |
| ----------------------------------------------------------------------------- | ---------------------          |
| <a name="output_repository_id"></a> [bucket\_id](#output\_repository\_id)     |"The Artifact Registry's ID.    |

## Test

No tests for this Module
