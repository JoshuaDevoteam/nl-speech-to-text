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
branch_regex = "release.*"
buckets = {
  datasets = {
    name = "pj-speech-text-uat-datasets"
    region = "europe-west1"
  }
  models = {
    name = "pj-speech-text-uat-models"
    region = "europe-west1"
  }
  frontend = {
    name = "pj-speech-text-uat-genai-frontend"
    region = "europe-west1"
  }
}
environment = ""
project_id = "pj-speech-text-uat"
repo_name = "nl-speech-to-text"
repo_owner = "JoshuaDevoteam"
region = "europe-west1"
service_accounts = {
  terraform = {
    create = false
    email = "sa-terraform@pj-speech-text-uat.iam.gserviceaccount.com"
  }
  cloudbuild = {
    create = false
    email = "sa-cloudbuild@pj-speech-text-uat.iam.gserviceaccount.com"
  }
  sa-frontend-uat = {
    create = false
    email = "sa-frontend-uat@pj-speech-text-uat.iam.gserviceaccount.com"
  }
}
cloud_build = {
  frontend = {
    included = [
      "services/frontend/**"
    ]
    path = "services/frontend/cloudbuild.yaml"
    substitutions = {
      _SERVICE_NAME = "frontend"
    }
  }
}
cloud_run = {
  frontend = {
    location = "europe-west1"
    service_account = "sa-frontend-uat"
    cpu = "1"
    memory = "4Gi"
    sa = {
      sa-frontend-uat = [
        "roles/run.invoker"
      ]
    }
  }
}
