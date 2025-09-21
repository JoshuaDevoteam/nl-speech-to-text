/********************
  SUBNET IAM MEMBER
********************/
variable "subnet_project_id" {
  type        = string
  description = "Project id the subnet belongs to"
}

variable "subnet_region" {
  type        = string
  description = "Region the subnet belongs to"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet"
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
