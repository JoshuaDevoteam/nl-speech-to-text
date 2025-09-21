variable "project_id" {
  type        = string
  description = "ID of the project."
  validation {
    condition     = can(regex("^[a-z][a-z0-9 -]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Must be letters, digits, hyphens. or spaces. Must start with a letter and end with a letter or number. Must be between 6 and 30 characters."
  }
}

variable "artifact_registry_repository_id" {
  type        = string
  description = "The last part of the repository name."
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$|^gcr.io$|^asia.gcr.io$|^eu.gcr.io$|^us.gcr.io$",
    var.artifact_registry_repository_id))
    error_message = "Names may only contain lowercase letters, numbers and hyphens, and must begin with a letter and end with a letter or number, or be one of 'gcr.io', 'asia.gcr.io', 'eu.gcr.io' or 'us.gcr.io'"
  }
}

variable "artifact_registry_format" {
  type        = string
  description = "The format of packages that are stored in the repository."
  default     = "DOCKER"
}

variable "artifact_registry_location" {
  type        = string
  description = "Location of the bucket created by this terraform module. You can select a region, dual-region, or multi-region."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.artifact_registry_location))
    error_message = "Must be valid a location name."
  }
}

variable "artifact_registry_description" {
  type        = string
  description = "(Optional) Description of the Artifact Registry."
  default     = null
}

variable "artifact_registry_role_group_map" {
  type        = map(list(string))
  description = "A map with each role as key and lists of members or groups as values."
  default     = {}
}

variable "cleanup_policies" {
  description = "A list of cleanup policies for the repository. Omitted if empty."
  type = list(object({
    id     = string
    action = string
    condition = optional(object({
      tag_state             = optional(string)
      tag_prefixes          = optional(list(string))
      version_name_prefixes = optional(list(string))
      package_name_prefixes = optional(list(string))
      older_than            = optional(string)
      newer_than            = optional(string)
    }))
    most_recent_versions = optional(object({
      package_name_prefixes = optional(list(string))
      keep_count            = optional(number)
    }))
  }))
  default = []
}

variable "docker_config" {
  description = "Docker-specific configuration. If format is DOCKER and this is null, immutable_tags will default to true."
  type = object({
    immutable_tags = optional(bool)
  })
  default = null
}
