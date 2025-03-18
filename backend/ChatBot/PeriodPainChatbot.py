import openai
from dotenv import load_dotenv
import os

load_dotenv()

openai.api_key = os.getenv("OPENAI_API_KEY")

class PeriodPainChatbot:
    def __init__(self):
        self.system_message = {
            "role": "system",
            "content": """You are a specialized chatbot focused solely on period pain management.
            Your expertise is limited to:
            - Period pain symptoms and management
            - Safe pain relief methods (both medical and natural)
            - Lifestyle adjustments for managing menstrual pain
            - Exercise recommendations during menstruation
            - Diet tips for period pain relief
            - When to seek medical attention
            - Common misconceptions about period pain

            Important guidelines:
            1. Only provide information related to period pain management
            2. Clearly state when a medical professional should be consulted
            3. Don't provide medical diagnoses
            4. Use scientifically backed information
            5. Be empathetic and supportive
            6. Redirect any non-period pain related questions

            If asked about topics outside these boundaries, politely redirect the conversation
            back to period pain management."""
        }

    def get_response(self, user_input):
        try:
            messages = [
                self.system_message,
                {"role": "user", "content": user_input}
            ]
            response = openai.ChatCompletion.create(
                model="gpt-4o",
                messages=messages,
                temperature=0.7,
                max_tokens=500,
                presence_penalty=0.6,
                frequency_penalty=0.3
            )

            return response.choices[0].message.content

        except Exception as e:
            return f"An error occurred: {str(e)}"