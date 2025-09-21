resource "googleworkspace_group_member" "member" {
  group_id = var.group_email
  email    = var.member_email
  role     = var.member_role
}
