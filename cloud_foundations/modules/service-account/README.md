# Service Account Module

The module it is split in submodules in order to be used for specific uses like:

- Default Service Account module
- Service Account module
- Service Account IAM Binding
- Service Account IAM Member
- Service Account Key
- Service Account IAM Policy

⚠️ **_Important_**: some Google Cloud products do not work if the default service accounts are deleted so it is
better to DEPRIVILEGE as Google CAN NOT recover service accounts that have been deleted for more than 30 days. Also
Google recommends using the `constraints/iam.automaticIamGrantsForDefaultServiceAccounts` constraint to disable
automatic IAM Grants to default service accounts.

**_Note:_** This resource works on a best-effort basis, as no API formally describes the default service accounts and it
is for users who are unable to use constraints. If the default service accounts change their name or additional service
accounts are added, this resource will need to be updated.

**_To remember_**:

- `google_service_account_iam_policy` cannot be used in conjunction with `google_service_account_iam_binding` and
  `google_service_account_iam_member` or they will fight over what your policy should be.

- `google_service_account_iam_binding` resources can be used in conjunction with `google_service_account_iam_member`
  resources only if they do not grant privilege to the same role.

## Examples

Default Service Account Module example:

```terraform
module "default_service_account" {
  source = "./default_service_account"

  project        = "PROJECT_ID"
  action         = "DISABLE"
  restore_policy = "NONE|REVERT|REVERT_AND_IGNORE_FAILURE."
}
```

Service Account Module example:

```terraform
module "service_account" {
  source = "./service_account"

  project      = "PROJECT_ID"
  account_id   = "test-sa"
  display_name = "test"
  description  = "Test description for service account"
  disabled     = false
}
```

Service Account IAM binding example:

```terraform
module "service_account_iam_binding" {
  source = "./service_account_iam_binding"

  project      = "PROJECT_ID"
  account_id   = "test-sa"
  display_name = "test-sa"
  description  = "Test description for service account"
  disabled     = false
  bindings     = {
    "user:stefan.neacsu@devoteam.com" = ["roles/viewer"]
  }
}
```

Service Account IAM member example:

```terraform
module "service_account_iam_member" {
  source = "./service_account_iam_member"

  project      = "PROJECT_ID"
  account_id   = "test-sa"
  display_name = "test-sa"
  description  = "Test description for service account"
  disabled     = false
  member       = "stefan.neacsu@devoteam.com"
  role         = ["roles/editor", "roles/viewer"]
}
```

Service Account Key example:

```terraform
module "service_account_key" {
  source = "./service_account_key"

  project            = "PROJECT_ID"
  account_id         = "test-sa"
  display_name       = "test-sa"
  service_account_id = "test-sa"
  private_key_type   = "TYPE_UNSPECIFIED"
  public_key_type    = "TYPE_X509_PEM_FILE"
  rotation_days      = 30
}
```

Service Account Policy example:

```terraform
module "service_account_policy" {
  source = "./service_account_policy"

  project      = "PROJECT_ID"
  account_id   = "test-sa"
  display_name = "test-sa"
  description  = "Test description for service account"
  disabled     = false
  bindings     = {
    "user:stefan.neacsu@devoteam.com" = ["roles/viewer"]
  }
}
```
## Test
There is 1 test for each of the default_service_account, service_account, service_account_iam_binding, service_account_iam_member, service_account_key and service_account_policy modules, which tests the applying of each. The tests have its own directory and test file inside tests/ directory, and variables are declared in a terraform.tfvars file inside the tests/test_[TEST_TYPE_HERE]/test_create_[MODULE_NAME_HERE] directory. Run
```
go test
```
in the tests/test_[TEST_TYPE_HERE] directory to test all modules. To test a single module, instead run:
```
go test create_[MODULE_NAME_HERE]_test.go.
```
