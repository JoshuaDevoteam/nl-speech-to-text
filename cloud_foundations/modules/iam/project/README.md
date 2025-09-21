# IAM Project module examples

In this module we have splitted all the resources needed for IAM Project. Most of them would not be used and cannot be
used because of APIs limitations and Terraform's as well.

**Important**:
`google_project_iam_policy` cannot be used in conjunction with `google_project_iam_binding`, `google_project_iam_member`, or
`google_project_iam_audit_config` or they will fight over what your policy should be.

**Important**:
`google_project_iam_binding` resources can be used in conjunction with `google_project_iam_member` resources only if they do
not grant privilege to the same role.

**_Things to _remember__**:
You can accidentally lock yourself out of your project using this resource. Deleting a `google_project_iam_policy` removes
access from anyone without organization-level access to the project. Proceed with caution. It's not recommended to use
`google_project_iam_policy` with your provider project to avoid locking yourself out, and it should generally only be used
with projects fully managed by Terraform. If you do use this resource, it is recommended to import the policy before
applying the change.

### Project IAM Audit config example:

```terraform
module "project_iam_audit_config" {
  source = "./iam_project_audit_config"

  project_id                = "cf-test-dev"
  audit_log_config_log_type = ["ADMIN_READ", "DATA_READ"]
  service                   = "allServices"

  exempted_members = ["user:stefan.neacsu@devoteam.com", "serviceAccount:912955999877@cloudbuild.gserviceaccount.com"]
}
```

### Project IAM Binding example

```terraform
module "project_iam_binding" {
  source = "./modules/iam_project/iam_project_binding"

  project_id = "cf-test-dev"
  bindings = {
    "user:stefan.neacsu@devoteam.com" = ["roles/editor"],
    "serviceAccount:912955999877@cloudbuild.gserviceaccount.com" = ["roles/editor"]
  }
}
````

### Project IAM Member example

```terraform
module "project_iam_member" {
  source = "./iam_project_member"

  project_id = "cf-test-dev"
  role       = ["roles/editor", "roles/viewer"]

  member = "user:stefan.neacsu@devoteam.com"
}
```

### Project IAM Policy Config example:

```terraform
module "project_iam_policy" {
  source = "./iam_project_policy"

  project_id = "cf-test-dev"
  bindings = {
    "user:stefan.neacsu@devoteam.com" = ["roles/editor"],
    "serviceAccount:912955999877@cloudbuild.gserviceaccount.com" = ["roles/editor"]
  }
}
```
## Test
There is 1 test for each of the iam_project_audit_config, iam_project_binding, iam_project_member and iam_project_policy modules, which tests the applying of each. The tests have its own directory and test file inside tests/ directory, and variables are declared in a terraform.tfvars file inside the tests/test_create_[MODULE_NAME_HERE] directory. Run
```
go test
```
in the tests directory to test all modules. To test a single module, run:
```
go test create_[MODULE_NAME_HERE]_test.go.
```
