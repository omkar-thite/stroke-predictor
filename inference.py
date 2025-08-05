import os
import json
import mlflow
import pandas as pd

from google.cloud import storage

from mlflow.tracking import MlflowClient

INPUT_FILE_PATH = 'input_data.json'

# Set MLflow tracking URI
MLFLOW_TRACKING_URI = os.getenv('MLFLOW_TRACKING_URI')
mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)

# GCS bucket for saving predictions
GCS_BUCKET = os.getenv('ARTIFACTS_BUCKET_NAME')

# Initialize MLflow client
client = MlflowClient()

model_name = "xgb_model"  # The model name used in register_model()
model_versions = client.search_model_versions(f"name='{model_name}'")
latest_version = max([model_version.version for model_version in model_versions])

print(f"Loading {model_name} version {latest_version}")

# Load the model directly from the model registry
model_uri = f"models:/{model_name}/{latest_version}"
model = mlflow.pyfunc.load_model(model_uri)

def map_values(X):
    X = X.replace("N/A", pd.NA)
    X = X.fillna(-1)

    X['gender'] = X['gender'].map({'Male': 0, 'Female': 1, 'Other': -1})
    X['ever_married'] = X['ever_married'].map({'Yes': 1, 'No': 0})
    X['Residence_type'] = X['Residence_type'].map({'Urban': 1, 'Rural': 0})
    return X

with open(INPUT_FILE_PATH, 'rb') as input_file:
    input_data = json.load(input_file)
    df = pd.DataFrame(input_data)
    
    df = map_values(df)
    predictions = model.predict(df)

    print("Predictions:")
    print(predictions)

    # save predictions to file
    pd.DataFrame({"predictions": predictions}).to_csv("predictions.csv", index=False)

    # Also save to GCS bucket
    if GCS_BUCKET:
        timestamp = pd.Timestamp.now().strftime("%Y%m%d_%H%M%S")
        blob_name = f"predictions/predictions_{timestamp}.csv"
        
        # Upload to GCS
        storage_client = storage.Client()
        bucket = storage_client.bucket(GCS_BUCKET)
        blob = bucket.blob(blob_name)
        
        blob.upload_from_filename("predictions.csv")
        print(f"Predictions saved to gs://{GCS_BUCKET}/{blob_name}")


