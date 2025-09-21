resource "google_folder_iam_binding" "folder" {
  for_each = local.folder_bindings

  folder = var.folder_id

  role    = each.key
  members = each.value
}
