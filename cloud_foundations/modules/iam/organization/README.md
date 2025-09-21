# IAM Organization Modules

In this module we have split all the resources needed for IAM Organization.

**Important**:
`google_organization_iam_policy` cannot be used in conjunction with `google_organization_iam_binding`,
`google_organization_iam_member`, or `google_organization_iam_audit_config` or they will fight over what your policy should
be.

**Important**:
`google_organization_iam_binding` resources can be used in conjunction with `google_organization_iam_member` resources only
if they do not grant privilege to the same role.

**_Things to remember_**:
New organizations have several default policies which will, without extreme caution, be overwritten by use of this
resource. The safest alternative is to use multiple `google_organization_iam_binding resources`. This resource makes it
easy to remove your own access to an organization, which will require a call to Google Support to have fixed, and can
take multiple days to resolve.

In general, this resource should only be used with organizations fully managed by Terraform. If you do use this resource,
the best way to be sure that you are not making dangerous changes is to start by importing your existing policy, and
examining the diff very closely.

### Organization IAM Audit config example:

```terraform
module "organization_iam_audit_config" {
  source = "./iam_organization_audit_config"

  organization_id           = "132905988165"
  audit_log_config_log_type = ["ADMIN_READ", "DATA_READ"]
  service                   = "allServices"

  exempted_members = ["user:stefan.neacsu@fourcast.dev"]
}
```

### Organization IAM Binding example

**Warning:** If role is set to `roles/owner` and you don't specify a user or service account you have access to in
members, you can lock yourself out of your organization.

```terraform
module "organization_iam_binding" {
  source = "./iam_organization_binding"

  organization_id = "132905988165"
  bindings = {
    "user:stefan.neacsu@devoteam.com" = ["roles/editor"],
    "serviceAccount:912955999877@cloudbuild.gserviceaccount.com" = ["roles/editor"]
  }
}
````

### Organization IAM Member example

```terraform
module "organization_iam_member" {
  source = "./iam_organization_member"

  organization_id = "132905988165"
  role            = ["roles/editor", "roles/viewer"]

  member = "user:stefan.neacsu@devoteam.com"
}
```

### Organization IAM Policy Config example:

```terraform
module "organization_iam_policy" {
  source = "./iam_organization_policy"

  organization_id = "132905988165"

  bindings = {
    "user:stefan.neacsu@devoteam.com" = ["roles/editor"],
    "serviceAccount:912955999877@cloudbuild.gserviceaccount.com" = ["roles/editor"]
  }
}
```
