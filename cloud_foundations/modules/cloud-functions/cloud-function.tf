resource "google_cloudfunctions_function" "function" {
  project = var.project_id

  name        = var.cloud_function_name
  region      = var.region
  runtime     = var.cloud_function_runtime
  description = var.cloud_function_description

  available_memory_mb   = var.cloud_function_available_memory_mb
  timeout               = var.cloud_function_timeout
  entry_point           = var.cloud_function_entry_point
  environment_variables = var.environment_variables
  labels                = var.cloud_function_labels
  service_account_email = var.service_account_email
  # if cloud_function_source_type is "BUCKET" source archive comes from cloud storage bucket
  source_archive_object = var.cloud_function_source_type == "BUCKET" ? var.cloud_function_source_archive_object : null
  source_archive_bucket = var.cloud_function_source_type == "BUCKET" ? var.cloud_function_source_archive_bucket : null

  # elif cloud_function_source_type is "REPOSITORY" source comes from a repository
  dynamic "source_repository" {
    for_each = var.cloud_function_source_type == "REPOSITORY" ? [1] : []
    content {
      url = var.cloud_function_source_repository_url
    }
  }

  # if cloud_function_trigger_type is "HTTP", then create an http-triggered cloud function
  trigger_http = var.cloud_function_trigger_type == "HTTP" ? true : null

  # elif cloud_function_trigger_type is "EVENT", then create an event-triggered cloud function
  dynamic "event_trigger" {
    for_each = var.cloud_function_trigger_type == "EVENT" ? [1] : []
    content {
      event_type = var.cloud_function_event_type
      resource   = var.cloud_function_resource

      failure_policy {
        retry = var.cloud_function_failure_policy_retry
      }
    }
  }
}
