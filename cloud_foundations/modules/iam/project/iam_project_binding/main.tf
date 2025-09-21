resource "google_project_iam_binding" "project" {
  for_each = local.project_bindings

  project = var.project_id

  role    = each.key
  members = each.value
}
