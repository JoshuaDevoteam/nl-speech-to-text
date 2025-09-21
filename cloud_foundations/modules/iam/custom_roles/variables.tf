variable "type" {
  type        = string
  default     = "org"
  description = "Whether to create an organization or project level role. Can be one of \"org\" or \"project\"."
  validation {
    condition     = contains(["org", "organization", "organisation", "project"], lower(var.type))
    error_message = "Invalid value for custom role type. Choose one of \"org\" or \"project\"."
  }
}

variable "role_id" {
  type        = string
  description = "The role id to use for this role."
}

variable "org_id" {
  type        = string
  default     = null
  description = "If making a custom role of type organization, the org ID should be specified."
}

variable "project" {
  type        = string
  default     = null
  description = "If making a custom role of type project, the project ID should be specified."
}

variable "title" {
  type        = string
  description = "A human-readable title for the role."
}

variable "description" {
  type        = string
  default     = null
  description = "(Optional) A human-readable description for the role."
}

variable "permissions" {
  type        = list(string)
  description = "The names of the permissions this role grants when bound in an IAM policy. At least one permission must be specified."
  validation {
    condition     = length(var.permissions) > 0
    error_message = "At least one permission must be specified."
  }
}

variable "stage" {
  type        = string
  description = "(Optional) The current launch stage of the role. Defaults to GA. List of possible stages is here: https://cloud.google.com/iam/reference/rest/v1/organizations.roles#Role.RoleLaunchStage"
  default     = "GA"
  validation {
    condition     = contains(["ALPHA", "BETA", "GA", "DEPRECATED", "DISABLED", "EAP"], upper(var.stage))
    error_message = "Given stage is not an acceptable value."
  }
}
