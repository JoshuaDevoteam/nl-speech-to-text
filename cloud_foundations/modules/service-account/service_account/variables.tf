variable "project" {
  type        = string
  description = "The project where the Service Account should be deployed."
}

variable "description" {
  type        = string
  description = "The description for the Service Account"
}

variable "display_name" {
  type        = string
  description = "The name that should be displayed for the service account."
}

variable "disabled" {
  type        = bool
  description = "Whether a service account is disabled or not. Defaults to false. This field has no effect during creation. Must be set after creation to disable a service account."
}
