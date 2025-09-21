module "folder_iam_audit_config" {
  source = "../../iam_folder_audit_config"

  folder_id                 = var.folder_id
  audit_log_config_log_type = var.audit_log_config_log_type
  service                   = var.service

  exempted_members = var.exempted_members
}
