locals {

  sa_roles = toset(flatten(concat(
    [
      for name, roles in var.bindings : [roles]
    ]
  )))

  sa_bindings = length(local.sa_roles) > 0 ? {
    for r, b in {
      for role in local.sa_roles : role => toset(concat(
        [
          for name, roles in var.bindings : name
          if contains(roles, role)
        ],
      ))
    } : r => b
    if b != null && length(b) > 0
  } : {}

}
