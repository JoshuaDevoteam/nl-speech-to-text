# GCP IAM module

This module manages Google Workspace Groups, and multiple Google Cloud Platform resources related to IAM.

There are two versions of the module, **basic** and **advanced**.

The **basic version** will manage folder and project level IAM, manage service accounts, supports service agents not
getting kicked out, and reference existing groups in Google Workspace.
The advanced version will have all the features of the basic version, but additionally manages organization level IAM,
subnet IAM, artifact registry IAM, groups, buckets, Workload Identity Federation, Workforce Identity Federation, and
custom roles.

In the **advanced version**, it is recommended to split the module into at least two deployments. One for the master
Service Accounts of all terraform deployments (admin). The other should be used for day-to-day management (ops). This to
limit the blast radius to the crucial terraform master service accounts.

| IAM Module                    | Basic | Advanced |
|-------------------------------|:-----:|:--------:|
| Project IAM bindings          |   x   |    x     |
| Folder IAM bindings           |   x   |    x     |
| Service Accounts              |   x   |    x     |
| Google Groups (read)          |   x   |    x     |
| Service Agents                |   x   |    x     |
| Google Groups (write)         |       |    x     |
| Organisation IAM bindings     |       |    x     |
| VPC Subnet IAM bindings       |       |    x     |
| Terraform State Buckets       |       |    x     |
| Artifact Registry IAM         |       |    x     |
| Workload Identity Federation  |       |    x     |
| Workforce Identity Federation |       |    x     |
| Custom Roles                  |       |    x     |

## Required Permissions

We assume **Super Administrator** role on the Cloud Identity / Google Workspace environment if using group management.
It is not needed for referencing groups. If you do not have a Cloud Identity or Google Workspace environment, please
contact your Devoteam G Cloud sales.

We assume **Organization Administrator** role on the customer Google Cloud Organization level. This can be revoked after
this bootstrapping operation, or if the customer is not willing to give such a wide level of access for starting the
foundations setup, we can suggest the client to carry out the bootstrapping together with our engineers.

## Customisation

Some elements need to be customized to the environment in order to run properly, like the organisation ID and a Service
Account.

## Billing

Admin Access `(roles/billing.admin)` to your Devoteam G Cloud resold Google Cloud billing account is required. Reach out
to your Devoteam G Cloud contact if this is not the case.

## Authentication

A Service Account is required to authenticate to Google Cloud Platform. Since a SA is a resource of a project,
a single project will need to exist / be created manually and a Service Account provisioned and authentication method
provided. The chosen authentication method for the service account can then be used here to create all other folders &
projects. These resources will be set up in the commands below, and could later be imported into Terraform. An example
of an authentication method is when using a service like Terraform Cloud, Workload Identity Federation can be set up
manually to circumvent using SA keys. Another method is to impersonate the service account.

## Setup

We purposely have not created a shell script as there's a small chance of elements need to be corrected (access,
authentication) during the initial setup.

Having a step-by-step initial setup simplifies spotting any issues and ensures full transparency of the setup.

### 1. Log in into gcloud with domain admin account (browser popup)

```shell
gcloud auth login
```

### 2. Setup variables

Replace this with your own variables. The project and buckets will be created in a later step. You can find
your `Organization ID` via `gcloud organizations list`. Devoteam G Cloud will provide your `Billing Account ID`.

```shell
export PROJECT_ID=pj-dgc-terraform-master
export BILLING_ACCOUNT=000634-BA49B6-590F1D
export ORG_ID=132905988165
export TF_ROOT_STATE_BUCKET_ADMIN=dgc-iam-admin-admin-tf-state # Optional, needed if storing state in a bucket
export TF_SA_NAME=dgc-iam-admin-admin-tf-state
```

### 3. Create a project under the root org & enable billing

```shell
gcloud projects create $PROJECT_ID --organization $ORG_ID --no-enable-cloud-apis
gcloud services enable cloudresourcemanager.googleapis.com --project $PROJECT_ID
gcloud services enable cloudbilling.googleapis.com --project $PROJECT_ID
gcloud services enable admin.googleapis.com --project $PROJECT_ID
gcloud services enable iam.googleapis.com --project $PROJECT_ID
gcloud beta billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT
```

### 4. Create a bucket for the root terraform state (if using buckets to store state)

To create the intial bucket, use the following. If using the recommendation to split the IAM up, the top-level IAM
module can be used to create and manage the state buckets for the other IAM repositories.

```shell
gcloud storage buckets create gs://$TF_ROOT_STATE_BUCKET_ADMIN --location EU --project $PROJECT_ID
gcloud storage buckets update gs://$TF_ROOT_STATE_BUCKET_ADMIN --versioning
```

