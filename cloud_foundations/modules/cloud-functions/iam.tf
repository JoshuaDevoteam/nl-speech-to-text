resource "google_cloudfunctions_function_iam_binding" "function_binding" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  for_each = var.iam_binding_role_group_map
  role     = each.key
  members  = each.value[*]
}
