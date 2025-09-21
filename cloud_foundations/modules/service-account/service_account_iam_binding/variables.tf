variable "account_id" {
  type        = string
  description = "The fully-qualified name of the service account to apply policy to"
}

variable "project" {
  type        = string
  description = "The name of the project where the service account policy should be applied to"
}

variable "display_name" {
  type        = string
  description = "The display name of the service account"
}

variable "bindings" {
  type = map(set(string))
}

variable "description" {
  type        = string
  description = "The description for the Service Account"
}

variable "disabled" {
  type        = bool
  description = "Whether a service account is disabled or not. Defaults to false. This field has no effect during creation. Must be set after creation to disable a service account."
}
