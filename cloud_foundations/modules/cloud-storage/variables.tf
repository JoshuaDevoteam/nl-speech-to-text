variable "project_id" {
  type        = string
  description = "ID of the project."

  validation {
    condition     = can(regex("^[a-z][a-z0-9 -]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Must be letters, digits, hyphens or spaces. Must start with a letter and end with a letter or number. Must be between 6 and 30 characters."
  }
}

variable "bucket_location" {
  type        = string
  description = "Location of the bucket created by this terraform module. You can select a region, dual-region, or multi-region."
  # TODO: how can I validate this? keep track of all the locations avaiable by google?
}

variable "bucket_storage_class" {
  type        = string
  description = "Storage class of the bucket created by this terraform module."
  default     = "STANDARD"

  validation {
    condition     = can(regex("STANDARD|MULTI_REGIONAL|REGIONAL|NEARLINE|COLDLINE|ARCHIVE", var.bucket_storage_class))
    error_message = "Supported values for bucket_storage_class include: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "bucket_force_destroy" {
  type        = bool
  description = "If set to true, when a bucket is deleted all contained objects are also deleted. If set to false, any bucket with objects inside will not be deleted."
  default     = false
}

variable "bucket_uniform_level_access" {
  type        = bool
  description = "Cloud Storage offers two systems for granting users permission to access your buckets and objects: IAM and Access Control Lists (ACLs). Enabling Uniform bucket-level access allows you to administer buckets using IAM."
  default     = true
}

variable "iam_binding_role_group_map" {
  type        = map(list(string))
  description = "A map with each role as key and lists of members or groups as values."
  default     = {}
  # TODO: Validation so that it only accepts groups? or is it better to leave it up to the user to decide on best practices?
}

variable "bucket_labels" {
  type        = map(string)
  description = "(Optional) A label is a key-value pair in the form of a map that helps you organize your Google Cloud resources."
  default     = {}
}

variable "bucket_object_versioning" {
  type        = bool
  description = "When set to true, objects versioning is enabled for this bucket."
  default     = true
}

variable "bucket_lifecycle_rules" {
  type = list(object({
    action    = any
    condition = any
  }))
  description = <<-EOT
  action:
    type: The type of action taken by the Lifecycle Rule. Possible values are: Delete and SetStorageClass.
    storage_class: (Required only for action type SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.
  condition:
    age: (Optional) Minimum age in days.
    created_before: (Optional) Object creation date in YYYY-MM-DD (a.k.a RFC 3339).
    with_state: (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".
    matches_storage_class: (Optional) Storage Class of objects to match on. Possible values: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.
    num_newer_versions: (Optional) Only for versioned objects; The total number of newer versions of an object to trigger the condition.
  EOT

  default = []
}

variable "website" {
  type = object({
    main_page_suffix = string
    not_found_page   = string
  })
  description = "(Optional) Website configuration for the bucket if it is used to host a static website."
  default     = null
}

variable "cors" {
  type = object({
    origin          = list(string)
    method          = list(string)
    response_header = list(string)
    max_age_seconds = number
  })
  description = "(Optional) CORS configuration for the bucket if it is used to host a static website."
  default     = null
}

variable "cloud_function_name" {
  type        = string
  description = "(Required) A user-defined name of the function. Function names must be unique globally."
  # TODO: regex validation on cloud_function_name
  default = null
}

variable "cloud_function_runtime" {
  type        = string
  description = "(Required) The runtime in which the function is going to run. Eg. nodejs10, nodejs12, nodejs14, python37, python38, python39, dotnet3, go113, java11, ruby27, etc. Check the official doc for the up-to-date list."
  # TODO: how do you validate this?
  default = null
}

variable "cloud_function_timeout" {
  type        = number
  description = "(Optional) Timeout (in seconds) for the function. Default value is 60 seconds. Cannot be more than 540 seconds."
  default     = 60
  # TODO: validate that it can't be greater than 540 seconds. Is there a minimum too?
}

variable "cloud_function_description" {
  type        = string
  description = "(Optional) Description of the function."
  default     = null
}

variable "cloud_function_available_memory_mb" {
  type        = number
  description = "(Optional) Memory (in MB), available to the function. Default value is 256. Possible values include 128, 256, 512, 1024, etc."
  default     = 256
  #TODO: validate
}

variable "cloud_function_entry_point" {
  type        = string
  description = "(Optional) Name of the function that will be executed when the Google Cloud Function is triggered."
  # TODO: how do you validate this?
  default = null
}

variable "cloud_function_trigger_type" {
  type        = string
  description = "(Required) The type of event to observe."
  default     = "EVENT"

  validation {
    condition     = can(regex("EVENT", var.cloud_function_trigger_type))
    error_message = "Can only be EVENT."
  }
}

variable "cloud_function_event_type" {
  type        = string
  description = "(Required) The type of event to observe."
  default     = "google.storage.object.finalize"
  validation {
    condition     = can(regex("google.storage.object.finalize|google.storage.object.delete|google.storage.object.archive|google.storage.object.metadataUpdate", var.cloud_function_event_type))
    error_message = "Supported values for event type include google.storage.object.finalize, delete, archive, metadataUpdate."
  }
}

variable "cloud_function_resource" {
  type        = string
  description = "(Required) Required. The name or partial URI of the resource from which to observe events."
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
  default     = "REPOSITORY"
  validation {
    condition     = can(regex("BUCKET|REPOSITORY", var.cloud_function_source_type))
    error_message = "Supported values for cloud_function_source_type include: BUCKET and REPOSITORY."
  }
}

variable "cloud_function_source_repository_url" {
  type        = string
  description = "(Optional) Represents the URL pointing to a source repository where a function is hosted."
  default     = null
  # TODO: how do you validate this?
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

variable "cloud_function_labels" {
  type        = map(string)
  description = "(Optional) A label is a key-value pair in the form of a map that helps you organize your Google Cloud resources."
  default     = {}
}

//variable "logging_bucket" {
//  type        = string
//  description = "Every bucket should log access. At the moment there is none created but it should be"
//}
