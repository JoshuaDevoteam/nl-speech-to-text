# Manual Project Creation Instructions

Ask someone with billing permissions to create the following projects:

## Projects to Create

1. **Project ID:** `pj-speech-text-dev`
   - **Display Name:** pj-speech-text-dev
   - **Parent Folder:** folders/1016983252724 (speech-to-text folder)
   - **Billing Account:** 01B87F-2B15CA-A24E45

2. **Project ID:** `pj-speech-text-uat`
   - **Display Name:** pj-speech-text-uat
   - **Parent Folder:** folders/1016983252724 (speech-to-text folder)
   - **Billing Account:** 01B87F-2B15CA-A24E45

3. **Project ID:** `pj-speech-text-prod`
   - **Display Name:** pj-speech-text-prod
   - **Parent Folder:** folders/1016983252724 (speech-to-text folder)
   - **Billing Account:** 01B87F-2B15CA-A24E45

## Commands to Create Projects (for someone with proper billing permissions)

```bash
# Create dev project
gcloud projects create pj-speech-text-dev \
    --name="pj-speech-text-dev" \
    --folder=1016983252724

gcloud beta billing projects link pj-speech-text-dev \
    --billing-account=01B87F-2B15CA-A24E45

# Create uat project
gcloud projects create pj-speech-text-uat \
    --name="pj-speech-text-uat" \
    --folder=1016983252724

gcloud beta billing projects link pj-speech-text-uat \
    --billing-account=01B87F-2B15CA-A24E45

# Create prod project
gcloud projects create pj-speech-text-prod \
    --name="pj-speech-text-prod" \
    --folder=1016983252724

gcloud beta billing projects link pj-speech-text-prod \
    --billing-account=01B87F-2B15CA-A24E45
```

## After Projects are Created

Once the projects are created, run the import script to import them into Terraform state:

```bash
./import-projects.sh
```

Then verify the import was successful:

```bash
terraform plan
```

The plan should show no changes if the projects were created correctly.