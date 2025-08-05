#!/bin/bash

# Get the job name - either hardcode it or extract from Terraform output
cd infrastructure
JOB_NAME=$(terraform output -raw inference-job-name)
PROJECT_ID=$(terraform output -raw project_id)
REGION=$(terraform output -raw region)
ARTIFACTS_BUCKET=$(terraform output -raw artifacts_bucket)

# Execute the Cloud Run job
echo "Executing Cloud Run job: $JOB_NAME"
gcloud run jobs execute $JOB_NAME --region $REGION --project $PROJECT_ID

# Optionally, track the execution
echo "Job execution started. Check status in Google Cloud Console."
echo "Predictions will be saved in ${ARTIFACTS_BUCKET}."