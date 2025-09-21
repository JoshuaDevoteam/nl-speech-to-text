variable "project" {
  type        = string
  description = "The project id on which to deploy the service"
  validation {
    condition     = can(regex("^[a-z][a-z0-9 -]{4,28}[a-z0-9]$", var.project))
    error_message = "Must be letters, digits, hyphens. or spaces. Must start with a letter and end with a letter or number. Must be between 6 and 30 characters."
  }
}

variable "name" {
  type        = string
  description = "The name of the service"
  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,63}[a-z0-9])?$", var.name))
    error_message = "Must be letters, digits, hyphens. Must start with a letter and end with a letter or number. Must be between 1 and 64 characters."
  }
}

variable "location" {
  type        = string
  description = "The location of the service"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.location))
    error_message = "Must be valid a location name."
  }
}

variable "cpu" {
  type        = string
  description = "The amount of CPU to allocate to the service"
}

variable "memory" {
  type        = string
  description = "The amount of memory to allocate to the service"
}

variable "service_account_email" {
  type        = string
  description = "The service account to use for the service"
}

variable "timeout" {
  type        = string
  description = "The number of seconds after which a request times out (should end with 's')"
  validation {
    condition     = can(regex("^([0-9].)?[0-9]*s$", var.timeout))
    error_message = "Must be a number followed by 's'."
  }
}

variable "max_instance_count" {
  type        = number
  description = "The maximum number of instances to spin up for this function"
}

variable "min_instance_count" {
  type        = number
  description = "The minimum number of instances to spin up for this function"
}

variable "startup_cpu_boost" {
  type        = bool
  description = "Boost CPU during instance startup"
}

variable "port" {
  type        = string
  description = "The port number for the service"
}

variable "environment_variables" {
  type        = map(string)
  description = "The environment variables to set for the service"
}

variable "vpc_access_connector_id" {
  type        = string
  description = "The ID of the vpc access connector id"
}

variable "container_image" {
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
  description = "The container image to deploy in Cloud Run"
}

variable "iam" {
  type = map(object({
    member = string
    role   = string
  }))
  default     = {}
  description = "Map of members and roles to be assigned on the Cloud Run service"
  validation {
    condition     = alltrue([for elem in var.iam : can(regex("^(?:serviceAccount|domain|group|user|principal|principalSet):.+$", elem.member))])
    error_message = "Member must be one of: `user:{emailid}`, `serviceAccount:{emailid}`, `group:{emailid}`, `domain:{domain}`, `principal:{emailid}` or `principalSet:{emailid}`."
  }
  validation {
    condition     = alltrue([for elem in var.iam : can(regex("^((projects|organizations)/[a-z][a-z0-9 -]{4,28}[a-z0-9]/)?roles/.+$", elem.role))])
    error_message = "Role must be one of: `roles/{role-name}` or `[projects|organizations]/{parent-name}/roles/{role-name}`."
  }
}

variable "secrets" {
  type = map(object({
    version = optional(string, "latest")
    name    = string
  }))
  description = "Map of secret versions and names to pass to the Cloud Run service"
}

variable "traffic" {
  type = object({
    type     = string
    percent  = optional(number)
    revision = optional(string)
    tag      = optional(string)
  })
  default = {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  validation {
    condition     = contains(["TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST", "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION"], var.traffic.type)
    error_message = "Traffic type must be one of: TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST, TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION."
  }
  validation {
    condition     = (var.traffic.type == "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST" || var.traffic.revision != null)
    error_message = "Must set traffic revision if traffic type is set to TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION."
  }
}