module "project_iam_binding" {
  source = "../../../iam_project_binding"

  project_id = var.project_id
  bindings   = var.bindings
}
