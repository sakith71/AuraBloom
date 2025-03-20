from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import openai  # Using the older OpenAI library

# Set your OpenAI API key
API_KEY = "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"
openai.api_key = API_KEY

class PeriodPainChatbot:
    def _init_(self):
        """Initialize the chatbot with system context"""
        # System message to define the chatbot's role and boundaries
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
        """Get a response from the chatbot for the user's input"""
        try:
            # Create messages list for this interaction
            messages = [
                self.system_message,
                {"role": "user", "content": user_input}
            ]
            
            # Get response from OpenAI using the older API style
            response = openai.ChatCompletion.create(
                model="gpt-4o",
                messages=messages,
                temperature=0.7,
                max_tokens=500,
                presence_penalty=0.6,
                frequency_penalty=0.3
            )
            
            # Extract the response content
            return response.choices[0].message['content']
        except Exception as e:
            return f"An error occurred: {str(e)}"