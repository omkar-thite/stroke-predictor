#!/bin/bash

cd infrastructure

JOB_NAME=$(terraform output -raw train-job-name)
PROJECT_ID=$(terraform output -raw project_id)
REGION=$(terraform output -raw region)

export EXECUTE_JOB_TYPE=training

# Execute the Cloud Run job
echo "Executing Cloud Run job: $JOB_NAME"
gcloud run jobs execute $JOB_NAME --region $REGION --project $PROJECT_ID

echo "Training job execution started. Check status in Google Cloud Console."
