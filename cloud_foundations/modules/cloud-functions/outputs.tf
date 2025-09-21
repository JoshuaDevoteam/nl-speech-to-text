output "cloud_function_id" {
  value = google_cloudfunctions_function.function.id
}

output "cloud_function_https_trigger_url" {
  value = google_cloudfunctions_function.function.https_trigger_url
}

output "cloud_function_source_repository" {
  value = google_cloudfunctions_function.function.source_repository
}

output "cloud_function_project" {
  value = google_cloudfunctions_function.function.project
}

output "cloud_function_region" {
  value = google_cloudfunctions_function.function.region
}
