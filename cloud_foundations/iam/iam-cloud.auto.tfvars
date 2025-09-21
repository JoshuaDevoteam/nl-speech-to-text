cloud_groups = {}

cloud_service_accounts = {

  ##################################################################
  ### Service Accounts for managing all the terraform workspaces ###
  ###  /!\ DON'T delete them or you may be locked out /!\        ###

  "sa-root-tf-iam" = {
    email  = "sa-root-tf-iam@pj-terra-speech-text-main.iam.gserviceaccount.com"
    create = false
    users = {
      "joshua.vink@devoteam.com" = [
        "roles/iam.serviceAccountTokenCreator"
      ]
    }
  }

  "sa-root-tf-rm" = {
    create         = false
    email          = "sa-root-tf-rm@pj-terra-speech-text-main.iam.gserviceaccount.com"
    environment    = "root-tf-rm"
    gcp_project_id = "pj-terra-speech-text-main"
    description    = "This service account is used to create folders and projects."
    users = {
      "joshua.vink@devoteam.com" = [
        "roles/iam.serviceAccountTokenCreator"
      ]
    }
  }

  "sa-root-tf-vpc" = {
    create         = true
    environment    = "root-tf-vpc"
    gcp_project_id = "pj-terra-speech-text-main"
    description    = "This service account is used to create networks."
    users = {
      "joshua.vink@devoteam.com" = [
        "roles/iam.serviceAccountTokenCreator"
      ]
    }
  }

  ###                                                           ###
  #################################################################
}


cloud_projects = {
  # Needed to use the project as billing project in terraform
  "pj-terra-speech-text-main" = {
    project_id = "pj-terra-speech-text-main"
    sa = {
      # IMPORTANT! DO NOT REMOVE PERMISSIONS IN THIS SECTION
      sa-root-tf-iam = [
        "roles/iam.securityAdmin",
        "roles/iam.serviceAccountCreator",
        "roles/iam.serviceAccountDeleter",
        "roles/serviceusage.serviceUsageConsumer",
        "roles/storage.admin"
      ],
      sa-root-tf-rm = [
        "roles/serviceusage.serviceUsageConsumer"
      ],
      sa-root-tf-vpc = [
        "roles/serviceusage.serviceUsageConsumer"
      ]
    }
    users = {}
    groups = {}
  }
}

cloud_folders = {
  "top_level_folder" = {
    folder_id = "375233610952"
    sa = {
      "sa-root-tf-iam" = [
        "roles/iam.securityAdmin",
        "roles/iam.serviceAccountAdmin",
        "roles/serviceusage.serviceUsageConsumer",
        "roles/storage.admin"
      ],
      "sa-root-tf-rm" = [
        "roles/compute.networkAdmin",
        "roles/resourcemanager.projectCreator",
        "roles/resourcemanager.folderCreator",
        "roles/billing.projectManager",
        "roles/serviceusage.serviceUsageAdmin"
      ],
      "sa-root-tf-vpc" = [
        "roles/compute.networkAdmin",
        "roles/compute.securityAdmin",
        "roles/serviceusage.serviceUsageConsumer"
      ]
    }
    users = {
      "joshua.vink@devoteam.com" = [
        "roles/iam.serviceAccountTokenCreator"
      ]
    }
    groups = {}
  }
}

cloud_tfstates = {
  cloud_rm_state = {
    project          = "pj-terra-speech-text-main",
    service_accounts = ["sa-root-tf-rm"]
    location         = "EUROPE-WEST1"
    name             = "rm-pj-terra-speech-text-main"
  }
  cloud_vpc_state = {
    project          = "pj-terra-speech-text-main",
    service_accounts = ["sa-root-tf-vpc"]
    location         = "EU"
    name             = "vpc-pj-terra-speech-text-main"
  }
}
