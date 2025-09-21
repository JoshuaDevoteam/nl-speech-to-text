module "folder_iam_policy" {
  source = "../../iam_folder_policy"

  folder_id = var.folder_id
  bindings  = var.bindings
}
