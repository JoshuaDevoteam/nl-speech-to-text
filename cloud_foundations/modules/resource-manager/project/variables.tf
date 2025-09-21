variable "projects" {
  type = map(object({
    project_id  = optional(string)
    name        = optional(string)
    namespace   = optional(string, "pj")
    tenant      = optional(string)
    environment = optional(string)
    stage       = optional(string)
    labels      = optional(map(string), {})
  }))
  description = <<EOF
    The projects to create directly under this folder.
    Specifying project_id can be used to preserve project IDs from imported projects. If not, it should not be used
    and name (or the key of the project) will be used to generate the ID instead.
    Labels for the project can be specified here. If the key matches one of the labels set on project level, it will
    be overwritten by this value.
  EOF
  default     = {}
}

variable "billing_account" {
  type        = string
  description = "The billing account the project will be linked to"
}

variable "parent_folder" {
  type        = string
  description = "The numeric ID of the folder this project should be created under, without folder/ prefix"
  default     = null
}

variable "labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to all projects in this module."
  default     = {}
}
