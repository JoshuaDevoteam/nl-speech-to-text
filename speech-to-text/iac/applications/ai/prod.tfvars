artifact_registry_repositories = {
  pipeline-containers = {
    description = "Repository containing pipeline Docker containers."
    format = "DOCKER"
    location = "europe-west1"
    role_group_map = {}
  }
  pipeline-packages = {
    description = "Repository containing pipeline Python packages."
    format = "PYTHON"
    location = "europe-west1"
    role_group_map = {}
  }
  pipeline-templates = {
    description = "Repository containing Kubeflow Pipelines templates."
    format = "KFP"
    location = "europe-west1"
    role_group_map = {}
  }
}
branch_regex = "main"
buckets = {
  datasets = {
    name = "pj-speech-text-prod-datasets"
    region = "europe-west1"
  }
  models = {
    name = "pj-speech-text-prod-models"
    region = "europe-west1"
  }
  frontend = {
    name = "pj-speech-text-prod-genai-frontend"
    region = "europe-west1"
  }
  audio_uploads = {
    name = "pj-speech-text-prod-audio-uploads"
    region = "europe-west1"
  }
  transcripts = {
    name = "pj-speech-text-prod-transcripts"
    region = "europe-west1"
  }
}
project_id = "pj-speech-text-prod"
repo_name = "nl-speech-to-text"
repo_owner = "JoshuaDevoteam"
region = "europe-west1"
service_accounts = {
  terraform = {
    create = false
    email = "sa-terraform@pj-speech-text-prod.iam.gserviceaccount.com"
  }
  cloudbuild = {
    create = false
    email = "sa-cloudbuild@pj-speech-text-prod.iam.gserviceaccount.com"
  }
  sa-frontend-prod = {
    create = false
    email = "sa-frontend-prod@pj-speech-text-prod.iam.gserviceaccount.com"
  }
  sa-backend-prod = {
    create = false
    email = "sa-backend-prod@pj-speech-text-prod.iam.gserviceaccount.com"
  }
}
cloud_build = {
  frontend = {
    included = [
      "speech-to-text/services/frontend/**"
    ]
    path = "speech-to-text/services/frontend/cloudbuild.yaml"
    substitutions = {
      _SERVICE_NAME = "speech-frontend"
    }
  }
  backend = {
    included = [
      "speech-to-text/services/backend/**"
    ]
    path = "speech-to-text/services/backend/cloudbuild.yaml"
    substitutions = {
      _SERVICE_NAME = "speech-backend"
    }
  }
}
cloud_run = {
  frontend = {
    location = "europe-west1"
    service_account = "sa-frontend-prod"
    cpu = "1"
    memory = "2Gi"
    sa = {
      sa-frontend-prod = [
        "roles/run.invoker"
      ]
    }
  }
  backend = {
    location = "europe-west1"
    service_account = "sa-backend-prod"
    cpu = "2"
    memory = "4Gi"
    sa = {
      sa-backend-prod = [
        "roles/run.invoker"
      ]
    }
  }
}
