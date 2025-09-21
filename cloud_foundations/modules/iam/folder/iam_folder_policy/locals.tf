locals {

  folder_roles = toset(flatten(concat(
    [
      for name, roles in var.bindings : [roles]
    ]
  )))

  folder_bindings = length(local.folder_roles) > 0 ? {
    for r, b in {
      for role in local.folder_roles : role => toset(concat(
        [
          for name, roles in var.bindings : name
          if contains(roles, role)
        ],
      ))
    } : r => b
    if b != null && length(b) > 0
  } : {}

}
