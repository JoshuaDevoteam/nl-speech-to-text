variable "folder_id" {
  type        = string
  default     = null
  description = "Set this to the folder ID (number) to make this policy apply to the folder. One of folder_id, project_id, or org_id needs to be set. If multiple are set, org will take precedence over folder and folder over project."
}

variable "project_id" {
  type        = string
  default     = null
  description = "Set this to the project ID to make this policy apply to the project. One of folder_id, project_id, or org_id needs to be set. If multiple are set, org will take precedence over folder and folder over project."
}

variable "org_id" {
  type        = string
  default     = null
  description = "Set this to the organization ID to make this policy apply to the organization. One of folder_id, project_id, or org_id needs to be set. If multiple are set, org will take precedence over folder and folder over project."
}

variable "constraint" {
  type        = string
  description = "The full programmatic name of the of the organization policy, e.g. gcp.resourceLocations"
}

variable "boolean_policy" {
  type        = bool
  default     = null
  description = "If the organization policy is a boolean policy, set this to true or false to toggle enforcement status of the policy."
}

variable "list_policy" {
  type = object({
    deny = optional(object({
      all    = optional(bool)
      values = optional(list(string))
      })
    )
    allow = optional(object({
      all    = optional(bool)
      values = optional(list(string))
      })
    )
  })
  default     = null
  description = "If the organization policy is a list policy, populate this object to set it. You can either set the policy to allow all values, deny all values, or allow or deny specific values, in which case those should be added as a list. See the specific documentation on what values are possible."
}

variable "restore_policy" {
  type        = bool
  default     = false
  description = "If set to true, this will set the policy for the resource to its default value, ignoring the parent policy. If set, it will ignore the boolean_policy and list_policy field and set inherit_from_parent to false."
}

variable "inherit_from_parent" {
  type        = bool
  default     = true
  description = "If the policy is a list policy, set this to true to have the node inherit the policy from its parent. If set to false, this policy will be the new root for evaluation."
}
