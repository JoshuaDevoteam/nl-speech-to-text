ai_service_accounts = {
  sa-ai-tf-dev = {
    gcp_project_id = "pj-speech-text-dev"
    description = "Terraform service account for Vertex AI Foundations Terraform DEV"
    name = "terraform"
    display_name = "Terraform service account for Vertex AI Foundations Terraform DEV"
    create = true
    users = {
      "joshua.vink@devoteam.com" = [
        "roles/iam.serviceAccountTokenCreator"
      ]
    }
  }
  sa-ai-tf-uat = {
    gcp_project_id = "pj-speech-text-uat"
    description = "Terraform service account for Vertex AI Foundations Terraform UAT"
    name = "terraform"
    display_name = "Terraform service account for Vertex AI Foundations Terraform UAT"
    create = true
    users = {
      "joshua.vink@devoteam.com" = [
        "roles/iam.serviceAccountTokenCreator"
      ]
    }
  }
  sa-ai-tf-prod = {
    gcp_project_id = "pj-speech-text-prod"
    description = "Terraform service account for Vertex AI Foundations Terraform PROD"
    name = "terraform"
    display_name = "Terraform service account for Vertex AI Foundations Terraform PROD"
    create = true
    users = {
      "joshua.vink@devoteam.com" = [
        "roles/iam.serviceAccountTokenCreator"
      ]
    }
  }
  sa-ai-cloudbuild-dev = {
    gcp_project_id = "pj-speech-text-dev"
    description = "Cloudbuild service account for DEV"
    name = "cloudbuild"
    display_name = "Cloudbuild service account for DEV"
    create = true
  }
  sa-ai-cloudbuild-uat = {
    gcp_project_id = "pj-speech-text-uat"
    description = "Cloudbuild service account for UAT"
    name = "cloudbuild"
    display_name = "Cloudbuild service account for UAT"
    create = true
  }
  sa-ai-cloudbuild-prod = {
    gcp_project_id = "pj-speech-text-prod"
    description = "Cloudbuild service account for PROD"
    name = "cloudbuild"
    display_name = "Cloudbuild service account for PROD"
    create = true
  }
  sa-frontend-dev = {
    create = true
    name = "frontend-dev"
    gcp_project_id = "pj-speech-text-dev"
  }
  sa-frontend-uat = {
    create = true
    name = "frontend-uat"
    gcp_project_id = "pj-speech-text-uat"
  }
  sa-frontend-prod = {
    create = true
    name = "frontend-prod"
    gcp_project_id = "pj-speech-text-prod"
  }
}
ai_tfstates = {
  ai_dev_state = {
    project = "pj-speech-text-dev"
    service_accounts = [
      "sa-ai-tf-dev"
    ]
    location = "europe-west1"
    name = "pj-speech-text-dev"
  }
  ai_uat_state = {
    project = "pj-speech-text-uat"
    service_accounts = [
      "sa-ai-tf-uat"
    ]
    location = "europe-west1"
    name = "pj-speech-text-uat"
  }
  ai_prod_state = {
    project = "pj-speech-text-prod"
    service_accounts = [
      "sa-ai-tf-prod"
    ]
    location = "europe-west1"
    name = "pj-speech-text-prod"
  }
}
ai_projects = {
  pj-speech-text-dev = {
    project_id = "pj-speech-text-dev"
    users = {}
    groups = {}
    sa = {
      sa-ai-tf-dev = [
        "roles/artifactregistry.admin",
        "roles/cloudbuild.builds.editor",
        "roles/storage.admin",
        "roles/aiplatform.user",
        "roles/run.admin",
        "roles/iam.serviceAccountUser"
      ]
      sa-ai-cloudbuild-dev = [
        "roles/editor"
      ]
      sa-frontend-dev = [
        "roles/storage.objectViewer",
        "roles/aiplatform.user"
      ]
    }
  }
  pj-speech-text-uat = {
    project_id = "pj-speech-text-uat"
    users = {}
    groups = {}
    sa = {
      sa-ai-tf-uat = [
        "roles/artifactregistry.admin",
        "roles/cloudbuild.builds.editor",
        "roles/storage.admin",
        "roles/aiplatform.user",
        "roles/run.admin",
        "roles/iam.serviceAccountUser"
      ]
      sa-ai-cloudbuild-uat = [
        "roles/editor"
      ]
      sa-frontend-uat = [
        "roles/storage.objectViewer",
        "roles/aiplatform.user"
      ]
    }
  }
  pj-speech-text-prod = {
    project_id = "pj-speech-text-prod"
    users = {}
    groups = {}
    sa = {
      sa-ai-tf-prod = [
        "roles/artifactregistry.admin",
        "roles/cloudbuild.builds.editor",
        "roles/storage.admin",
        "roles/aiplatform.user",
        "roles/run.admin",
        "roles/iam.serviceAccountUser"
      ]
      sa-ai-cloudbuild-prod = [
        "roles/editor"
      ]
      sa-frontend-prod = [
        "roles/storage.objectViewer",
        "roles/aiplatform.user"
      ]
    }
  }
}
