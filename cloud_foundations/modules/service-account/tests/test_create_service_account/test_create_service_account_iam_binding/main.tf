module "service_account_iam_binding" {
  source = "../../../service_account_iam_binding"

  project      = var.project
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
  disabled     = var.disabled
  bindings     = var.bindings
}
