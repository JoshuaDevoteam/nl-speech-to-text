output "bucket_id" {
  value       = google_storage_bucket.bucket.id
  description = "The GCS bucket's ID."
}

output "bucket_url" {
  value       = google_storage_bucket.bucket.url
  description = "The GCS bucket's URL"
}

# output "cloud_function_id" {
#   value       = module.storage-triggered-function[*].cloud_function_id
#   description = "Cloud function id that is triggered by GCS"
# }
