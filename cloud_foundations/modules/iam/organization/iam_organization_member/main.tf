resource "google_organization_iam_member" "project" {
  for_each = var.role

  org_id = var.org_id
  role   = each.value
  member = var.member
}
