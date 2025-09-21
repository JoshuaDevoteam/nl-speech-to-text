variable "project_id" {
  type = string
}

variable "audit_log_config_log_type" {
  type = list(string)
}

variable "service" {
  type = string
}

variable "exempted_members" {
  type = list(string)
}
