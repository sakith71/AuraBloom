from flask import Flask, request, jsonify
from flask_cors import CORS
import openai
import os
from PeriodPainChatbot import PeriodPainChatbot

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Root route to test if server is running
@app.route('/', methods=['GET'])
def index():
    return jsonify({"status": "Server is running", "message": "Welcome to the Period Pain Management Chatbot API"}), 200

# Simple ping endpoint for testing connectivity
@app.route('/api/ping', methods=['GET'])
def ping():
    return jsonify({"status": "success", "message": "API is reachable"}), 200

@app.route('/api/chat', methods=['GET', 'POST'])
def chat():
    chatbot = PeriodPainChatbot()
    
    try:
        if request.method == 'POST':
            data = request.get_json()
            prompt = data.get('prompt')
        else:  # GET
            data = request.args.to_dict()
            prompt = data.get('prompt')
            
        if not prompt:
            return jsonify({"error": "No prompt provided"}), 400
            
        response = chatbot.get_response(prompt)
        # For debugging, wrap response in a JSON object
        return jsonify({"response": response}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Get port from environment variable or use 8000 as default
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=True)