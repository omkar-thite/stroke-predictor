import os
import joblib

import pandas as pd

from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.base import BaseEstimator, TransformerMixin

from sklearn.metrics import accuracy_score, log_loss

from google.cloud import storage

import xgboost as xgb
from xgboost import XGBClassifier

import mlflow
from mlflow.tracking import MlflowClient

from dotenv import load_dotenv

load_dotenv()

# URI to database
MLFLOW_TRACKING_URI = os.getenv('MLFLOW_TRACKING_URI')
experiment_name = os.getenv('experiment_name')

mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)

gcs_bucket_name = os.getenv('GCP_BUCKET_NAME')
experiment_name = os.getenv('experiment_name')
gcs_artifact_location = f"gs://{gcs_bucket_name}/mlartifacts/"

# Set mlflow experiment
experiment = mlflow.get_experiment_by_name(experiment_name)

if experiment is None:
    mlflow.create_experiment(name=experiment_name, artifact_location=gcs_artifact_location)

mlflow.set_experiment(experiment_name)


categorical_cols = ['work_type', 'smoking_status']
numerical_cols = ['bmi', 'age', 'avg_glucose_level']
    
def read_data(file):
    df = pd.read_csv(file)
    
    # Separate features and target
    X = df.drop('stroke', axis=1)
    y = df['stroke']
    return X, y

def map_values(X):
    X = X.replace("N/A", pd.NA)

    X['gender'] = X['gender'].map({'Male': 0, 'Female': 1, 'Other': -1})
    X['ever_married'] = X['ever_married'].map({'Yes': 1, 'No': 0})
    X['Residence_type'] = X['Residence_type'].map({'Urban': 1, 'Rural': 0})
    return X

# Define the column transformer
def model_pipeline():

    num_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='median')),  # Replace missing values with medianan
        ('scaler', StandardScaler())
    ])

    preprocessor = ColumnTransformer(
        transformers=[
            ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_cols),
            ('num', num_transformer, numerical_cols)]
    )


    # Define the model pipeline
    pipeline = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('classifier', XGBClassifier())
    ])

    return pipeline


def register_model(run_id, stg='development'):
    
    model_uri = f"runs:/{run_id}/model"
    result = mlflow.register_model(model_uri, "xgb_model")

    # Add a tag to the registered model version
    client = MlflowClient()
    client.set_model_version_tag(
        name="xgb_model",
        version=result.version,
        key="stage",
        value= stg
    )


def train_model(X, y):

    with mlflow.start_run():
        X = map_values(X)
        xgb_classifier_pipeline = model_pipeline()

        # Fit the pipeline
        xgb_classifier_pipeline.fit(X, y)

        y_pred = xgb_classifier_pipeline.predict(X)
        log_loss_ = log_loss(y, y_pred)
        accuracy = accuracy_score(y, y_pred)

        mlflow.log_metric('log_loss', log_loss_)
        mlflow.log_metric('accuracy', accuracy)

        os.makedirs("../models", exist_ok=True)
        joblib.dump(xgb_classifier_pipeline, "../models/model_pipeline.pkl")

        # Log the file as an artifact
        mlflow.log_artifact("../models/model_pipeline.pkl")
        
        run = mlflow.active_run()
        run_id = run.info.run_id

        # Log the model using MLflow's sklearn flavor
        mlflow.sklearn.log_model(
            sk_model=xgb_classifier_pipeline,
            name="model"
        )

        register_model(run_id)
        
        return run_id

if __name__=='__main__':
    X, y = read_data('healthcare-dataset-stroke-data.csv')
    run_id = train_model(X, y)