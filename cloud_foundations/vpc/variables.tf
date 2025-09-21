variable "cloud_vpc" {
  description = "The vpcs to be created"
  default     = {}
}

variable "data_vpc" {
  default = {}
}

variable "ai_vpc" {
  default = {}
}

variable "cloud_firewalls" {
  description = "The firewall rules to create"
  default     = {}
}

variable "data_firewalls" {
  default = {}
}

variable "ai_firewalls" {
  default = {}
}

variable "cloud_nats" {
  default = {}
}

variable "data_nats" {
  default = {}
}

variable "ai_nats" {
  default = {}
}
