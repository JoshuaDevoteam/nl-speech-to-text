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

variable "role" {
  type        = set(string)
  description = "The role that should be assigned to the binding. Ex: roles/editor"
}

variable "member" {
  type        = string
  description = "Members that should have full control of the resources. Must be one of: `user:{emailid}`, `serviceAccount:{emailid}`"
}

variable "description" {
  type        = string
  description = "The description for the Service Account"
}

variable "disabled" {
  type        = bool
  description = "Whether a service account is disabled or not. Defaults to false. This field has no effect during creation. Must be set after creation to disable a service account."
}
