module "pool_label" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0
  namespace = "wlpool"
  context   = module.this.context
}

resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = module.pool_label.id
  display_name              = coalesce(var.display_name, module.pool_label.id)
  description               = "Identity pool for automated test"
  disabled                  = !var.workload_enabled
  project                   = var.project_id
}

module "provider_labels" {
  for_each = var.workload_providers
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace = "wlprov"
  name      = each.key
  context   = module.this.context
}

resource "google_iam_workload_identity_pool_provider" "providers" {
  for_each = var.workload_providers

  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = module.provider_labels[each.key].id
  display_name                       = coalesce(each.value.display_name, module.provider_labels[each.key].id)
  description                        = each.value.description
  disabled                           = !each.value.enabled
  attribute_condition                = each.value.attribute_condition
  attribute_mapping                  = each.value.attribute_mapping
  project                            = var.project_id
  dynamic "aws" {
    for_each = each.value.aws_account_id[*]
    content {
      account_id = each.value.aws_account_id
    }
  }
  dynamic "oidc" {
    for_each = each.value.oidc[*]
    content {
      allowed_audiences = oidc.value.allowed_audiences
      issuer_uri        = oidc.value.issuer_uri
      jwks_json         = oidc.value.jwks_json
    }
  }
  dynamic "saml" {
    for_each = each.value.saml[*]
    content {
      idp_metadata_xml = data.google_secret_manager_secret_version.idp_metadata_xml[each.key].secret_data
    }
  }

  lifecycle {
    ignore_changes = [
      saml.0.idp_metadata_xml
    ]
  }
}

data "google_secret_manager_secret_version" "idp_metadata_xml" {
  for_each = { for k, v in var.workload_providers : k => v.saml if v.saml != null }

  project = each.value.secret_project
  secret  = each.value.secret
  version = each.value.secret_version
}
