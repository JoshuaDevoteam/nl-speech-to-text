module "project_iam_policy" {
  source = "../../../iam_project_policy"

  project_id = var.project_id
  bindings   = var.bindings
}
