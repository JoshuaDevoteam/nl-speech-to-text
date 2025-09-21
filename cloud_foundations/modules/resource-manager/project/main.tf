module "labels" {
  for_each = var.projects
  source   = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace        = each.value.namespace
  name             = coalesce(each.value.name, each.key)
  tenant           = each.value.tenant
  environment      = each.value.environment
  stage            = each.value.stage
  context          = module.this.context
  label_key_case   = "lower" # label keys have to be lower case cfr https://cloud.google.com/resource-manager/docs/creating-managing-labels#requirements
  label_value_case = "lower" # label values have to be lower case cfr https://cloud.google.com/resource-manager/docs/creating-managing-labels#requirements
  id_length_limit  = 30      # cfr https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin
  tags             = merge(var.labels, each.value.labels)
}

resource "google_project" "project" {
  #checkov:skip=CKV2_GCP_5: "Ensure that Cloud Audit Logging is configured properly across all services and all users from a project"
  for_each            = var.projects
  name                = module.labels[each.key].id
  project_id          = each.value.project_id != null ? each.value.project_id : module.labels[each.key].id
  folder_id           = var.parent_folder
  billing_account     = var.billing_account
  auto_create_network = false

  labels = module.labels[each.key].tags
}
