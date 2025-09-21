variable "project_id" {
  type        = string
  description = "ID of the project."

  validation {
    condition     = can(regex("^[a-z][a-z0-9 -]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Must be letters, digits, hyphens or spaces. Must start with a letter and end with a letter or number. Must be between 6 and 30 characters."
  }
}

variable "region" {
  type        = string
  description = "The region where the Cloud Function will be deployed"
}

variable "cloud_function_name" {
  type        = string
  description = "(Required) A user-defined name of the function. Function names must be unique globally."
}

variable "cloud_function_runtime" {
  type        = string
  description = "(Required) The runtime in which the function is going to run. Eg. nodejs10, nodejs12, nodejs14, python37, python38, python39, dotnet3, go113, java11, ruby27, etc. Check the official doc for the up-to-date list."
}

variable "cloud_function_timeout" {
  type        = number
  description = "(Optional) Timeout (in seconds) for the function. Default value is 60 seconds. Cannot be more than 540 seconds."
  default     = 60
}

variable "cloud_function_description" {
  type        = string
  description = "(Optional) Description of the function."
}

variable "cloud_function_available_memory_mb" {
  type        = number
  description = "(Optional) Memory (in MB), available to the function. Default value is 256. Possible values include 128, 256, 512, 1024, etc."
  default     = 256
}

variable "cloud_function_entry_point" {
  type        = string
  description = "(Optional) Name of the function that will be executed when the Google Cloud Function is triggered."
}

variable "cloud_function_source_archive_bucket" {
  type        = string
  description = "(Optional) The GCS bucket containing the zip archive which contains the function."
  default     = null
}

variable "cloud_function_source_archive_object" {
  type        = string
  description = "(Optional) The source archive object (file) in archive bucket."
  default     = null
}

variable "cloud_function_source_repository_url" {
  type        = string
  description = "(Optional) Represents the URL pointing to a source repository where a function is hosted."
  default     = null
}

variable "cloud_function_event_type" {
  type        = string
  description = "(Required) The type of event to observe. For example: \"google.storage.object.finalize\". See the documentation on calling Cloud Functions for a full reference of accepted triggers."
  default     = null
}

variable "cloud_function_resource" {
  type        = string
  description = "(Required) The name or partial URI of the resource from which to observe events. For example, \"myBucket\" or \"projects/my-project/topics/my-topic\""
  default     = null
}

variable "cloud_function_failure_policy_retry" {
  type        = bool
  description = "(Required) Whether the function should be retried on failure. Defaults to false."
  default     = false
}

variable "cloud_function_source_type" {
  type        = string
  description = "(Required) Says whether the cloud function will take source code from a bucket or a repository."
  validation {
    condition     = can(regex("BUCKET|REPOSITORY", var.cloud_function_source_type))
    error_message = "Supported values for cloud_function_source_type include: BUCKET and REPOSITORY."
  }
}

variable "cloud_function_trigger_type" {
  type        = string
  description = "(Required) Says whether the cloud function will be triggered by an HTTP request or an event."
  validation {
    condition     = can(regex("HTTP|EVENT", var.cloud_function_trigger_type))
    error_message = "Supported values for cloud_function_trigger_type include: HTTP and EVENT."
  }
}

variable "iam_binding_role_group_map" {
  type        = map(list(string))
  description = "A map with each role as key and lists of members or groups as values."
  default     = {}
}

variable "cloud_function_labels" {
  type        = map(string)
  description = "(Optional) A label is a key-value pair in the form of a map that helps you organize your Google Cloud resources."
  default     = {}
}

variable "service_account_email" {
  type        = string
  description = "(Optional) If provided, the self-provided service account to run the function with"
  default     = null
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "(Optional) A set of key/value environment variable pairs to assign to the function."
}
