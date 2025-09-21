module "folder_iam_member" {
  source = "../../iam_folder_member"

  folder_id = var.folder_id
  role      = var.role

  member = var.member
}