### 5. Domain variables (advanced only)

* Set the domain admin email in `.tfvars` (Only when managing Cloud Identity groups)
* Get *Organization ID* using the command below and put it in `.tfvars`

```shell
gcloud organizations list
```

This command will show a table with all domains where your user account has access on. The *Organization ID* is the `ID`
column.

### 6. Create the root terraform IAM Service Account in the Terraform master project

```shell
gcloud iam service-accounts create \
$TF_SA_NAME --project $PROJECT_ID \
--description="Service Account used by terraform to centrally manage IAM, groups and service accounts" \
--display-name="Root Terraform service account for IAM"
```

### 7. Grant service account access on organization level and state bucket:

In comments are the reasons why certain IAM roles are needed. If you're not planning to use a certain feature, the
associated role(s) are not needed. When splitting up responsibilities these permissions can also be granted at the
required folders or projects instead of organization. In this case, it would be better to do this through Terraform
after doing the initial setup and only grant the org Admin/folder IAM admin/project IAM admin to bootstrap (if working
on project level the service usage viewer will also be required from the start to allow the service agent logic to work)

See later table for all the roles.

#### Basic & Advanced

```shell
gcloud storage buckets add-iam-policy-binding gs://$TF_ROOT_STATE_BUCKET_ADMIN --member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/storage.objectAdmin"

# Required for setting IAM policies on ORG level and below (and thus setting up the RM and VPC module).
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/resourcemanager.organizationAdmin"

# Required for creating service accounts and managing their IAM policies.
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/iam.serviceAccountAdmin"

# Required for the serviceagent logic.
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/serviceusage.serviceUsageViewer"

# Required for setting IAM policies on folders if not working at org level (does not automatically grant project level IAM admin).
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/resourcemanager.folderIamAdmin"

# Required for setting IAM policies on projects if not working at org level (is not included in the folder IAM admin).
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/resourcemanager.projectIamAdmin"
```

#### Advanced Only

Add the following only for advanced as needed:

```shell
# Required for setting IAM policies on subnets when using shared VPCs.
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/compute.xpnAdmin"

# Required for creating Cloud Storage buckets to store Terraform state.
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/storage.admin"

# Required for setting IAM policies on artifact registry repositories.
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/artifactregistry.admin"

# Required for configuring Workload Identity Federation.
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/iam.workloadIdentityPoolAdmin"

# Required for configuring Workforce Identity Federation.
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/iam.workforcePoolAdmin"

# Required for managing custom roles.
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/iam.organizationRoleAdmin"

# Required for managing project level custom roles and organization role admin is not granted.
gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/iam.roleAdmin"
```

### 8. Authenticate to run Terraform

The service account has been granted the required roles to execute the Terraform code, but to make sure Terraform is
executed as that service account, some steps need to be followed.

