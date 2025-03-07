from flask import Flask, request, jsonify
import joblib
import pandas as pd

# Load the saved Random Forest model
model = joblib.load("random_forest_model.pkl")

# Initialize Flask app
app = Flask(__name__)

@app.route("/", methods=["GET"])
def home():
    return "Random Forest Prediction API is running!"

@app.route("/predict", methods=["POST"])
def predict():
    try:
        # Get JSON data from request
        data = request.get_json()

        # Convert JSON to DataFrame
        input_data = pd.DataFrame([data])

        # Make a prediction
        prediction = model.predict(input_data)[0]

        # Return the result
        return jsonify({"prediction": prediction})

    except Exception as e:
        return jsonify({"error": str(e)})

# Run the Flask app
if __name__ == "__main__":
    app.run(debug=True)
