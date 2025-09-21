variable "network" {
  description = "The local network"
}
variable "peer_network" {
  description = "The peered network"
}

variable "exchange_network_routes" {
  type        = bool
  default     = true
  description = "Exchange routes coming from the first network. Set to YES if you want network to export, and peer_network to import custom routes."
}

variable "exchange_peer_network_routes" {
  type        = bool
  default     = true
  description = "Exchange routes coming from the peer network. Set to YES if you want network to import, and peer_network to export custom routes."
}
