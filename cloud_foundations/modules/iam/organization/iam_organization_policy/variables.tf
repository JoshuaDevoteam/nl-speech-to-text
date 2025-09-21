variable "org_id" {
  type        = string
  description = "The id of the organization where the resource should be created"
}

variable "bindings" {
  description = "Map of lists, where the key is the role that should be assigned to the binding (e.g. roles/editor) and value is the list of members that should have full control of the resources (must be one of: `user:{emailid}`, `serviceAccount:{emailid}`)"
  type        = map(set(string))
}

variable "service_audit_configs" {
  type = map(list(object({
    log_type         = string
    exempted_members = optional(list(string))
  })))
  default     = {}
  description = "Map of services with their audit logging config."
}

variable "conditional_bindings" {
  description = "A map of objects, with the key as the title for the conditional binding, and as value the role, members, condition, and optionally a description."
  type = map(object({
    title       = string
    role        = string
    members     = set(string)
    condition   = string
    description = optional(string)
  }))
  default = {}
}
