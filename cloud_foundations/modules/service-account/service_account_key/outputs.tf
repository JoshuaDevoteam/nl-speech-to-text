output "service_account_id" {
  value = google_service_account_key.key.service_account_id
}

output "public_key_type" {
  value = google_service_account_key.key.public_key_type
}

output "private_key_type" {
  value = google_service_account_key.key.private_key_type
}
