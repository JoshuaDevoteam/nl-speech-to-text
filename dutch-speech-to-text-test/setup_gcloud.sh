# Run the gcloud auth login command
gcloud auth login
# Set the project
gcloud config set project pj-dutch-speech-to-text
gcloud auth application-default set-quota-project pj-dutch-speech-to-text
# Run the gcloud auth application-default login command
gcloud auth application-default login
