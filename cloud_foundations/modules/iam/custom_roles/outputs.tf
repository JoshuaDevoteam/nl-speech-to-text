output "role_name" {
  value = contains(["org", "organization", "organisation"], lower(var.type)) ? google_organization_iam_custom_role.org_role[0].name : google_project_iam_custom_role.project_role[0].name
}
