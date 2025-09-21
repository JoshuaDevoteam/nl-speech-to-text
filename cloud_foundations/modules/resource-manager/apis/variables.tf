variable "services" {
  type        = set(string)
  description = "Set of APIs to enable in the form of the full google api url, (e.g. iam.googleapis.com)"
}

variable "project_id" {
  type        = string
  description = "Project ID of the project in which enable the API"
}

variable "disable_on_destroy" {
  type        = bool
  default     = false
  description = "If true, disable the service when the Terraform resource is destroyed. May be useful in the event that a project is long-lived but the infrastructure running in that project changes frequently."
}
