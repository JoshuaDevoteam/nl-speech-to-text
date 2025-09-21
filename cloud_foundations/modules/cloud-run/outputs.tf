output "name" {
  value       = google_cloud_run_v2_service.service.name
  description = "Cloud Run service name"
}

output "location" {
  value       = google_cloud_run_v2_service.service.location
  description = "Cloud Run service location"
}


output "url" {
  value       = google_cloud_run_v2_service.service.uri
  description = "Cloud Run service URL"
}