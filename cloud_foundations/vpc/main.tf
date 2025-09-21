provider "google" {
  impersonate_service_account = "sa-root-tf-vpc@pj-terra-speech-text-main.iam.gserviceaccount.com"
  user_project_override       = true
  billing_project             = "pj-terra-speech-text-main"
}

terraform {
  backend "gcs" {
    bucket                      = "gcs-tf-state-vpc-pj-terra-speech-text-main"
    prefix                      = "terraform/state/vpc"
    impersonate_service_account = "sa-root-tf-vpc@pj-terra-speech-text-main.iam.gserviceaccount.com"
  }
}

module "basic" {
  source    = "./basic"
  firewalls = merge(var.cloud_firewalls, var.data_firewalls, var.ai_firewalls)
  vpc       = merge(var.cloud_vpc, var.data_vpc, var.ai_vpc)
  nats      = merge(var.cloud_nats, var.data_nats, var.ai_nats)
}
