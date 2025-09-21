variable "network" {
  type        = string
  description = "The FQDN of the vpc to deploy the resources in"
}

variable "description" {
  type    = string
  default = null
}

variable "advertise_subnets" {
  type    = bool
  default = false
}

variable "advertised_ip_ranges" {
  description = "The IP ranges on GCP to advertise on the BGP router to go over the interconnect"
  type = list(object({
    range       = string
    description = optional(string)
  }))
  default = []
}

variable "asn" {
  description = "the ASN for the BGP router"
  type        = string
}

variable "keepalive_interval" {
  type    = number
  default = 20
}

variable "project" {
  description = "the Google Cloud project that will host the interconnect"
  type        = string
}

variable "region" {
  description = "the region of the router of the interconnect attachment"
  type        = string
}

variable "attachments" {
  type = map(object({
    description              = optional(string)
    enabled                  = optional(bool, true)
    mtu                      = optional(number, 1440)
    edge_availability_domain = string
    ip_range                 = string
    peer_ip_address          = string
    peer_asn                 = string
    priority                 = number
    advertise_mode           = optional(string, "DEFAULT")
    advertised_groups        = optional(list(string))
    advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })))
    bfd = optional(object({
      session_initialization_mode = optional(string, "DISABLED")
      min_receive_interval        = optional(string)
      min_transit_interval        = optional(string)
      multiplier                  = optional(string)
    }))
    activated             = optional(bool, true)
    attributes            = optional(list(string))
    override_names        = optional(bool, false)
    router_interface_name = optional(string)
    router_peer_name      = optional(string)
  }))
}
