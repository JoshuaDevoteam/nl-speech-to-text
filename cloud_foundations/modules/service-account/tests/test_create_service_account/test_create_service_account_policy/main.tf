module "service_account_policy" {
  source = "../../../service_account_policy"

  project      = var.project
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
  disabled     = var.disabled
  bindings     = var.bindings
}
