variable "folder_id" {
  type = string
}

variable "constraint" {
  type = string
}

variable "boolean_policy" {
  type = bool
}

variable "list_policy" {

}

variable "restore_policy" {
  type    = bool
  default = false
}
