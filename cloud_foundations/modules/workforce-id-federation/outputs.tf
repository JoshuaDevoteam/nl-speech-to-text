output "workforce_pool_id" {
  value       = google_iam_workforce_pool.pool.id
  description = "The id of the Workforce pool with format locations/{{location}}/workforcePools/{{workforce_pool_id}}"
}

output "workforce_pool_state" {
  value       = google_iam_workforce_pool.pool.state
  description = "The state of the Workforce pool"
}

output "workforce_provider_ids" {
  value       = { for k, v in google_iam_workforce_pool_provider.provider : k => v.id }
  description = "A map of all Workforce provider ids with format locations/{{location}}/workforcePools/{{workforce_pool_id}}/providers/{{provider_id}}"
}

output "workforce_provider_states" {
  value       = { for k, v in google_iam_workforce_pool_provider.provider : k => v.state }
  description = "A map of all Workforce provider states"
}
