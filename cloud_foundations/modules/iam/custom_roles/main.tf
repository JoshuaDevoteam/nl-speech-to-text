resource "google_organization_iam_custom_role" "org_role" {
  count = contains(["org", "organization", "organisation"], lower(var.type)) ? 1 : 0

  org_id      = var.org_id
  permissions = var.permissions
  role_id     = var.role_id
  title       = var.title
  description = var.description
  stage       = upper(var.stage)
}

resource "google_project_iam_custom_role" "project_role" {
  count = contains(["project"], lower(var.type)) ? 1 : 0

  permissions = var.permissions
  role_id     = var.role_id
  title       = var.title
  project     = var.project
  description = var.description
  stage       = upper(var.stage)
}
