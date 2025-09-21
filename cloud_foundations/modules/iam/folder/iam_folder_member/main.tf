resource "google_folder_iam_member" "folder" {
  for_each = var.role

  folder = var.folder_id
  role   = each.value
  member = var.member
}
