variable "project" {
  type        = string
  description = "The project to apply this policy to"
}

variable "enable_inbound_forwarding" {
  type        = bool
  description = "Whether to enable inbound forwarding"
}

variable "networks" {
  type        = list(string)
  description = "List of networks on which to apply this policy"
  default     = []
}

variable "logging" {
  type        = bool
  description = "Turns on logging if enabled"
  default     = false
}

variable "target_name_servers" {
  type = map(object({
    ipv4_address    = string
    forwarding_path = optional(string, "default")
  }))
  default = {}
}

variable "description" {
  type    = string
  default = ""
}
