resource "googleworkspace_group_members" "default" {
  group_id = var.group_email

  dynamic "members" {
    for_each = var.group_members
    content {
      email = members.value.email
      role  = members.value.role
    }
  }
}
