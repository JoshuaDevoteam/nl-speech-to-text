output "display_name" {
  value = google_folder.folder.display_name
}

output "folder_id" {
  value = google_folder.folder.name
}

output "folder_parent_id" {
  value = google_folder.folder.parent
}
