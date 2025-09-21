module "project_management" {
  source = "../"
  projects = {
    "project-5" = {
      project_id = "test-management-aka5"
    }
    "project-6" = {
      project_id = "test-management-aka6"
    }
  }
  parent_folder   = ""
  billing_account = ""
}

output "name" {
  value = module.project_management.project_objects
}
