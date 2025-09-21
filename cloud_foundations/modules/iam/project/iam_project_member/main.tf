resource "google_project_iam_member" "project" {
  for_each = var.role

  project = var.project_id
  role    = each.value
  member  = var.member
}
