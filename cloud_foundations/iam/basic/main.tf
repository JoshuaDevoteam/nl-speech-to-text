module "service_accounts" {
  for_each = {
    for sa_name, sa in local.service_accounts : sa_name => sa if sa.create
  }

  source = "../../modules/service-account/service_account"

  project      = each.value.gcp_project_id
  display_name = each.value.display_name
  description  = each.value.description
  disabled     = each.value.disabled

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = lookup(each.value, "tenant", null)
  environment = lookup(each.value, "environment", null)
  stage       = lookup(each.value, "stage", null)
  name        = lookup(each.value, "name", null)
  attributes  = lookup(each.value, "attributes", null)
  label_order = lookup(each.value, "label_order", null)
  context     = module.this.context

}

module "service_accounts_policy" {
  for_each = local.service_account_bindings

  source = "../../modules/service-account/service_account_policy"

  service_account_id   = each.value.service_account_id
  bindings             = each.value.bindings
  conditional_bindings = each.value.conditional_bindings
}

module "folder" {
  for_each = local.folder_bindings

  source = "../../modules/iam/folder/iam_folder_policy"

  folder_id            = each.value.folder_id
  bindings             = each.value.bindings
  conditional_bindings = each.value.conditional_bindings
}

module "projects" {
  for_each = local.project_bindings

  source = "../../modules/iam/project/iam_project_policy"

  project_id           = each.value.project_id
  bindings             = each.value.bindings
  conditional_bindings = each.value.conditional_bindings

  depends_on = [
    google_project_service_identity.serviceagents_service_account
  ]
}

module "bucket" {
  for_each = var.tfstates

  source = "../../modules/cloud-storage"

  project_id               = each.value.project
  bucket_location          = each.value.location
  bucket_object_versioning = true

  environment = "tf-state"
  tenant      = lookup(each.value, "tenant", null)
  stage       = lookup(each.value, "stage", null)
  name        = lookup(each.value, "name", null)
  attributes  = lookup(each.value, "attributes", null)
  label_order = lookup(each.value, "label_order", null)
}

module "iam_bucket" {
  for_each = local.tfstate_bucket_bindings

  source = "../../modules/iam/bucket"

  bucket   = each.value.bucket
  bindings = each.value.bindings
  #   conditional_bindings = each.value.conditional_bindings
}
