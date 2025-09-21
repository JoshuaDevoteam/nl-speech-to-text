# is needed?

resource "google_cloud_run_service_iam_member" "member" {
  for_each = var.iam

  location = var.location
  project  = var.project
  service  = google_cloud_run_v2_service.service.name
  role     = each.value.role
  member   = each.value.member
}