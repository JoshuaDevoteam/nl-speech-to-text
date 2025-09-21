resource "google_service_account" "service_account" {
  #checkov:skip=CKV2_GCP_3: "Ensure that there are only GCP-managed service account keys for each service account"
  account_id   = var.account_id
  project      = var.project
  display_name = var.display_name
  description  = var.description
  disabled     = var.disabled
}

resource "google_service_account_iam_binding" "sa-account-iam" {
  for_each = local.sa_bindings

  service_account_id = google_service_account.service_account.name
  role               = each.key
  members            = each.value
}
