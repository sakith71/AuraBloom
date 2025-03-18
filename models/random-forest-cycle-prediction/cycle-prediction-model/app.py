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

@app.route("/predict", methods=["POST"])
def predict():
    try:
        # Get JSON data from request
        data = request.get_json()
        print(f"Received data: {data}")
        
        # Check that all required fields are present
        required_fields = ["MeanCycleLength", "LengthofMenses", "MeanMensesLength", "BMI"]
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing required field: {field}"}), 400
        
        # Prepare input data based on model's expected features
        if using_actual_model and hasattr(model, 'feature_names_in_'):
            input_data = {}
            for feature in model.feature_names_in_:
                if feature in data:
                    input_data[feature] = float(data[feature])
                else:
                    # For any missing required features, use reasonable defaults
                    if feature == "MeanCycleLength":
                        input_data[feature] = float(data.get("MeanCycleLength", 28))
                    elif feature == "MeanMensesLength":
                        input_data[feature] = float(data.get("MeanMensesLength", 5))
                    elif feature == "LengthofMenses":
                        input_data[feature] = float(data.get("LengthofMenses", 5))
                    elif feature == "BMI":
                        input_data[feature] = float(data.get("BMI", 22.5))
                    else:
                        # For any other features, use default value of 0
                        input_data[feature] = 0.0
        else:
            # Default input data structure
            input_data = {
                "MeanCycleLength": float(data["MeanCycleLength"]),
                "LengthofMenses": float(data["LengthofMenses"]),
                "MeanMensesLength": float(data["MeanMensesLength"]),
                "BMI": float(data["BMI"])
            }
        
        # Convert JSON to DataFrame
        input_df = pd.DataFrame([input_data])
        print(f"Input dataframe shape: {input_df.shape}")
        print(f"Input dataframe columns: {input_df.columns.tolist()}")
        
        # Make a prediction
        try:
            prediction = model.predict(input_df)[0]
            prediction_success = True
        except Exception as e:
            print(f"Error during prediction: {e}")
            traceback.print_exc()
            # Fallback to using MeanCycleLength as prediction
            prediction = float(data["MeanCycleLength"])
            prediction_success = False
        
        print(f"Prediction: {prediction}")
        
        # Return the result with information about which model was used
        return jsonify({
            "prediction": float(prediction),
            "usedActualModel": using_actual_model and prediction_success,
            "modelType": "Random Forest" if (using_actual_model and prediction_success) else "Simple Fallback"
        })

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route("/predict_for_user/<user_id>", methods=["GET"])
def predict_for_user(user_id):
    try:
        # Get user data from Firestore
        user_doc = db.collection('users').document(user_id).get()
        
        if not user_doc.exists:
            return jsonify({"error": "User not found"}), 404
        
        user_data = user_doc.to_dict()
        print(f"User data: {user_data}")
        
        # Extract features needed for prediction - using correct feature names for the model
        if using_actual_model and hasattr(model, 'feature_names_in_'):
            # Use the expected feature names from the model
            input_data = {}
            for feature in model.feature_names_in_:
                if feature == "MeanCycleLength":
                    input_data[feature] = float(user_data.get("cycleLength", 28))
                elif feature == "MeanMensesLength":
                    input_data[feature] = float(user_data.get("periodLength", 5))
                elif feature == "LengthofMenses":
                    input_data[feature] = float(user_data.get("periodLength", 5))
                elif feature == "BMI":
                    input_data[feature] = float(user_data.get("bmi", 22.5))
                else:
                    # For any other features, use default value of 0
                    input_data[feature] = 0.0
        else:
            # Default input data structure if we don't know the exact feature names
            input_data = {
                "MeanCycleLength": float(user_data.get("cycleLength", 28)),
                "MeanMensesLength": float(user_data.get("periodLength", 5)),
                "LengthofMenses": float(user_data.get("periodLength", 5)),
                "BMI": float(user_data.get("bmi", 22.5))
            }
        
        print(f"Input data: {input_data}")
        
        # Convert to DataFrame for model prediction
        input_df = pd.DataFrame([input_data])
        
        # Make prediction for cycle length
        try:
            predicted_cycle_length = model.predict(input_df)[0]
            prediction_success = True
        except Exception as e:
            print(f"Error during prediction: {e}")
            traceback.print_exc()
            # Fallback to simple calculation
            predicted_cycle_length = float(user_data.get("cycleLength", 28))
            prediction_success = False
            
        # Round to nearest whole number
        predicted_cycle_length = round(predicted_cycle_length)
        print(f"Predicted cycle length: {predicted_cycle_length}")
        
        # Calculate next period start date
        last_period_start = None
        if "lastCycleStartDate" in user_data and user_data["lastCycleStartDate"]:
            try:
                last_period_start = datetime.fromisoformat(user_data["lastCycleStartDate"].replace("Z", "+00:00") if "Z" in user_data["lastCycleStartDate"] else user_data["lastCycleStartDate"])
            except Exception as e:
                print(f"Error parsing lastCycleStartDate: {e}")
        
        if not last_period_start and "lastCycleStartDate" in user_data and user_data["lastCycleStartDate"]:
            try:
                last_period_start = datetime.fromisoformat(user_data["lastCycleStartDate"].replace("Z", "+00:00") if "Z" in user_data["lastCycleStartDate"] else user_data["lastCycleStartDate"])
            except Exception as e:
                print(f"Error parsing lastCycleStartDate: {e}")
        
        if not last_period_start:
            # If we still don't have a date, use current date as fallback
            last_period_start = datetime.now()
            print("No valid last period date found, using current date as fallback")
        
        next_period_start = last_period_start + timedelta(days=int(predicted_cycle_length))
        
        # Update user document with predictions
        update_data = {
            "predictedCycleLength": int(predicted_cycle_length),
            "predictedNextPeriodStart": next_period_start.isoformat(),
            "lastPredictionDate": datetime.now().isoformat(),
            "usedActualModel": using_actual_model and prediction_success
        }
        
        db.collection('users').document(user_id).update(update_data)
        print(f"Updated user with predictions: {update_data}")
        
        # Return the prediction results with information about which model was used
        return jsonify({
            "userId": user_id,
            "predictedCycleLength": int(predicted_cycle_length),
            "nextPeriodStartDate": next_period_start.isoformat(),
            "lastPeriodStartDate": last_period_start.isoformat(),
            "usedActualModel": using_actual_model and prediction_success,
            "modelType": "Random Forest" if (using_actual_model and prediction_success) else "Simple Fallback"
        })
        
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route("/update_after_period", methods=["POST"])
def update_after_period():
    try:
        data = request.get_json()
        print(f"Update period data: {data}")
        user_id = data.get("userId")
        actual_period_start = data.get("actualPeriodStartDate")
        period_length = data.get("periodLength")
        
        if not user_id or not actual_period_start:
            return jsonify({"error": "Missing userId or actualPeriodStartDate"}), 400
            
        # Get user document
        user_doc = db.collection('users').document(user_id).get()
        if not user_doc.exists:
            return jsonify({"error": "User not found"}), 404
            
        user_data = user_doc.to_dict()
        
        # Calculate actual cycle length
        last_period_start = None
        if "lastCycleStartDate" in user_data and user_data["lastCycleStartDate"]:
            try:
                last_period_start = datetime.fromisoformat(user_data["lastCycleStartDate"].replace("Z", "+00:00") if "Z" in user_data["lastCycleStartDate"] else user_data["lastCycleStartDate"])
            except Exception as e:
                print(f"Error parsing lastCycleStartDate: {e}")
        
        if not last_period_start and "lastCycleStartDate" in user_data and user_data["lastCycleStartDate"]:
            try:
                last_period_start = datetime.fromisoformat(user_data["lastCycleStartDate"].replace("Z", "+00:00") if "Z" in user_data["lastCycleStartDate"] else user_data["lastCycleStartDate"])
            except Exception as e:
                print(f"Error parsing lastCycleStartDate: {e}")
        
        try:
            actual_period_start_date = datetime.fromisoformat(actual_period_start.replace("Z", "+00:00") if "Z" in actual_period_start else actual_period_start)
        except Exception as e:
            print(f"Error parsing actualPeriodStartDate: {e}")
            # Fallback to current date if date parsing fails
            actual_period_start_date = datetime.now()
        
        if last_period_start:
            actual_cycle_length = (actual_period_start_date - last_period_start).days
            if actual_cycle_length < 0:
                # If negative days (shouldn't happen), use default
                actual_cycle_length = user_data.get("cycleLength", 28)
                print(f"Warning: Negative cycle length calculated, using default: {actual_cycle_length}")
        else:
            actual_cycle_length = user_data.get("cycleLength", 28)
        
        # Update user data
        update_data = {
            "lastCycleStartDate": actual_period_start,
            "lastCycleStartDate": actual_period_start,
            "actualCycleLength": actual_cycle_length
        }
        
        if period_length:
            update_data["periodLength"] = period_length
        
        # Update Firestore
        db.collection('users').document(user_id).update(update_data)
        print(f"Updated user after period: {update_data}")
        
        # Re-predict for next cycle
        # This will automatically use the updated data
        return predict_for_user(user_id)
        
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

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