resource "google_project_iam_audit_config" "project" {
  for_each = var.audit_log_config_log_type

  project = var.project_id
  service = var.service

  audit_log_config {
    log_type         = each.value
    exempted_members = var.exempted_members
  }
}
