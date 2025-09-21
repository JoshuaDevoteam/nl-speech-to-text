resource "google_folder_iam_audit_config" "folder" {

  folder  = var.folder_id
  service = var.service

  dynamic "audit_log_config" {
    for_each = var.audit_log_config_log_type
    content {
      log_type         = audit_log_config.value
      exempted_members = var.exempted_members
    }
  }
}
