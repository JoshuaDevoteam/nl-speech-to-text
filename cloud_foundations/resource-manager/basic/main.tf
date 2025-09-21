module "folders_root" {
  for_each = var.resources_root
  source   = "../../modules/resource-manager/folder"
  parent   = var.resources_root_folder_id == null ? "organizations/${var.gcp_organisation}" : "folders/${var.resources_root_folder_id}"
  name     = each.value.folder_name

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = each.value.tenant
  environment = each.value.environment
  stage       = each.value.stage
  attributes  = each.value.attributes
  label_order = each.value.label_order
  context     = module.this.context
}

module "projects_in_folder_root" {
  for_each        = var.resources_root
  source          = "../../modules/resource-manager/project"
  projects        = try(each.value.projects, {})
  billing_account = var.billing_account
  parent_folder   = trimprefix(module.folders_root[each.key].folder_id, "folders/")

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant         = each.value.tenant
  environment    = each.value.environment
  stage          = each.value.stage
  attributes     = each.value.attributes
  label_order    = each.value.label_order
  labels_as_tags = each.value.labels_as_tags
  context        = module.this.context

  labels = each.value.labels
}

module "folders_l1" {
  for_each = var.resources_l1
  source   = "../../modules/resource-manager/folder"
  parent   = module.folders_root[each.value.parent_folder].folder_id
  name     = each.value.folder_name

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = each.value.tenant
  environment = each.value.environment
  stage       = each.value.stage
  attributes  = each.value.attributes
  label_order = each.value.label_order
  context     = module.this.context
}
module "projects_in_folder_l1" {
  for_each        = var.resources_l1
  source          = "../../modules/resource-manager/project"
  projects        = try(each.value.projects, {})
  billing_account = var.billing_account
  parent_folder   = trimprefix(module.folders_l1[each.key].folder_id, "folders/")

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant         = each.value.tenant
  environment    = each.value.environment
  stage          = each.value.stage
  attributes     = each.value.attributes
  label_order    = each.value.label_order
  labels_as_tags = each.value.labels_as_tags
  context        = module.this.context

  labels = each.value.labels
}
module "folders_l2" {
  for_each = var.resources_l2
  source   = "../../modules/resource-manager/folder"
  parent   = module.folders_l1[each.value.parent_folder].folder_id
  name     = each.value.folder_name

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = each.value.tenant
  environment = each.value.environment
  stage       = each.value.stage
  attributes  = each.value.attributes
  label_order = each.value.label_order
  context     = module.this.context
}
module "projects_in_folder_l2" {
  for_each        = var.resources_l2
  source          = "../../modules/resource-manager/project"
  projects        = try(each.value.projects, {})
  billing_account = var.billing_account
  parent_folder   = trimprefix(module.folders_l2[each.key].folder_id, "folders/")

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant         = each.value.tenant
  environment    = each.value.environment
  stage          = each.value.stage
  attributes     = each.value.attributes
  label_order    = each.value.label_order
  labels_as_tags = each.value.labels_as_tags
  context        = module.this.context

  labels = each.value.labels
}
module "folders_l3" {
  for_each = var.resources_l3
  source   = "../../modules/resource-manager/folder"
  parent   = module.folders_l2[each.value.parent_folder].folder_id
  name     = each.value.folder_name

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = each.value.tenant
  environment = each.value.environment
  stage       = each.value.stage
  attributes  = each.value.attributes
  label_order = each.value.label_order
  context     = module.this.context
}
module "projects_in_folder_l3" {
  for_each        = var.resources_l3
  source          = "../../modules/resource-manager/project"
  projects        = try(each.value.projects, {})
  billing_account = var.billing_account
  parent_folder   = trimprefix(module.folders_l3[each.key].folder_id, "folders/")

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant         = each.value.tenant
  environment    = each.value.environment
  stage          = each.value.stage
  attributes     = each.value.attributes
  label_order    = each.value.label_order
  labels_as_tags = each.value.labels_as_tags
  context        = module.this.context

  labels = each.value.labels
}
module "folders_l4" {
  for_each = var.resources_l4
  source   = "../../modules/resource-manager/folder"
  parent   = module.folders_l3[each.value.parent_folder].folder_id
  name     = each.value.folder_name

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = each.value.tenant
  environment = each.value.environment
  stage       = each.value.stage
  attributes  = each.value.attributes
  label_order = each.value.label_order
  context     = module.this.context
}
module "projects_in_folder_l4" {
  for_each        = var.resources_l4
  source          = "../../modules/resource-manager/project"
  projects        = try(each.value.projects, {})
  billing_account = var.billing_account
  parent_folder   = trimprefix(module.folders_l4[each.key].folder_id, "folders/")

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant         = each.value.tenant
  environment    = each.value.environment
  stage          = each.value.stage
  attributes     = each.value.attributes
  label_order    = each.value.label_order
  labels_as_tags = each.value.labels_as_tags
  context        = module.this.context

  labels = each.value.labels
}
module "folders_l5" {
  for_each = var.resources_l5
  source   = "../../modules/resource-manager/folder"
  parent   = module.folders_l4[each.value.parent_folder].folder_id
  name     = each.value.folder_name

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant      = each.value.tenant
  environment = each.value.environment
  stage       = each.value.stage
  attributes  = each.value.attributes
  label_order = each.value.label_order
  context     = module.this.context
}
module "projects_in_folder_l5" {
  for_each        = var.resources_l5
  source          = "../../modules/resource-manager/project"
  projects        = try(each.value.projects, {})
  billing_account = var.billing_account
  parent_folder   = trimprefix(module.folders_l5[each.key].folder_id, "folders/")

  #namespace forced by module - no need in passing as will be overwritten anyway.
  #to avoid using namespace, supply a custom label_order excluding it.
  tenant         = each.value.tenant
  environment    = each.value.environment
  stage          = each.value.stage
  attributes     = each.value.attributes
  label_order    = each.value.label_order
  labels_as_tags = each.value.labels_as_tags
  context        = module.this.context

  labels = try(each.value.labels, {})
}

module "apis" {
  for_each = local.apis_combined
  source   = "../../modules/resource-manager/apis"

  project_id         = each.key
  services           = each.value
  disable_on_destroy = var.disable_api_on_destroy

  depends_on = [
    module.projects_in_folder_root,
    module.projects_in_folder_l1,
    module.projects_in_folder_l2,
    module.projects_in_folder_l3,
    module.projects_in_folder_l4,
    module.projects_in_folder_l5
  ]
}
