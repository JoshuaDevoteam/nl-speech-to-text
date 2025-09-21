variable "project_id" {
  type        = string
  description = "The id of the project where the resource should be created"
}

variable "bindings" {
  type = map(set(string))
}
