locals {
  folders_root_ids = { for alias, folder in module.folders_root : folder.folder_id => folder.display_name }
  folders_l1_ids   = { for alias, folder in module.folders_l1 : folder.folder_id => "${local.folders_root_ids[folder.folder_parent_id]}/${folder.display_name}" }
  folders_l2_ids   = { for alias, folder in module.folders_l2 : folder.folder_id => "${local.folders_l1_ids[folder.folder_parent_id]}/${folder.display_name}" }
  folder_ids       = merge(local.folders_root_ids, local.folders_l1_ids, local.folders_l2_ids)

  project_root_ids = merge([
    for object_with_project_object in module.projects_in_folder_root :
    {
      for project in object_with_project_object.project_objects : project.project_id => project.name
    }
  ]...)
  project_l1_ids = merge([
    for object_with_project_object in module.projects_in_folder_l1 :
    {
      for project in object_with_project_object.project_objects : project.project_id => project.name
    }
  ]...)
  project_l2_ids = merge([
    for object_with_project_object in module.projects_in_folder_l2 :
    {
      for project in object_with_project_object.project_objects : project.project_id => project.name
    }
  ]...)
  project_l3_ids = merge([
    for object_with_project_object in module.projects_in_folder_l3 :
    {
      for project in object_with_project_object.project_objects : project.project_id => project.name
    }
  ]...)
  project_l4_ids = merge([
    for object_with_project_object in module.projects_in_folder_l4 :
    {
      for project in object_with_project_object.project_objects : project.project_id => project.name
    }
  ]...)
  project_l5_ids = merge([
    for object_with_project_object in module.projects_in_folder_l5 :
    {
      for project in object_with_project_object.project_objects : project.project_id => project.name
    }
  ]...)
  project_ids = merge(local.project_root_ids, local.project_l1_ids, local.project_l2_ids, local.project_l3_ids, local.project_l4_ids, local.project_l5_ids)

  apis_root = merge([
    for folder_key, folder in var.resources_root : {
      for project_key, project_value in folder.projects : try(module.projects_in_folder_root[folder_key].project_objects[project_key].project_id, project_value.project_id) => project_value.apis
    }
  ]...)
  apis_l1 = merge([
    for folder_key, folder in var.resources_l1 : {
      for project_key, project_value in folder.projects : try(module.projects_in_folder_l1[folder_key].project_objects[project_key].project_id, project_value.project_id) => project_value.apis
    }
  ]...)
  apis_l2 = merge([
    for folder_key, folder in var.resources_l2 : {
      for project_key, project_value in folder.projects : try(module.projects_in_folder_l2[folder_key].project_objects[project_key].project_id, project_value.project_id) => project_value.apis
    }
  ]...)
  apis_l3 = merge([
    for folder_key, folder in var.resources_l3 : {
      for project_key, project_value in folder.projects : try(module.projects_in_folder_l3[folder_key].project_objects[project_key].project_id, project_value.project_id) => project_value.apis
    }
  ]...)
  apis_l4 = merge([
    for folder_key, folder in var.resources_l4 : {
      for project_key, project_value in folder.projects : try(module.projects_in_folder_l4[folder_key].project_objects[project_key].project_id, project_value.project_id) => project_value.apis
    }
  ]...)
  apis_l5 = merge([
    for folder_key, folder in var.resources_l5 : {
      for project_key, project_value in folder.projects : try(module.projects_in_folder_l5[folder_key].project_objects[project_key].project_id, project_value.project_id) => project_value.apis
    }
  ]...)
  apis_all = merge(local.apis_root, local.apis_l1, local.apis_l2, local.apis_l3, local.apis_l4, local.apis_l5)
  apis_old_method = {
    for k, v in merge(
      var.apis,
      { for project_id, project_name in local.project_ids : project_id => setunion(lookup(var.apis, project_id, []), lookup(var.apis, "all", [])) }
    ) : k => v if k != "all"
  }
  apis_combined = { for project in distinct(concat(keys(local.apis_all), keys(local.apis_old_method))) : project => setunion(lookup(local.apis_all, project, []), lookup(local.apis_old_method, project, [])) }
}
