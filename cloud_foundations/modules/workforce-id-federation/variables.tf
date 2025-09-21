variable "org_id" {
  type        = string
  description = "The organisation ID"
}

variable "description" {
  type        = string
  description = "The description for the Workforce pool"
  default     = ""
}

variable "display_name" {
  type        = string
  description = "The display name for the Workforce pool"
  default     = ""
}

variable "workforce_enabled" {
  type        = bool
  description = "Whether the Workforce pool is enabled"
  default     = true
}

variable "session_duration" {
  type        = string
  description = "Duration that the Google Cloud access tokens, console sign-in sessions, and gcloud sign-in sessions from this pool are valid. Must be greater than 15 minutes (900s) and less than 12 hours (43200s)."
  default     = "3600s"
}

variable "workforce_providers" {
  type = map(object({
    secret_project      = string
    secret              = string
    secret_version      = string
    attribute_mapping   = optional(map(string))
    attribute_condition = optional(string, "true")
    prefix              = optional(string, "wfprov")
    null_label_order    = optional(list(string), ["namespace", "name"])
    display_name        = optional(string)
    description         = optional(string)
    enabled             = optional(bool, true)
  }))
  description = <<EOT
    Map of provider configurations. The key of the map will be used as the name of the Workforce provider:
        secret_project: The project where the secret manager secret is saved that holds the metadata xml received from the IdP.
        secret: The name of the secret that holds the metadata xml
        secret_version: The version of the secret that holds the metadata xml
        attribute_mapping: (Optional) Maps attributes from the authentication credentials issued by an external identity provider to Google Cloud attributes, such as subject and segment.
        prefix: (Optional) the prefix for the naming convention of the Workforce provider
        null_label_order: (Optional) The label order for the null_label module that defines the naming convention
        display_name: (Optional) The display name of the Workforce provider
        description: (Optional) The description of the Workforce provider
        enabled: (Optional) Whether or not the Workforce provider is enabled
        attribute_condition: (Optional) A Common Expression Language expression, in plain text, to restrict what otherwise valid authentication credentials issued by the provider should not be accepted. The expression must output a boolean representing whether to allow the federation.
  EOT
}
