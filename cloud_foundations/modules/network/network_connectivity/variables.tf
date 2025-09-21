variable "project" {
  type        = string
  description = "The project ID for the hub."
}

variable "hub_description" {
  type        = string
  default     = null
  description = "The description to attach to the NCC hub."
}

variable "spokes" {
  type = map(object({
    location    = optional(string, "global")
    project     = optional(string)
    description = optional(string)
    linked_vpc_network = optional(object({
      exclude_export_ranges = optional(list(string), [])
      uri                   = string
    }))
    linked_interconnect_attachments = optional(object({
      site_to_site_data_transfer = bool
      uris                       = list(string)
    }))
    linked_router_appliance_instances = optional(object({
      site_to_site_data_transfer = bool
      instances = map(object({
        ip_address = string
        vm         = string
      }))
    }))
    linked_vpn_tunnels = optional(object({
      site_to_site_data_transfer = bool
      uris                       = list(string)
    }))
  }))
  default = {}
}
