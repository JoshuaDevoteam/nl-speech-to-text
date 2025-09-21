resource "google_service_account" "service_account" {
  account_id   = var.account_id
  project      = var.project
  display_name = var.display_name
  description  = var.description
  disabled     = var.disabled
}

resource "google_service_account_key" "key" {
  service_account_id = google_service_account.service_account.name
  public_key_type    = var.public_key_type
  private_key_type   = var.private_key_type

  keepers = {
    rotation_time = time_rotating.key_rotation.rfc3339
  }
}

resource "time_rotating" "key_rotation" {
  rotation_days = var.rotation_days
}
