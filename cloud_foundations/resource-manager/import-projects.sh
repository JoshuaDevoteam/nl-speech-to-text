#!/bin/bash
# Import script for manually created projects

echo "Starting project import process..."

# Import pj-speech-text-dev
echo "Importing pj-speech-text-dev..."
terraform import 'module.basic.module.projects_in_folder_root["speech-to-text"].google_project.project["pj-speech-text-dev"]' pj-speech-text-dev

# Import pj-speech-text-uat
echo "Importing pj-speech-text-uat..."
terraform import 'module.basic.module.projects_in_folder_root["speech-to-text"].google_project.project["pj-speech-text-uat"]' pj-speech-text-uat

# Import pj-speech-text-prod
echo "Importing pj-speech-text-prod..."
terraform import 'module.basic.module.projects_in_folder_root["speech-to-text"].google_project.project["pj-speech-text-prod"]' pj-speech-text-prod

echo "Import complete!"
echo ""
echo "Now run 'terraform plan' to verify the imported state matches your configuration."