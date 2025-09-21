variable "project_id" {
  type        = string
  description = "The project id on which to deploy the job"
  validation {
    condition     = can(regex("^[a-z][a-z0-9 -]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Must be letters, digits, hyphens. or spaces. Must start with a letter and end with a letter or number. Must be between 6 and 30 characters."
  }
}

variable "name" {
  type        = string
  description = "The name of the job"
  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,63}[a-z0-9])?$", var.name))
    error_message = "Must be letters, digits, hyphens. Must start with a letter and end with a letter or number. Must be between 1 and 64 characters."
  }
}

variable "location" {
  type        = string
  description = "The location of the job"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.location))
    error_message = "Must be valid a location name."
  }
}

variable "launch_stage" {
  type        = string
  default     = null
  description = "Launch stage of the Cloud Run v2 Job. Must be one of: UNIMPLEMENTED, PRELAUNCH, EARLY_ACCESS, ALPHA, BETA, GA, DEPRECATED"
}

variable "parallelism" {
  type        = number
  default     = null
  description = "Number of tasks that can run in parallel. Must be greater than 0."
  validation {
    condition     = var.parallelism == null || var.parallelism > 0
    error_message = "Invalid parallelism. Must be greater than 0."
  }
}

variable "task_count" {
  type        = number
  default     = null
  description = "Total number of tasks to run. Must be greater than 0."
  validation {
    condition     = var.task_count == null || var.task_count > 0
    error_message = "Invalid task_count. Must be greater than 0."
  }
}

variable "container_name" {
  type        = string
  default     = null
  description = "Name of the container. Optional."
  validation {
    condition     = var.container_name == null || can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.container_name)) # Kubernetes container name validation
    error_message = "Invalid container_name. Must match Kubernetes container name conventions (lowercase alphanumeric and hyphens)."
  }
}

variable "command" {
  type        = list(string)
  default     = null
  description = "Entrypoint array. Not executed within a shell. The container image's ENTRYPOINT is used if this is not provided. Optional."
}

variable "args" {
  type        = list(string)
  default     = null
  description = "Arguments to the entrypoint. The container image's CMD is used if this is not provided. Optional."
}

variable "environment_variables" {
  type        = map(string)
  default     = null
  description = "List of environment variables to set in the container. Optional."
}

variable "cpu" {
  type        = string
  default     = null
  description = "The amount of CPU to allocate to the job"
}

variable "memory" {
  type        = string
  default     = null
  description = "The amount of memory to allocate to the job"
}

variable "service_account_email" {
  type        = string
  default     = null
  description = "The service account to use for the job"
}

variable "timeout" {
  type        = string
  default     = null
  description = "The number of seconds after which a request times out (should end with 's')"
  validation {
    condition     = var.timeout == null || can(regex("^([0-9].)?[0-9]*s$", var.timeout))
    error_message = "Must be a number followed by 's'."
  }
}

variable "container_image" {
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/job:latest"
  description = "The container image to deploy. Required. Can be with or without a tag."
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._/:]+$", var.container_image))
    error_message = "Invalid image name. Must be a valid image name (can include or exclude a tag)."
  }
}

variable "vpc_access_connector_id" {
  type        = string
  default     = null
  description = "The ID of the vpc access connector id. Optional"
}

variable "execution_environment" {
  type        = string
  default     = null
  description = "The execution environment for this job. Possible values: 'EXECUTION_ENVIRONMENT_GEN1', 'EXECUTION_ENVIRONMENT_GEN2'. Optional."
}

variable "encryption_key" {
  type        = string
  default     = null
  description = "Customer-managed encryption key for the job. Format: projects/*/locations/*/keyRings/*/cryptoKeys/*. Optional."
  validation {
    condition     = var.encryption_key == null || can(regex("^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$", var.encryption_key))
    error_message = "Invalid encryption_key. Must follow the format: projects/*/locations/*/keyRings/*/cryptoKeys/*."
  }
}

variable "max_retries" {
  type        = number
  default     = 0
  description = "Maximum number of retries the job will have. Must be >= 0. Optional."
  validation {
    condition     = var.max_retries >= 0
    error_message = "Invalid max_retries. Must be a non-negative number."
  }
}

variable "working_dir" {
  type        = string
  default     = null
  description = "The working directory for the container. Optional."
}

variable "iam" {
  type = list(object({
    member = string
    role   = string
  }))
  default     = []
  description = "List of members and roles to be assigned on the Cloud Run job"
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
  default     = {}
  description = "Map of secret versions and names to pass to the Cloud Run job as environment variables"
}

variable "binary_authorization" {
  type = object({
    use_default              = optional(bool)
    policy                   = optional(string)
    breakglass_justification = optional(string)
  })
  default     = null
  description = "Settings for Binary Authorization. Omitted if null."
}


variable "deletion_protection" {
  type        = bool
  default     = false
  description = "When set to true, prevents the Job from being deleted."
}
