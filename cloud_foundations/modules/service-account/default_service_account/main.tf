resource "google_project_default_service_accounts" "default" {
  project        = var.project
  action         = var.action
  restore_policy = var.restore_policy
}
