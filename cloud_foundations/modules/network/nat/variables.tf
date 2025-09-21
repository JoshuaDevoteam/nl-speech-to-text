variable "region" {
  type        = string
  description = "The region for the NAT"
}

variable "network" {
  type        = string
  description = "The VPC for the NAT"
}

variable "project" {
  type        = string
  description = "The project for the NAT"
}

variable "subnets" {
  type        = list(any)
  description = "Use empty array to map all subnets to the NAT. Fill array with specific subnets to only NAT those subnets"
  default     = []
}

variable "number_of_static_ips" {
  type        = number
  default     = 0
  description = "If set to a number larger than 0, the cloud NAT will use manually reserved static IPs, instead of dynamically allocated IPs."
  validation {
    condition     = var.number_of_static_ips >= 0
    error_message = "The number of static IPs can not be negative."
  }
}
