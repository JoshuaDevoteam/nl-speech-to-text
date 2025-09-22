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
branch_regex = ".*"
buckets = {
  datasets = {
    name = "pj-speech-text-dev-datasets"
    region = "europe-west1"
  }
  models = {
    name = "pj-speech-text-dev-models"
    region = "europe-west1"
  }
  frontend = {
    name = "pj-speech-text-dev-genai-frontend"
    region = "europe-west1"
  }
  audio_uploads = {
    name = "pj-speech-text-dev-audio-uploads"
    region = "europe-west1"
  }
  transcripts = {
    name = "pj-speech-text-dev-transcripts"
    region = "europe-west1"
  }
}
project_id = "pj-speech-text-dev"
repo_name = "nl-speech-to-text"
repo_owner = "JoshuaDevoteam"
region = "europe-west1"
service_accounts = {
  terraform = {
    create = false
    email = "sa-terraform@pj-speech-text-dev.iam.gserviceaccount.com"
  }
  cloudbuild = {
    create = false
    email = "sa-cloudbuild@pj-speech-text-dev.iam.gserviceaccount.com"
  }
  sa-frontend-dev = {
    create = false
    email = "sa-frontend-dev@pj-speech-text-dev.iam.gserviceaccount.com"
  }
  sa-backend-dev = {
    create = false
    email = "sa-backend-dev@pj-speech-text-dev.iam.gserviceaccount.com"
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
    service_account = "sa-frontend-dev"
    cpu = "1"
    memory = "2Gi"
    sa = {
      sa-frontend-dev = [
        "roles/run.invoker"
      ]
    }
  }
  backend = {
    location = "europe-west1"
    service_account = "sa-backend-dev"
    cpu = "2"
    memory = "4Gi"
    sa = {
      sa-backend-dev = [
        "roles/run.invoker"
      ]
    }
  }
}
