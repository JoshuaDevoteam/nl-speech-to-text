#TODO extend on descriptions for non-powerusers
#TODO validations
#TODO refine variable type & structure (e.g. private_service_access type=object()...)
variable "project" {
  type        = string
  description = "The project id for the VPC"
}
variable "description" {
  type        = string
  description = "The description for the VPC"
}
variable "subnets" {
  type = map(object({
    name                  = optional(string)
    cidr_primary          = string
    region                = string
    private_google_access = optional(bool)
    secondary_ranges = optional(map(object({
      name       = optional(string)
      cidr_range = string
    })))
    purpose = optional(string, "PRIVATE")
    role    = optional(string)
  }))
  description = "The subnets for the VPC"
}
variable "routing_mode" {
  type        = string
  description = "The routing mode for the VPC (GLOBAL or REGIONAL)"
  validation {
    condition     = can(regex("^(GLOBAL|REGIONAL)$", var.routing_mode))
    error_message = "Must be either GLOBAL or REGIONAL."
  }
}

variable "skip_default_deny_fw" {
  type        = bool
  default     = false
  description = "By default, deny all egress (overrules the allow all egress rule implied in the root vpc network resource)."
}

variable "delete_default_route_on_create" {
  type        = bool
  default     = false
  description = "If set to true, deletes the default route to the internet on create. Does nothing after initial creation."
}

variable "firewall_logging_mode" {
  type    = string
  default = null
  validation {
    condition     = var.firewall_logging_mode == null || contains(["INCLUDE_ALL_METADATA", "EXCLUDE_ALL_METADATA"], coalesce(var.firewall_logging_mode, " "))
    error_message = "Firewall logging mode must be EXCLUDE_ALL_METADATA, INCLUDE_ALL_METADATA, or null."
  }
}
