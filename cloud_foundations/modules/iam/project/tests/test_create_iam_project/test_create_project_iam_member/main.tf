module "project_iam_member" {
  source = "../../../iam_project_member"

  project_id = var.project_id
  role       = var.role

  member = var.member
}
