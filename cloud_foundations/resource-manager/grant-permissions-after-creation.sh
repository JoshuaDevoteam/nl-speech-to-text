#!/bin/bash
# Grant permissions to service account after projects are created

echo "Granting permissions to sa-root-tf-rm service account..."

# Grant Owner role to sa-root-tf-rm on all three projects
for project in pj-speech-text-dev pj-speech-text-uat pj-speech-text-prod; do
    echo "Granting permissions on $project..."
    gcloud projects add-iam-policy-binding $project \
        --member="serviceAccount:sa-root-tf-rm@pj-terra-speech-text-main.iam.gserviceaccount.com" \
        --role="roles/owner"
done

echo "Permissions granted successfully!"