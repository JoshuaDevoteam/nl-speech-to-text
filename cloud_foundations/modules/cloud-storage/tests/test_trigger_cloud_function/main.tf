variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "bucket_storage_class" {
  type = string
}

variable "bucket_force_destroy" {
  type = bool
}

variable "bucket_uniform_level_access" {
  type = string
}

variable "iam_binding_role_group_map" {
  type = map(list(string))
}

variable "cloud_function_name" {
  type = string
}

variable "cloud_function_runtime" {
  type = string
}

variable "cloud_function_timeout" {
  type = number
}

variable "cloud_function_available_memory_mb" {
  type = number
}

variable "cloud_function_entry_point" {
  type = string
}

variable "cloud_function_source_type" {
  type = string
}

variable "cloud_function_source_repository_url" {
  type = string
}

variable "cloud_function_event_type" {
  type = string
}

variable "cloud_function_failure_policy_retry" {
  type = bool
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "bucket" {
  source                      = "../../../tf-gcp-cloud-storage"
  project_id                  = var.project_id
  bucket_name                 = var.bucket_name
  bucket_location             = var.region
  bucket_storage_class        = var.bucket_storage_class
  bucket_force_destroy        = var.bucket_force_destroy
  bucket_uniform_level_access = var.bucket_uniform_level_access
  iam_binding_role_group_map  = var.iam_binding_role_group_map

  cloud_function_name        = var.cloud_function_name
  cloud_function_description = "Trigger DAG with GCS"

  cloud_function_runtime             = var.cloud_function_runtime
  cloud_function_timeout             = var.cloud_function_timeout
  cloud_function_available_memory_mb = var.cloud_function_available_memory_mb

  cloud_function_entry_point = var.cloud_function_entry_point

  cloud_function_source_type           = var.cloud_function_source_type
  cloud_function_source_repository_url = var.cloud_function_source_repository_url

  cloud_function_event_type = var.cloud_function_event_type
  cloud_function_resource   = module.bucket.bucket_id

  cloud_function_failure_policy_retry = var.cloud_function_failure_policy_retry

}

output "bucket_url" {
  value       = module.bucket.bucket_url
  description = "The GCS bucket's URL"
}

output "cloud_function" {
  value       = module.bucket.cloud_function_id[0]
  description = "Cloud function id that is triggered by GCS"
}
