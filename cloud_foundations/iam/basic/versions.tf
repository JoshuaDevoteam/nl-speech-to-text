terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    google      = ">= 4.49"
    google-beta = ">= 4.49"
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
  }
}
