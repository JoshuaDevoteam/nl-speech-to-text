variable "project_id" {
  type        = string
  description = "The id of the project where the resource should be created"
}

variable "role" {
  type        = set(string)
  description = "The role that should be assigned to the binding. Ex: roles/editor"
}

variable "member" {
  type        = string
  description = "Members that should have full control of the resources. Must be one of: `user:{emailid}`, `serviceAccount:{emailid}`"
}
