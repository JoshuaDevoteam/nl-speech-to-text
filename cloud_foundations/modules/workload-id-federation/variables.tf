variable "display_name" {
  type        = string
  description = "The display name for the Workload pool"
  default     = ""
}

variable "description" {
  type        = string
  description = "The description for the Workload pool"
  default     = ""
}

variable "workload_enabled" {
  type        = bool
  description = "Whether the Workload pool is enabled"
  default     = true
}

variable "project_id" {
  type        = string
  description = "The project ID for this Workload pool"
}

variable "workload_providers" {
  type = map(object({
    display_name        = optional(string)
    description         = optional(string)
    enabled             = optional(bool, true)
    attribute_mapping   = optional(map(string))
    attribute_condition = optional(string)
    aws_account_id      = optional(string)
    oidc = optional(object({
      allowed_audiences = optional(list(string))
      issuer_uri        = string
      jwks_json         = optional(string)
    }))
    saml = optional(object({
      secret_project = string
      secret         = string
      secret_version = string
    }))
  }))
}
