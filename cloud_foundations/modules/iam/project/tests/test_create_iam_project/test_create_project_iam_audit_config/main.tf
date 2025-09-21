module "project_iam_audit_config" {
  source = "../../../iam_project_audit_config"

  project_id                = var.project_id
  audit_log_config_log_type = var.audit_log_config_log_type
  service                   = var.service

  exempted_members = var.exempted_members
}