An option is to use something like Terraform Cloud, in which case you should check how to authenticate your workspace.
See [this blog](https://cloud.google.com/blog/products/devops-sre/infrastructure-as-code-with-terraform-and-identity-federation)
and [this documentation](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/workload-identity-tokens)
for information to put you on the right path.

When using a pipeline (GitHub, Gitlab, etc.), Workload Identity Federation should be set up.
See [this](https://github.com/google-github-actions/auth)
and [this](https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions)
for an example for GitHub.

When planning and applying from a local machine, credentials should be set up to impersonate the service account (in
this case you have to make sure you have the "roles/iam.serviceAccountTokenCreator" role on the service account). This
can be done by executing this command:

```
export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com
```

See [this blog](https://cloud.google.com/blog/topics/developers-practitioners/using-google-cloud-service-account-impersonation-your-terraform-code)
for more information.

:warning: The next method should only be done as a last ditch effort if no other method is applicable :warning:

If it is not possible to use any other authentication methods, you can follow these steps to use a service account key:

```
gcloud iam service-accounts keys create resources/key.json --iam-account="$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
```

Protect this key and do not commit the key to any repositories.
This key can be set using the `GOOGLE_CREDENTIALS` environment variable.

For other methods of authenticating,
see [this documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference.html).

### 9. [ADVANCED only] Give service account access to call the *Groups API*

If you want to make use of the built-in group management, follow these steps:

* Enable domain-wide delegation on the service account `$TF_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com` in the
  Terraform master project by
  following [this guide](https://cloud.google.com/identity/docs/how-to/setup#configure_service_account) to tick the
  checkbox, configure the application name and save the changes.
* Note the `Client ID` in the domain-wide delegation settings
* Add scopes this `Client ID` in the Admin Console:

    - Go to https://admin.google.com
    - Click `Security` > `Access and data controls`  > `API controls` > `MANAGE DOMAIN-WIDE DELEGATION`
    - Click `Add new`
    - fill in `Client ID` field
    - fill in `Scope` field:

      ```
      https://www.googleapis.com/auth/admin.directory.group,
      https://www.googleapis.com/auth/apps.groups.settings,
      https://www.googleapis.com/auth/admin.directory.user,
      https://www.googleapis.com/auth/admin.directory.userschema
      ```

    - Click `Authorize`.

### 10. Backport IAM grants

In set-up step 7, we manually granted the Terraform SA some roles at organization level.

The **basic** module does not manage IAM policy for organizations. Therefore, the IAM grants from set-up step 7
*need not* be backported. You only need to reference the SA in case you want to manage it via Terraform in the
future.

The **advanced** module manages IAM policy for organizations in authoritative manner. Therefore, the advanced module
configuration you write **must** include (backport) the roles granted manually in set-up step 7. An example is
available in [`iam-advanced-admin` sample deployment][backport_iam].

[backport_iam]: https://github.com/devoteamgcloud/tf-gcp-foundation-samples-iam/tree/main/iam-advanced-admin

It contains the roles granted above:

```shell
"roles/resourcemanager.organizationAdmin"
"roles/iam.serviceAccountAdmin"
"roles/compute.xpnAdmin"
"roles/storage.admin"
"roles/workforcePoolAdmin"
"roles/iam.workloadIdentityPoolAdmin"
"roles/artifactregistry.admin"
"roles/serviceusage.serviceUsageViewer"
"roles/iam.organizationRoleAdmin"
```

### 11. Apply terraform

Now the SA is ready to be used by Terraform! Check
the [Sample implementations](https://github.com/devoteamgcloud/tf-gcp-foundation-samples-iam) for deployed examples.

## Separation of ADMIN and OPS (advanced only)

We recommend using a separate bucket & tfvars file to create all other service accounts for the master terraform SA's
for Resource Manager & VPC. Please see the examples. The above service account could be used to access both remote state
files and apply all policies, or you can create 2 separate SA's, each with access only to the dedicated bucket for admin
service account management (the SA used by terraform Resource Manager and VPC) and the other for general
day-to-day policies.

An idea to make sure the lower level IAM repositories can't do organization level IAM grants while still easily giving
them access on all folders and projects in the organization, consider using the following roles:

```shell
"roles/resourcemanager.folderIamAdmin"
"roles/resourcemanager.projectIamAdmin"
"roles/iam.serviceAccountAdmin"
"roles/compute.xpnAdmin"
"roles/artifactregistry.admin"
"roles/iam.workloadIdentityPoolAdmin"
"roles/serviceusage.serviceUsageViewer"
```

## Required GCP IAM role table

| IAM Module                    |              Required Role              | Basic | Advanced |
|-------------------------------|:---------------------------------------:|:-----:|:--------:|
| Project IAM bindings *        |  roles/resourcemanager.projectIamAdmin  |   x   |    x     |
| Folder IAM bindings *         |  roles/resourcemanager.folderIamAdmin   |   x   |    x     |
| Service Accounts              |      roles/iam.serviceAccountAdmin      |   x   |    x     |
| Service Agents                |  roles/serviceusage.serviceUsageViewer  |   x   |    x     |
| Organisation IAM bindings     | roles/resourcemanager.organizationAdmin |       |    x     |
| VPC Subnet IAM bindings       |         roles/compute.xpnAdmin          |       |    x     |
| Terraform State Buckets       |           roles/storage.admin           |       |    x     |
| Artifact Registry IAM         |      roles/artifactregistry.admin       |       |    x     |
| Workload Identity Federation  |   roles/iam.workloadIdentityPoolAdmin   |       |    x     |
| Workforce Identity Federation |      roles/iam.workforcePoolAdmin       |       |    x     |
| Organization Custom Roles     |     roles/iam.organizationRoleAdmin     |       |    x     |
| Project Custom Roles **       |           roles/iam.roleAdmin           |       |    x     |

\* If granting the organization admin role, this role is no longer required

\** If granting the organization role admin role, this role is no longer required

## Note on referencing existing Service Accounts and Groups

The Service Accounts have a field `create=`. This field is by default set to `true`. When set to `true`, Terraform will
create and manage this SA. If you're referencing an existing SA, set this field to `false`. An example of this is when
referencing the manually created SA necessary to start this module. Groups in the advanced module have this same field,
allowing creation of new groups. Note that since the basic module will not manage groups, it will never create new
groups and as a result does not have this field.
