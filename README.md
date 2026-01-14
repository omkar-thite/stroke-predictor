# Stroke Predictor - MLOps Project
**Archived**

A complete MLOps solution for training and deploying a machine learning model that predicts stroke risk based on healthcare data.

## Data source:  
[Kaggle Stroke Prediction Dataset](https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset/data)

## Project Overview

This project implements an end-to-end MLOps pipeline using Google Cloud Platform (GCP) services:

1. **Model Training Pipeline**: Trains a stroke prediction model using healthcare data
2. **Model Inference Service**: Deploys the trained model as a Cloud Run job
3. **MLflow Integration**: Tracks experiments and model artifacts using MLflow with PostgreSQL backend
4. **Infrastructure as Code**: Uses Terraform to provision and manage all required GCP resources

## Architecture

The solution uses the following GCP services:

- Cloud Run Jobs (for training and inference)
- Cloud SQL (PostgreSQL for MLflow backend)
- Artifact Registry (for Docker images)
- Google Cloud Storage (for model artifacts)
- VPC networking with private connectivity

All produces thorugh terraform.  
You have to create a state bucket manually to store terraform state.

## Prerequisites

1. Google Cloud Platform account with a project
2. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed
3. [Terraform](https://www.terraform.io/downloads.html) v1.12.2 installed
4. [Docker](https://docs.docker.com/get-docker/) installed

## Required GCP IAM Roles

Your service account needs these roles:
- `roles/iam.serviceAccountAdmin`
- `roles/resourcemanager.projectIamAdmin`
- `roles/vpcaccess.admin`
- `roles/compute.networkAdmin`
- `roles/cloudsql.admin`
- `roles/artifactregistry.admin`
- `roles/run.admin`
- `roles/storage.admin`
- Project IAM Admin
- Service Account User
- Service Account Token Creator

## Required GCP APIs

Ensure these APIs are enabled in your project:
- Serverless VPC Access API
- Cloud Run API
- Cloud SQL Admin API
- Artifact Registry API
- Compute Engine API
- Storage API

## Setup Instructions

= Create an empty `.env` file with `experiment_name` in root folder.  
- Authenticate your google account with sdk to run `gcloud` commnads. 
- Never commit service account keys to version control

### 1. Clone this repository
```bash
git clone https://github.com/omkar-thite/stroke-predictor.git
cd stroke_predictor
```

### 2. Update variable files
Edit the [`infrastructure/vars/prod.tfvars`](infrastructure/vars/vars_template.txt) file with your GCP project information.

### 3. Deploy Infrastructure

```bash
cd infrastructure
terraform init
terraform plan --var-file=vars/prod.tfvars -out=tfplan
terraform apply tfplan
```
This creates docker images and resources for training and inference.  

**Note:** The PostgreSQL instance creation can take 10-20 minutes. This is normal as Google needs to:
- Allocate compute resources
- Set up the database engine
- Configure networking
- Set up high availability if configured

### 4. Run Training Pipeline

```bash
./train_setup.sh
```

This script:
1. Gets the Cloud Run job name, project ID and region from Terraform outputs
2. Executes the training job on Cloud Run
3. Stores model artifacts in the GCS bucket

### 5. Run Inference Pipeline

```bash
./inference.sh
```

This script:
1. Gets the inference job name, project ID and region from Terraform outputs
2. Executes the inference job on Cloud Run
3. Saves predictions to the GCS bucket

## Project Structure

- [`data`](data): Contains healthcare stroke dataset and sample input data for inference
- [`dockerfiles`](dockerfiles): Docker configurations for training and inference containers
- [`infrastructure`](infrastructure): Terraform modules for GCP resource provisioning
  - `/modules/artifact_registry`: Manages Docker image repository
  - `/modules/cloud_run_job`: Sets up Cloud Run jobs for training and inference
  - `/modules/gcs`: Creates storage bucket for model artifacts
  - `/modules/networking`: Configures VPC for private connectivity
  - `/modules/postgresql`: Sets up PostgreSQL instance for MLflow backend
- [`notebooks`](notebooks): Jupyter notebooks for exploratory data analysis

## Troubleshooting

GCP configuration is complex and may result in errors. Common issues:
- Insufficient permissions: Verify all required roles are assigned
- API not enabled: Check that all required APIs are enabled
- Resource dependencies: Resources must be created in the right order
- Region availability: Ensure chosen region supports all required services

## License

MIT License
