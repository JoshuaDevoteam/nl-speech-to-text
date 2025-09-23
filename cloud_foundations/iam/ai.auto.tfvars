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
    description = "Frontend service account for DEV"
    display_name = "Frontend service account for DEV"
  }
  sa-frontend-uat = {
    create = true
    name = "frontend-uat"
    gcp_project_id = "pj-speech-text-uat"
    description = "Frontend service account for UAT"
    display_name = "Frontend service account for UAT"
  }
  sa-frontend-prod = {
    create = true
    name = "frontend-prod"
    gcp_project_id = "pj-speech-text-prod"
    description = "Frontend service account for PROD"
    display_name = "Frontend service account for PROD"
  }
  sa-backend-dev = {
    create = true
    name = "backend-dev"
    gcp_project_id = "pj-speech-text-dev"
    description = "Backend service account for DEV with Speech-to-Text access"
    display_name = "Backend service account for DEV"
  }
  sa-backend-uat = {
    create = true
    name = "backend-uat"
    gcp_project_id = "pj-speech-text-uat"
    description = "Backend service account for UAT with Speech-to-Text access"
    display_name = "Backend service account for UAT"
  }
  sa-backend-prod = {
    create = true
    name = "backend-prod"
    gcp_project_id = "pj-speech-text-prod"
    description = "Backend service account for PROD with Speech-to-Text access"
    display_name = "Backend service account for PROD"
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
      sa-backend-dev = [
        "roles/storage.objectAdmin",
        "roles/speech.client",
        "roles/aiplatform.user",
        "roles/iam.serviceAccountTokenCreator"
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
      sa-backend-uat = [
        "roles/storage.objectAdmin",
        "roles/speech.client",
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
      sa-backend-prod = [
        "roles/storage.objectAdmin",
        "roles/speech.client",
        "roles/aiplatform.user"
      ]
    }
  }
}
