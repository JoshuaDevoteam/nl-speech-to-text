# Run the gcloud auth login command
gcloud auth login
# Set the project
gcloud config set project pj-speech-text-dev
gcloud auth application-default set-quota-project pj-speech-text-dev
# Run the gcloud auth application-default login command
gcloud auth application-default login
