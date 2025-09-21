# IAM Folder module examples

In this module we have splitted all the resources needed for IAM Project. Most of them would not be used and cannot be
used because of APIs limitations and Terraform's as well.

**Important**:
google_folder_iam_policy cannot be used in conjunction with google_folder_iam_binding, google_folder_iam_member, or
google_folder_iam_audit_config or they will fight over what your policy should be.

**Important**:
google_folder_iam_binding resources can be used in conjunction with google_folder_iam_member resources only if they do
not grant privilege to the same role.

**_Things to _remember__**:
You can accidentally lock yourself out of your folder using this resource. Deleting a google_folder_iam_policy removes
access from anyone without permissions on its parent folder/organization. Proceed with caution. It's not recommended to
use google_folder_iam_policy with your provider folder to avoid locking yourself out, and it should generally only be
used with folders fully managed by Terraform. If you do use this resource, it is recommended to import the policy before
applying the change.

### Folder IAM Audit config example:

```
module "folder_iam_audit_config" {
  source = "./modules/iam_folder/iam_folder_audit_config"

  folder_id                 = "folders/807142320330"
  audit_log_config_log_type = ["ADMIN_READ", "DATA_READ"]
  service                   = "allServices"

  exempted_members = ["user:test@example.com"]
}
```

### Folder IAM Binding example

```
module "folder_iam_binding" {
  source = "./modules/iam_folder/iam_folder_binding"

  folder_id = "folders/FOLDER_ID"
  bindings = {
    "user:test@example.com" = ["roles/editor"],
    "serviceAccount:912955999877@cloudbuild.gserviceaccount.com" = ["roles/editor"]
  }}
````

### Folder IAM Member example

```
module "folder_iam_member" {
  source = "./modules/iam_folder/iam_folder_member"

  folder_id = "folders/FOLDER_ID"
  role      = ["roles/editor", "roles/viewer"]

  member = "user:test@example.com"
}
```

### Folder IAM Policy Config example:

```
module "folder_iam_policy" {
  source = "./modules/iam_folder/iam_folder_policy"

  folder_id = "folders/FOLDER_ID"
  bindings = {
    "user:test@example.com" = ["roles/editor"],
    "serviceAccount:912955999877@cloudbuild.gserviceaccount.com" = ["roles/editor"]
  }
}
```

### Test
There is 1 test for each of the iam_folder_audit_config, iam_folder_binding, iam_folder_member and iam_folder_policy modules, which tests the applying of each. The tests have its own directory and test file inside tests/ directory, and variables are declared in a terraform.tfvars file inside the tests/test_create_[MODULE_NAME_HERE] directory. Run
```
go test
```
in the tests directory to test all modules. To test a single module, run:
```
go test create_[MODULE_NAME_HERE]_test.go.
```
