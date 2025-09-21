locals {
  groups = var.groups

  service_accounts_defaults = var.service_accounts
  service_accounts          = merge(local.service_accounts_defaults, local.serviceagents_service_accounts)

  service_account_bindings = {
    for sa_name, service_account in local.service_accounts : sa_name => {
      service_account_id = lookup(module.service_accounts, sa_name, null) == null ? "projects/-/serviceAccounts/${local.service_accounts[sa_name].email}" : module.service_accounts[sa_name].id
      bindings = transpose(merge(
        {
          for sa, roles in service_account.sa : lookup(module.service_accounts, sa, null) == null ? "serviceAccount:${local.service_accounts[sa].email}" : "serviceAccount:${module.service_accounts[sa].email}" => roles
        },
        {
          for group, roles in service_account.groups : "group:${local.groups[group]["email"]}" => roles
        },
        {
          for user, roles in service_account.users : "user:${user}" => roles
        },
        {
          for principal, roles in service_account.principals : "principal:${principal}" => roles
        },
        {
          for principalSet, roles in service_account.principalSets : "principalSet:${principalSet}" => roles
        }
      ))
      conditional_bindings = merge([
        for condition_title, conditional in try(service_account.conditionals, {}) : {
          for role, members in transpose(merge(
            {
              for sa, roles in conditional.sa : "serviceAccount:${try(module.service_accounts[sa].email, local.service_accounts[sa].email)}" => roles
            },
            {
              for group, roles in conditional.groups : "group:${local.groups[group]["email"]}" => roles
            },
            {
              for user, roles in conditional.users : "user:${user}" => roles
            },
            {
              for principal, roles in conditional.principals : "principal:${principal}" => roles
            },
            {
              for principalSet, roles in conditional.principalSets : "principalSet:${principalSet}" => roles
            }
            )) : "${condition_title}-${role}" => {
            title       = condition_title
            role        = role
            members     = members
            condition   = conditional.condition
            description = conditional.description
          }
        }
      ]...)
    }
    # Check if there are any bindings for the given Service account by checking if there is at least one element for any principal type or a conditional binding
    # This condition structure looks weird but is needed to prevent unknown for_each keys at apply time
    if try(service_account.force_create_policy, false) ? true : length(merge(try(service_account.groups, {}), try(service_account.sa, {}), try(service_account.users, {}), try(service_account.principals, {}), try(service_account.principalSets, {}), try(service_account.conditionals, {}))) > 0
  }

  folders = var.folders
  folder_bindings = {
    for folder_name, folder in local.folders : folder_name => {
      folder_id = folder.folder_id
      bindings = transpose(merge(
        {
          for sa, roles in folder.sa : lookup(module.service_accounts, sa, null) == null ? "serviceAccount:${local.service_accounts[sa].email}" : "serviceAccount:${module.service_accounts[sa].email}" => roles
        },
        {
          for group, roles in folder.groups : "group:${local.groups[group]["email"]}" => roles
        },
        {
          for user, roles in folder.users : "user:${user}" => roles
        },
        {
          for principal, roles in folder.principals : "principal:${principal}" => roles
        },
        {
          for principalSet, roles in folder.principalSets : "principalSet:${principalSet}" => roles
        }
      ))
      conditional_bindings = merge([
        for condition_title, conditional in folder.conditionals : {
          for role, members in transpose(merge(
            {
              for sa, roles in conditional.sa : "serviceAccount:${try(module.service_accounts[sa].email, local.service_accounts[sa].email)}" => roles
            },
            {
              for group, roles in conditional.groups : "group:${local.groups[group]["email"]}" => roles
            },
            {
              for user, roles in conditional.users : "user:${user}" => roles
            },
            {
              for principal, roles in conditional.principals : "principal:${principal}" => roles
            },
            {
              for principalSet, roles in conditional.principalSets : "principalSet:${principalSet}" => roles
            }
            )) : "${condition_title}-${role}" => {
            title       = condition_title
            role        = role
            members     = members
            condition   = conditional.condition
            description = conditional.description
          }
        }
      ]...)
    }
  }

  projects = var.projects
  project_bindings = {
    for project_name, project in local.projects : project_name => {
      project_id = project.project_id
      bindings = transpose(merge(
        {
          for sa, roles in project.sa : lookup(module.service_accounts, sa, null) == null ? "serviceAccount:${local.service_accounts[sa].email}" : "serviceAccount:${module.service_accounts[sa].email}" => roles
        },
        {
          for sa, roles in local.serviceagents_service_accounts_roles[project.project_id] : lookup(module.service_accounts, sa, null) == null ? "serviceAccount:${local.service_accounts[sa].email}" : "serviceAccount:${module.service_accounts[sa].email}" => roles
        },
        {
          for group, roles in project.groups : "group:${local.groups[group]["email"]}" => roles
        },
        {
          for user, roles in project.users : "user:${user}" => roles
        },
        {
          for principal, roles in project.principals : "principal:${principal}" => roles
        },
        {
          for principalSet, roles in project.principalSets : "principalSet:${principalSet}" => roles
        }
      ))
      conditional_bindings = merge([
        for condition_title, conditional in project.conditionals : {
          for role, members in transpose(merge(
            {
              for sa, roles in conditional.sa : "serviceAccount:${try(module.service_accounts[sa].email, local.service_accounts[sa].email)}" => roles
            },
            {
              for group, roles in conditional.groups : "group:${local.groups[group]["email"]}" => roles
            },
            {
              for user, roles in conditional.users : "user:${user}" => roles
            },
            {
              for principal, roles in conditional.principals : "principal:${principal}" => roles
            },
            {
              for principalSet, roles in conditional.principalSets : "principalSet:${principalSet}" => roles
            }
            )) : "${condition_title}-${role}" => {
            title       = condition_title
            role        = role
            members     = members
            condition   = conditional.condition
            description = conditional.description
          }
        }
      ]...)
    }
  }

  serviceagents_encoded = file("${path.module}/serviceagents.yaml")
  serviceagents_decoded = yamldecode(local.serviceagents_encoded)
  serviceagents = {
    for project_name, project in local.projects :
    "${project.project_id}" =>
    yamldecode(
      replace(
        local.serviceagents_encoded,
        "$${PROJECT_NUMBER}",
        data.google_project.serviceagents_project[project_name].number
      )
    )
  }
  serviceagents_apis = toset([for serviceagent in local.serviceagents_decoded.data : serviceagent.api])

  serviceagents_service_accounts_resource = merge(flatten([
    for k, v in data.http.serviceagents_service : [
      for service in try(jsondecode(v.response_body).services, []) : {
        "${data.google_project.serviceagents_project[k].project_id}/${service.config.name}" = {
          service = service.config.name
          project = data.google_project.serviceagents_project[k].project_id
        }
      } if contains(local.serviceagents_apis, service.config.name)
    ]
  ])...)
  serviceagents_service_accounts = merge(flatten([
    for project_name, project in local.projects : [
      for serviceagent in local.serviceagents[project.project_id].data : {
        replace(serviceagent.email, ".gserviceaccount.com", "") = {
          project_id   = project.project_id
          create       = false
          email        = serviceagent.email
          roles        = serviceagent.roles
          display_name = serviceagent.name

          groups        = {}
          sa            = {}
          users         = {}
          principals    = {}
          principalSets = {}
        }
      } if contains([for service in try(jsondecode(data.http.serviceagents_service[project_name].response_body).services, []) : service.name], serviceagent.id)
    ]
  ])...)
  serviceagents_service_accounts_roles = {
    for project_name, project in local.projects :
    "${project.project_id}" => {
      for k, v in local.serviceagents_service_accounts : k => v.roles if v.project_id == project.project_id
    }
  }

  tfstate_bucket_bindings = {
    for tfstate_alias, tfstate in var.tfstates : tfstate_alias => {
      bucket = module.bucket[tfstate_alias].bucket_id
      bindings = {
        "roles/storage.admin" = [
          for sa_name in tfstate.service_accounts : lookup(module.service_accounts, sa_name, null) == null ? "serviceAccount:${var.service_accounts[sa_name].email}" : "serviceAccount:${module.service_accounts[sa_name].email}"
        ]
      }
    }
  }
}
