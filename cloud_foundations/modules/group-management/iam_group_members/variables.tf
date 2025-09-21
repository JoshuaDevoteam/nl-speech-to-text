variable "group_email" {
  type        = string
  description = "the email address of the group"
}

variable "group_members" {
  type = set(object({
    email = string
    role  = string
    type  = string
  }))
}
