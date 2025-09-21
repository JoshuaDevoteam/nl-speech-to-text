module "labels" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace = "f-gcp"
  context   = module.this.context
}


resource "googleworkspace_group" "group" {
  name        = module.labels.id
  email       = var.group_email
  description = var.group_description
}
