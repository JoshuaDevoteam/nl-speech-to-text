variable "project" {
  type        = string
  description = "The ID of the project in which the resource belongs."
}

variable "network" {
  type        = string
  description = "The network that this route applies to."
}

variable "description" {
  type        = string
  description = "An optional description of this resource. Provide this property when you create the resource."
  default     = ""
}

variable "dest_range" {
  type        = string
  description = "The destination range of outgoing packets that this route applies to. Only IPv4 is supported."
}

variable "priority" {
  type        = number
  description = <<-EOT
    The priority of this route. Priority is used to break ties in cases where there is more than one matching route of
    equal prefix length. In the case of two routes with equal prefix length, the one with the lowest-numbered priority
    value wins. Default value is 1000. Valid range is 0 through 65535.
  EOT
  default     = 1000
}

variable "instance_tags" {
  type        = list(string)
  description = "A list of instance tags to which this route applies."
  default     = []
}

variable "next_hop_gateway" {
  type        = string
  description = "URL to a gateway that should handle matching packets."
  default     = null
}

variable "next_hop_instance" {
  type        = string
  description = "URL to an instance that should handle matching packets. You can specify this as a full or partial URL."
  default     = null
}

variable "next_hop_ip" {
  type        = string
  description = "Network IP address of an instance that should handle matching packets."
  default     = null
}

variable "next_hop_vpn_tunnel" {
  type        = string
  description = "URL to a VpnTunnel that should handle matching packets."
  default     = null
}

variable "next_hop_ilb" {
  type        = string
  description = <<-EOT
    The IP address or URL to a forwarding rule of type loadBalancingScheme=INTERNAL that should handle matching packets.
    With the GA provider you can only specify the forwarding rule as a partial or full URL.
  EOT
  default     = null
}

variable "next_hop_instance_zone" {
  type        = string
  description = "The zone of the instance specified in next_hop_instance. Omit if next_hop_instance is specified as a URL."
  default     = null
}
