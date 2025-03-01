from flask import Flask, request, jsonify
import joblib
import pandas as pd

# Load the trained Random Forest model
model = joblib.load("random_forest_model.pkl")

# Initialize Flask app
app = Flask(__name__)

@app.route('/')
def home():
    return "Menstrual Cycle Prediction API is running!"

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get JSON input from request
        data = request.get_json()

        # Validate input fields
        required_fields = ["MeanCycleLength", "LengthofMenses", "BMI"]
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing required fields!'}), 400

        # Convert input data into DataFrame
        input_df = pd.DataFrame([data])

        # Make prediction
        prediction = model.predict(input_df)

        # Return the predicted cycle length
        return jsonify({
            'predicted_next_cycle_length': round(prediction[0], 2)
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
