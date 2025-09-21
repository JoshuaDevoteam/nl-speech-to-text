resource "google_organization_iam_binding" "project" {
  for_each = local.org_bindings

  org_id  = var.org_id
  role    = each.key
  members = each.value
}
