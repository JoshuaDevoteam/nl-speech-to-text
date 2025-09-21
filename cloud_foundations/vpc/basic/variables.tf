#TODO fill with defaults in case customer does not specify
variable "vpc" {
  description = "The vpcs to be created"
}
variable "firewalls" {
  description = "The firewall rules to create"
}
variable "nats" {
  description = "The Cloud NATs to create"
  default     = {}
}
