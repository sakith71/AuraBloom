from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/', methods=['GET'])
def api_status():
    return jsonify({"status": "API is running"}), 200

@app.route('/chat', methods=['POST'])
def chat():
    try:
        user_input = request.json.get('message')

        if not user_input:
            return jsonify({"error": "Message is required"}), 400

        print("Initializing post endpoint to retrieve chat messages from the user.")

        return jsonify({"message": f"Recieved: {user_input}"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)