output "name" {
  value       = google_cloud_run_v2_job.job.name
  description = "Cloud Run job name"
}

output "id" {
  value       = google_cloud_run_v2_job.job.id
  description = "Cloud Run job id"
}

output "location" {
  value       = google_cloud_run_v2_job.job.location
  description = "Cloud Run job location"
}
