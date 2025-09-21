variable "folder_id" {
  type        = string
  description = "The id of the project where the resource should be created"
}

variable "service" {
  type        = string
  description = "The name of the service where the IAM Audit Config should be deployed. Default value could be allServices if we want to add to all of the services."
}

variable "members" {
  type        = set(string)
  default     = []
  description = "Members that should have full control of the resources. Must be one of: `user:{emailid}`, `serviceAccount:{emailid}`"
}

variable "exempted_members" {
  type        = set(string)
  default     = []
  description = "Members that should have full control of the resources. Must be one of: `user:{emailid}`, `serviceAccount:{emailid}`"
}

variable "audit_log_config_log_type" {
  type        = set(string)
  description = "The type of log type we would like. Ex: ADMIN_READ, DATA_READ"
}
