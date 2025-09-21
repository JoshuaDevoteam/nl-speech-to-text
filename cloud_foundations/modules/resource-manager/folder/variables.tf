variable "parent" {
  type        = string
  description = "The parent ID of the org or folder under which this folder must be created as a direct descendant. format: organizations/1234567 or folders/1234567"
  default     = null
}
