# GCP VPC module

This module manages the objects related to Google Cloud networking.

There are two versions of the module: **basic** and **advanced**.

The **basic version** will manage networks, subnets, and firewalls.

The **advanced** version will have all the features of the basic version, and additionally manages interconnect, VPN,
peerings, shared VPC, DNS, NAT, private service access, private google APIs, routes, and network connectivity center hub
and spokes (only VPC spokes for now).

| Feature                      |  Basic  |  Advanced  |
|------------------------------|:-------:|:----------:|
| Networks                     |    x    |     x      |
| Subnets                      |    x    |     x      |
| Firewall                     |    x    |     x      |
| Interconnect                 |         |     x      |
| VPN                          |         |     x      |
| Peering                      |         |     x      |
| Shared VPC (XPN)             |         |     x      |
| DNS                          |         |     x      |
| NAT                          |         |     x      |
| Private Service Access (PSA) |         |     x      |
| Private Google APIs          |         |     x      |
| Routes                       |         |     x      |
| NCC hub and spokes (VPC)     |         |     x      |

## Required APIs
#TODO: fill this out
Several APIs will need to be enabled on projects in which you plan to create some VPC resources. A table listing some can be found below:

| API                                |  Basic  |  Advanced  |
|------------------------------------|:-------:|:----------:|
| compute.googleapis.com             |    x    |     x      |
| networkconnectivity.googleapis.com |         |     x      |

## Required Permissions

Depending on whether you're deploying the basic or advanced version, the Service Account needs specific IAM grants on
the GPC Organization.
These should have been granted using the IAM module of the Cloud Foundations repository, an example can be
found [here](https://github.com/devoteamgcloud/tf-gcp-foundation-samples-iam/blob/e038af4db3316f3599e3cc2d8e3382ff97cb3aeb/iam-advanced-admin/sample.auto.tfvars#L155).

| IAM Role                             |  Basic  |  Advanced  |
|--------------------------------------|:-------:|:----------:|
| roles/compute.networkAdmin           |    x    |     x      |
| roles/compute.securityAdmin          |    x    |     x      |
| roles/compute.networkUser            |         |     x      |
| roles/dns.admin                      |         |     x      |
| roles/servicedirectory.editor        |         |     x      |
| roles/compute.xpnAdmin               |         |     x      |
| roles/serviceusage.serviceUsageAdmin |         |     x      |
| roles/networkconnectivity.hubAdmin   |         |     x      |

### IAM roles

The IAM admin module on the Basic level must have already run, so that the Service Account (SA) has been created.
When using the basic package, access to resource creation roles needs to be given to the SA manually.
This can be done through the console, or by following the extra steps for basic package below.

When using the Advanced module, the Service Account and the Organization-level IAM bindings should have been created
so that the admins can retrieve a key for the Service Account.

### Terraform state bucket

If using the basic package, you will need to create a new bucket in the same way as how you created one for the IAM
module.
In that case, follow the extra steps for basic package below.

If using the advanced package, the IAM admin module should also already have been used to create a GCS
bucket for the terraform state of this module, and given the related SA access to write to the bucket.

## Setup

### 1. Variables

replace the below variables accordingly. To retrieve *Organization ID* using the command below. This command will show a
table with all domains where your user account has access on. The *Organization ID* is the `ID` column. It's required
in Step 3 below for the Basic module.

```shell
gcloud organizations list
```

**Replace all exported variables accordingly.**

```shell
export TF_SA_VPC="sa-cf-tf-basic-vpc@pj-cf-basic-terraform-master.iam.gserviceaccount.com"
```

### 2. Download the key for the SA

```shell
gcloud iam service-accounts keys create resources/key.json --iam-account=$TF_SA_VPC
```

### 3. [BASIC ONLY] Extra steps

To grant the service account created by the IAM module the necessary organization level access, use following commands.
**Replace all exported variables accordingly.**

```shell
export ORG_ID=132905988165
export PROJECT_ID=pj-cf-basic-terraform-master
export TF_ROOT_STATE_BUCKET_VPC=cf-basic-vpc-tf-state

gcloud storage buckets create gs://$TF_ROOT_STATE_BUCKET_VPC --location EU --project $PROJECT_ID
gcloud storage buckets update gs://$TF_ROOT_STATE_BUCKET_VPC --versioning
gcloud storage buckets add-iam-policy-binding gs://$TF_ROOT_STATE_BUCKET_VPC --member="serviceAccount:${TF_SA_VPC}" --role="roles/storage.objectAdmin"

gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_VPC" \
--role="roles/compute.networkAdmin"

gcloud organizations add-iam-policy-binding $ORG_ID \
--member="serviceAccount:$TF_SA_VPC" \
--role="oles/compute.securityAdmin" #required for firewalls
```

An example .tfvars file can be found
here: [sample implementation](https://github.com/devoteamgcloud/tf-gcp-foundation-samples-vpc/blob/main/advanced/sample.auto.tfvars)
