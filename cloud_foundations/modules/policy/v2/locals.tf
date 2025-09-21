locals {
  type   = var.org_id != null ? "ORG" : var.folder_id != null ? "FOLDER" : var.project_id != null ? "PROJECT" : "INVALID"
  parent = local.type == "ORG" ? "organizations/${var.org_id}" : local.type == "FOLDER" ? "folders/${var.folder_id}" : local.type == "PROJECT" ? "projects/${var.project_id}" : "INVALID"
  name   = "${local.parent}/policies/${var.constraint}"
}
