output "workload_pool_name" {
  value       = google_iam_workload_identity_pool.pool.name
  description = "The name of the Workload Identity pool with format projects/{project_number}/locations/global/workloadIdentityPools/{workload_identity_pool_id}"
}

output "workload_pool_state" {
  value       = google_iam_workload_identity_pool.pool.state
  description = "The state of the Workload Identity pool"
}

output "workload_provider_names" {
  value       = { for k, v in google_iam_workload_identity_pool_provider.providers : k => v.name }
  description = "A map of all Workload Identity provider names with format projects/{project_number}/locations/global/workloadIdentityPools/{workload_identity_pool_id}/providers/{workload_identity_pool_provider_id}"
}

output "workload_provider_states" {
  value       = { for k, v in google_iam_workload_identity_pool_provider.providers : k => v.state }
  description = "A map of all Workload Identity provider states"
}
