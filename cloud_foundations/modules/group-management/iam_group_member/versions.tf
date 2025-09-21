terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "0.7.0"
    }
  }
}
