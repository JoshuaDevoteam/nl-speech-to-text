#DOES NOT WORK SINCE IT"S A LOCAL REFERENCE TO CLOUD FUNCTION MODULE
//module "storage-triggered-function" {
//  count      = var.cloud_function_name != null ? 1 : 0
//  source     = "../tf-gcp-cloud-function"
//  project_id = var.project_id
//
//  cloud_function_name        = var.cloud_function_name
//  cloud_function_runtime     = var.cloud_function_runtime
//  cloud_function_description = var.cloud_function_description
//
//  cloud_function_available_memory_mb = var.cloud_function_available_memory_mb
//  cloud_function_timeout             = var.cloud_function_timeout
//  cloud_function_entry_point         = var.cloud_function_entry_point
//  cloud_env_variable                 = var.environment_variables
//  labels                             = var.cloud_function_labels
//
//  service_account_email = var.service_account_email
//
//  cloud_function_source_type           = var.cloud_function_source_type
//  cloud_function_source_repository_url = var.cloud_function_source_repository_url
//
//
//  cloud_function_trigger_type = var.cloud_function_trigger_type
//  cloud_function_event_type   = var.cloud_function_event_type
//  cloud_function_resource     = var.cloud_function_resource
//
//  # cloud_function_failure_policy_retry = var.cloud_function_failure_policy_retry
//}
