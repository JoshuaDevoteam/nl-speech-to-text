resource "google_service_account" "service_account" {
  #checkov:skip=CKV2_GCP_3: "Ensure that there are only GCP-managed service account keys for each service account"
  account_id   = var.account_id
  project      = var.project
  display_name = var.display_name
  description  = var.description
  disabled     = var.disabled
}

resource "google_service_account_iam_member" "sa-account-iam" {
  for_each = var.role

  service_account_id = google_service_account.service_account.name
  role               = each.value
  member             = var.member
}
