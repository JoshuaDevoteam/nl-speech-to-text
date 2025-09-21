module "service_account_key" {
  source = "../../../service_account_key"

  project            = var.project
  account_id         = var.account_id
  display_name       = var.display_name
  description        = var.description
  service_account_id = var.service_account_id
  private_key_type   = var.private_key_type
  disabled           = var.disabled
  public_key_type    = var.public_key_type
  rotation_days      = var.rotation_days
}
