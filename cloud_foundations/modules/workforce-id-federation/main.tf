module "pool_label" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  namespace   = module.this.namespace == null ? "wfpool" : module.this.namespace
  label_order = module.this.label_order == null ? ["namespace", "name"] : module.this.label_order
  context     = module.this.context
}

resource "google_iam_workforce_pool" "pool" {
  workforce_pool_id = module.pool_label.id
  parent            = "organizations/${var.org_id}"
  location          = "global"
  display_name      = var.display_name == "" ? module.pool_label.id : var.display_name
  description       = var.description
  disabled          = !var.workforce_enabled
  session_duration  = var.session_duration
}

module "provider_labels" {
  for_each = var.workforce_providers

  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace   = each.value.prefix
  name        = each.key
  label_order = each.value.null_label_order

  context = module.this.context
}

resource "google_iam_workforce_pool_provider" "provider" {
  for_each = var.workforce_providers

  workforce_pool_id   = google_iam_workforce_pool.pool.workforce_pool_id
  location            = google_iam_workforce_pool.pool.location
  provider_id         = module.provider_labels[each.key].id
  attribute_mapping   = each.value.attribute_mapping
  display_name        = each.value.display_name == null ? module.provider_labels[each.key].id : each.value.display_name
  description         = each.value.description
  disabled            = !each.value.enabled
  attribute_condition = each.value.attribute_condition

  saml {
    idp_metadata_xml = data.google_secret_manager_secret_version.idp_metadata_xml[each.key].secret_data
  }

  lifecycle {
    ignore_changes = [
      saml.0.idp_metadata_xml
    ]
  }
}

data "google_secret_manager_secret_version" "idp_metadata_xml" {
  for_each = var.workforce_providers

  project = each.value.secret_project
  secret  = each.value.secret
  version = each.value.secret_version
}
