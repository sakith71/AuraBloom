from flask import Flask, request, jsonify
from flask_cors import CORS
from flasgger import Swagger
import joblib
import pandas as pd
import numpy as np
import logging
import os
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("api_logs.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Create logs directory if it doesn't exist
os.makedirs('logs', exist_ok=True)

# Load the saved Random Forest model
try:
    model = joblib.load("random_forest_model.pkl")
    logger.info("Model loaded successfully")
except Exception as e:
    logger.error(f"Failed to load model: {str(e)}")
    raise

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Configure Swagger
swagger_config = {
    "headers": [],
    "specs": [
        {
            "endpoint": 'apispec',
            "route": '/apispec.json',
            "rule_filter": lambda rule: True,
            "model_filter": lambda tag: True,
        }
    ],
    "static_url_path": "/flasgger_static",
    "swagger_ui": True,
    "specs_route": "/docs/"
}

swagger = Swagger(app, config=swagger_config)

# Required features for prediction
REQUIRED_FEATURES = ['MeanCycleLength', 'LengthofMenses', 'MeanMensesLength', 'BMI']

@app.route("/", methods=["GET"])
def home():
    """
    Home endpoint
    Returns a welcome message
    ---
    responses:
      200:
        description: Welcome message
    """
    logger.info("Home endpoint accessed")
    return jsonify({
        "status": "success",
        "message": "Menstrual Cycle Length Prediction API is running!",
        "documentation": "/docs/",
        "version": "1.0.0"
    })

@app.route("/health", methods=["GET"])
def health_check():
    """
    Health check endpoint
    Returns the status of the API and model
    ---
    responses:
      200:
        description: Health status
    """
    logger.info("Health check endpoint accessed")
    try:
        # Test model with a dummy prediction
        test_data = pd.DataFrame({
            'MeanCycleLength': [30.0],
            'LengthofMenses': [5.0],
            'MeanMensesLength': [4.5],
            'BMI': [0.3]
        })
        model.predict(test_data)
        
        return jsonify({
            "status": "healthy",
            "model_loaded": True,
            "timestamp": datetime.now().isoformat()
        })
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return jsonify({
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }), 500

def validate_input(data):
    """Validate that all required features are present"""
    
    # Check if all required features are present
    missing_features = [feat for feat in REQUIRED_FEATURES if feat not in data]
    if missing_features:
        return False, f"Missing required features: {', '.join(missing_features)}"
    
    # Check if features are numeric
    for feature in REQUIRED_FEATURES:
        if feature in data:
            value = data[feature]
            if not isinstance(value, (int, float)):
                return False, f"Feature {feature} must be a number"
    
    return True, ""

@app.route("/predict", methods=["POST"])
def predict():
    """
    Make a prediction for menstrual cycle length
    ---
    parameters:
      - name: body
        in: body
        required: true
        schema:
          type: object
          required:
            - MeanCycleLength
            - LengthofMenses
            - MeanMensesLength
            - BMI
          properties:
            MeanCycleLength:
              type: number
              example: 28.5
              description: Average length of previous menstrual cycles
            LengthofMenses:
              type: number
              example: 5.0
              description: Length of menstruation period
            MeanMensesLength:
              type: number
              example: 4.5
              description: Mean length of menstruation periods
            BMI:
              type: number
              example: 0.35
              description: Body Mass Index (normalized between 0-1)
    responses:
      200:
        description: Prediction result
        schema:
          type: object
          properties:
            prediction:
              type: number
              description: Predicted length of cycle
            timestamp:
              type: string
              description: Time when prediction was made
      400:
        description: Bad request - invalid input
      500:
        description: Internal server error
    """
    try:
        # Get request ID for tracking
        request_id = request.headers.get('X-Request-ID', datetime.now().strftime('%Y%m%d%H%M%S'))
        
        # Get JSON data from request
        data = request.get_json()
        
        if not data:
            logger.warning(f"Request {request_id}: No data provided")
            return jsonify({
                "status": "error", 
                "message": "No data provided"
            }), 400
        
        # Log the incoming request
        logger.info(f"Request {request_id}: Received prediction request - {data}")
        
        # Validate input data
        is_valid, validation_message = validate_input(data)
        if not is_valid:
            logger.warning(f"Request {request_id}: Invalid input data - {validation_message}")
            return jsonify({
                "status": "error",
                "message": validation_message
            }), 400
        
        # Convert JSON to DataFrame
        input_data = pd.DataFrame([data])
        
        # Make a prediction
        prediction = model.predict(input_data)[0]
        
        # Round to 2 decimal places
        prediction = round(float(prediction), 2)
        
        # Log the prediction
        logger.info(f"Request {request_id}: Prediction successful - {prediction}")
        
        # Return the result
        return jsonify({
            "status": "success",
            "prediction": prediction,
            "timestamp": datetime.now().isoformat(),
            "request_id": request_id
        })

    except Exception as e:
        logger.error(f"Request {request_id if 'request_id' in locals() else 'unknown'}: Error during prediction - {str(e)}")
        return jsonify({
            "status": "error",
            "message": "An error occurred during prediction",
            "error": str(e)
        }), 500

@app.route("/model_info", methods=["GET"])
def model_info():
    """
    Get model information
    ---
    responses:
      200:
        description: Model information
    """
    try:
        return jsonify({
            "status": "success",
            "model_type": "Random Forest Regressor",
            "features": REQUIRED_FEATURES,
            "target": "LengthofCycle"
        })
    except Exception as e:
        logger.error(f"Error retrieving model info: {str(e)}")
        return jsonify({
            "status": "error",
            "message": "Failed to retrieve model information",
            "error": str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    logger.warning(f"Endpoint not found: {request.url}")
    return jsonify({
        "status": "error",
        "message": "Endpoint not found",
        "url": request.url
    }), 404

@app.errorhandler(405)
def method_not_allowed(error):
    logger.warning(f"Method not allowed: {request.method} {request.url}")
    return jsonify({
        "status": "error",
        "message": f"Method {request.method} not allowed for this endpoint"
    }), 405

@app.errorhandler(500)
def server_error(error):
    logger.error(f"Internal server error: {str(error)}")
    return jsonify({
        "status": "error",
        "message": "Internal server error",
        "error": str(error)
    }), 500

# Run the Flask app
if __name__ == "__main__":
    logger.info("Starting Menstrual Cycle Length Prediction API")
    app.run(host='0.0.0.0', port=5000, debug=False)