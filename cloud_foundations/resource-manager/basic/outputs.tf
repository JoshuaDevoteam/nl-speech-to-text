output "folder_ids" {
  value = { for folder_id, path in local.folder_ids : path => trimprefix(folder_id, "folders/") }
}
