module "service_account_iam_member" {
  source = "../../../service_account_iam_member"

  project      = var.project
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
  disabled     = var.disabled
  member       = var.member
  role         = var.role
}
