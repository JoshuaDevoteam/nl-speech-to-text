variable "service_account_id" {
  type = string
}

variable "bindings" {

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
