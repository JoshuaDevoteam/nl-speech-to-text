# Run the gcloud auth login command
gcloud auth login
# Set the project
gcloud config set project pj-terra-speech-text-main
gcloud auth application-default set-quota-project pj-terra-speech-text-main
# Run the gcloud auth application-default login command
gcloud auth application-default login
