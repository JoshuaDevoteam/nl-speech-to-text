variable "org_id" {
  type        = string
  description = "The id of the organization where the resource should be created"
}

variable "bindings" {
  type = map(set(string))
}
