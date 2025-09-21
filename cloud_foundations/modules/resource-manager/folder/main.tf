module "labels" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash of version 0.25.0

  namespace       = "fo"
  id_length_limit = 30

  context = module.this.context
}

resource "google_folder" "folder" {
  display_name = module.labels.id
  parent       = var.parent
}
