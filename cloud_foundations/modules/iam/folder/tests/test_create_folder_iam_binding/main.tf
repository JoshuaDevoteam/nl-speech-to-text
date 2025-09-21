module "folder_iam_binding" {
  source = "../../iam_folder_binding"

  folder_id = var.folder_id
  bindings  = var.bindings
}
