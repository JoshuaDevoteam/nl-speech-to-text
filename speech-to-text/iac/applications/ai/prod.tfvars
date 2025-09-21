artifact_registry_repositories = {
  pipeline-containers = {
    description    = "Repository containing pipeline Docker containers."
    format         = "DOCKER"
    location       = "europe-west1"
    role_group_map = {}
  }
  pipeline-packages = {
    description    = "Repository containing pipeline Python packages."
    format         = "PYTHON"
    location       = "europe-west1"
    role_group_map = {}
  }
  pipeline-templates = {
    description    = "Repository containing Kubeflow Pipelines templates."
    format         = "KFP"
    location       = "europe-west1"
    role_group_map = {}
  }
}
branch_regex = "main"
buckets = {
  datasets = {
    name   = "pj-speech-text-prod-datasets"
    region = "europe-west1"
  }
  models = {
    name   = "pj-speech-text-prod-models"
    region = "europe-west1"
  }
}
environment = ""
project_id  = "pj-speech-text-prod"
repo_name   = "nl-speech-to-text"
repo_owner  = "JoshuaDevoteam"
region      = "europe-west1"
service_accounts = {
  terraform = {
    create = false
    email  = "sa-terraform@pj-speech-text-prod.iam.gserviceaccount.com"
  }
  cloudbuild = {
    create = false
    email  = "sa-cloudbuild@pj-speech-text-prod.iam.gserviceaccount.com"
  }
}