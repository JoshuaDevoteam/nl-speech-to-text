resource "google_artifact_registry_repository_iam_binding" "artifact_registry_binding" {
  for_each   = var.artifact_registry_role_group_map
  project    = google_artifact_registry_repository.repository.project
  location   = google_artifact_registry_repository.repository.location
  repository = google_artifact_registry_repository.repository.name
  role       = each.key
  members    = each.value[*]
}