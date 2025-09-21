variable "project" {
  description = "the project hosting the VPC where the firewall rule will be deployed"
}
variable "network" {
  description = "the network in which to deploy the firewall rule"
}
variable "egress_allow_range" {
  description = "the allowed egress, based on target tag (sending) and destination IP (receiving)"
  type = map(object({
    description        = string
    protocols          = map(list(string))
    target_tags        = list(string)
    destination_ranges = list(string)
    priority           = optional(number)
    logging_mode       = optional(string)
  }))
}
variable "ingress_allow_tag" {
  description = "the allowed ingress, based on source tag (sending) and target tag (receiving)"
  type = map(object({
    description  = string
    protocols    = map(list(string))
    source_tags  = list(string)
    target_tags  = list(string)
    logging_mode = optional(string)
  }))
}
variable "ingress_allow_range" {
  description = "the allowed ingress, based on source IP range (sending) and target tag (receiving)"
  type = map(object({
    description   = string
    protocols     = map(list(string))
    source_ranges = list(string)
    target_tags   = list(string)
    logging_mode  = optional(string)
  }))
}

variable "egress_deny_range" {
  type = map(object({
    description        = string
    protocols          = map(list(string))
    target_tags        = list(string)
    destination_ranges = list(string)
    priority           = optional(number)
    logging_mode       = optional(string)
  }))
}

variable "default_logging_mode" {
  type    = string
  default = null
  validation {
    condition     = var.default_logging_mode == null || contains(["EXCLUDE_ALL_METADATA", "INCLUDE_ALL_METADATA"], coalesce(var.default_logging_mode, " "))
    error_message = "Default_logging_mode must be EXCLUDE_ALL_METADATA, INCLUDE_ALL_METADATA, or null."
  }
}
