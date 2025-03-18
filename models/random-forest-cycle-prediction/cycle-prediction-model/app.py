from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore
import json
import os
from datetime import datetime, timedelta
import joblib
import pandas as pd
import traceback

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Create a temporary file with the Firebase credentials
service_account_file = "firebase_credentials.json"
with open(service_account_file, "w") as f:
    json.dump({
        "type": "service_account",
        "project_id": "aurabloom-c8b3f",
        "private_key_id": "a5aecbdf4ed30328a3d1359dd218b2e607887751",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCLLnzjOZq0iUAk\nse1+/56dkoHvck1RbH3QgHbQIv6bWheIdG2pcmQkCE2WgZbrwpJW0B0IcWXXADLs\ncap1kJic2a8VcFhy+DPjecg61yk6tmw98YoeUGPEH7BvSVfjqtYkaWukvb7nTgEP\nyjEmOgm9gjzHHns1fXgWquEhC6p1fNhZqaBW+4VJyVxBptISkljplz+a6lcA7nlm\nfzE6c2aaC4C2KzTRKwPmFvhhN1pFI1om0n2msi04cjVBejixHjq9DVsHWY9MLa9+\noXtEx9xxsC6DpLPUw409tmwtS+Dt7ugk154Qx+7NhitaEGa9rXwKmRJkAcuLFrFP\nS5HRDO4JAgMBAAECggEADu+hNV1ELeWgvY9elkdmRTCowwJ4K6nB4rM2jOWEfzVu\n2xTrg8ij2H4PnXwwrwJFZA2XYAWTUTxTOq6EBXPL/OEbeeiBhWz/XIUAKNhYM1XK\nTedy1Af6fNyNuZOcW/FEY8nwZFB8gSQM1x3yolCOJQkp7pBl1nqtfXk/CaXP2CWy\nKoSp2F3IBs3YVaHk6iyJhdGrscMCOA9lNr6EFuzT2UVBth0wNJ+UyovqqbFgT5QA\nfagntTLkM1ZexsSUaEx+mVlMrYYqznKZKywGg3adLK/fFEYTfNt9eOF9n1RqBk85\nkFYcsFwcPBqdEMcXekOsCS+IMkww8cTeCGtXOPE8gQKBgQC85VI5KyUnHk9PvN9V\nqQ5k0KzVcqnqZ1mHBa9wBHjoRDN2g/lqxODNA7Oo7W4PxGMxLQnB+Tqb2kxm+MlC\noBwcXZVlfW5/MZ3e59Oi7aBAYY1iEx7aeZUoPEB9gRngopPdMcM94kBweDvTPRS1\nWXBe0FRBn8o+TCu8vYzr1PCAMQKBgQC8oAcE2q3p0I39r8JVbOuq67M2vrP1Pgzf\nzyY12zNJFCy+LgMc7/Ezo90YuJ3wTkoA8sWW5qEfNaZ5nOhRpx/vDxCny42A2Rmj\ndi7KDc3vAd2TGsJar+u8BjGqEMRHd1FKz5CuIg0rHYgJJdKWlpxTQAkka2MmYZ0a\nc3uc6TPtWQKBgFF56JlYDtJstHEEWqCsJtU9XQ9EQh4lLeybeyyqASzOHhSEoFR5\nTy2e5yN6JfsPDmnrr0XHpowLAOF5dfYS8Y0aoJICJGMgl6PKAvNH49NhQIaJEMnT\nn46XTonT4cGO3pCOIlTS/lCEy+k1c3U1es6qtW0I60cru8HRULN4SbRBAoGAZ/eg\nxskuEPF2Qj1NVT6rC1PNPUCR+nwQJpCMVCUVOJOZMd40sw+CGF+ar1SbIWhVm/40\ncL+AUa6FqwSUfOUsUd0w5fvpa/q+Cf5LPe2r87BIjBu0wr2yprmXSFDjjyyyLxUH\nfyOftIMbh0dEsuIjGjPylhNm3DHzoS/EE7HqgEkCgYAtqmM6QFL4fdrGYpQnjNEB\nj7eQabuZP+xaYGV/P/IvpxoA+S/ZB7Oj9vjpCKdA0KrtMy9ZHqJlSWSmPfv56wNb\n+/AAqvTf8dEG/KhlSOY5hjczrSZrwjAmW4xnVybZhaBRTkSzlsKjs/fXU8EPSW0B\nx70QIPGr3v7YTgaESer+xw==\n-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk-fbsvc@aurabloom-c8b3f.iam.gserviceaccount.com",
        "client_id": "104733157803645017419",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40aurabloom-c8b3f.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
    }, f)

# Initialize Firebase with the credentials
cred = credentials.Certificate(service_account_file)
firebase_admin.initialize_app(cred)
db = firestore.client()

# Set the path to your model file - update this to the correct path
MODEL_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "random_forest_model.pkl")
print(f"Looking for model at: {MODEL_PATH}")

# Flag to track if we're using the actual trained model
using_actual_model = False

# Load the saved Random Forest model
try:
    if os.path.exists(MODEL_PATH):
        model = joblib.load(MODEL_PATH)
        using_actual_model = True
        print("Actual Random Forest model loaded successfully!")
        
        # Print feature names if available to help with debugging
        if hasattr(model, 'feature_names_in_'):
            print(f"Model expects these feature names: {model.feature_names_in_}")
    else:
        print(f"Model file not found at {MODEL_PATH}")
        # Create a dummy model for testing
        from sklearn.ensemble import RandomForestRegressor
        model = RandomForestRegressor()
        model.fit([[28, 5, 5, 25]], [28])  # Dummy training
        print("Created fallback model for testing - NOT using actual Random Forest model")
        using_actual_model = False
except Exception as e:
    print(f"Error loading model: {e}")
    # Create a dummy model for testing
    from sklearn.ensemble import RandomForestRegressor
    model = RandomForestRegressor()
    model.fit([[28, 5, 5, 25]], [28])  # Dummy training
    print("Created fallback model for testing - NOT using actual Random Forest model")
    using_actual_model = False

@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "status": "ok",
        "message": "Menstrual Cycle Prediction API is running!",
        "usingActualModel": using_actual_model
    })

# Clean up the credentials file when the app exits
@app.teardown_appcontext
def cleanup(exception=None):
    if os.path.exists(service_account_file):
        try:
            os.remove(service_account_file)
            print(f"Removed temporary credentials file: {service_account_file}")
        except Exception as e:
            print(f"Error removing credentials file: {e}")

# Run the Flask app
if __name__ == "__main__":
    try:
        print("Starting the server...")
        app.run(debug=True, host='0.0.0.0', port=8000)
    finally:
        # Ensure the credentials file is removed even if app fails to start
        if os.path.exists(service_account_file):
            os.remove(service_account_file)
            print(f"Removed temporary credentials file: {service_account_file}")