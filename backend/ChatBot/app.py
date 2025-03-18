from flask import Flask, request, jsonify
from PeriodPainChatbot import PeriodPainChatbot

app = Flask(__name__)

@app.route('/', methods=['GET'])
def api_status():
    return jsonify({"status": "API is running"}), 200

@app.route('/chat', methods=['POST'])
def chat():
    try:
        chatbot = PeriodPainChatbot()
        user_input = request.json.get('message')

        if not user_input:
            return jsonify({"error": "Message is required"}), 400

        bot_reply = chatbot.get_response(user_input)

        return jsonify({"reply": bot_reply}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)