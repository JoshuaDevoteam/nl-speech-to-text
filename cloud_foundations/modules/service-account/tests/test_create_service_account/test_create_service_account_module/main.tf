module "service_account" {
  source = "../../../service_account"

  project      = var.project
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
  disabled     = var.disabled
}
