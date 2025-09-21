module "default_service_account" {
  source = "../../../default_service_account"

  project        = var.project
  action         = var.action
  restore_policy = var.restore_policy
}
