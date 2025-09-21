# Group management module

In order to start using this modules you will first need to follow the steps described in
the [documentation.](https://developers.google.com/admin-sdk/directory/v1/guides/delegation#delegate_domain-wide_authority_to_your_service_account)
 In there you will be walked through on the steps you need to do in Google Admin and also on Google Cloud Platform.

It is always indicated and we recommended using a Service Account that would impersonate the Google Workspace Super User
instead of using `gcloud auth login`. Be sure to have the Admin SDK enabled in Google Cloud Platform (
admin.googleapis.com) in order to work.

## Examples

Group creation example with provider for Google Workspace (Provider needed for the modules to work)

```terraform
provider "googleworkspace" {
  customer_id             = "WORKSPACE_CUSTOMER_ID"
  credentials             = "GOOGLE_CREDENTIALS_FILE.JSON"
  oauth_scopes            = [
    "https://www.googleapis.com/auth/admin.directory.user", "https://www.googleapis.com/auth/admin.directory.group"
  ]
  impersonated_user_email = "stefan.neacsu@example.dev"
}

module "group" {
  source = "./iam_group"

  group_description = "test group"
  group_email       = "test-something@example.dev"
  group_name        = "test-group"
}
```

Example of Group IAM member

```terraform
module "group_iam_member" {
  source = "./iam_group_member"

  group_email  = "test-something@example.dev"
  member_email = "stefan.neacsu@example.dev"
  member_role  = "OWNER"
}
```

Example of Group IAM members

```terraform
module "group_iam_members" {
  source = "./iam_group_members"

  group_email   = "test-something@example.dev"
  group_members = {
    "MANAGER" = "stefan.neacsu@example.dev", "MEMBER" = "example@email.com"
  }
}
```
