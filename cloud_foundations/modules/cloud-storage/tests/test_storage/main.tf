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
  logging_bucket              = ""
}


output "bucket_url" {
  value       = module.bucket.bucket_url
  description = "The GCS bucket's URL"
}
