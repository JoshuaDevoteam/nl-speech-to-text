variable "private_service_access" {
  description = "The Private Service Accesses to configure. Needs service `servicenetworking.googleapis.com` API to be enabled in the Resource Manager"
  type = map(object({
    cidr_ranges = map(string)
    service     = string
    name        = string
  }))
}

variable "network" {
  description = "The VPC hosting the PSA"
  type        = string
}

variable "project" {
  description = "The project ID"
  type        = string
}
