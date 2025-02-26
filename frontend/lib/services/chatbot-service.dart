class ChatbotService {
  static const String systemPrompt = """
    You are a specialized chatbot focused solely on period pain management.
    Your expertise is limited to:
    - Period pain symptoms and management
    - Safe pain relief methods (both medical and natural)
    - Lifestyle adjustments for managing menstrual pain
    - Exercise recommendations during menstruation
    - Diet tips for period pain relief
    - When to seek medical attention
    - Common misconceptions about period pain
  """;

  static List<String> getDefaultOptions() {
    return [
      "Track Pain Symptoms",
      "Pain Relief Methods",
      "Exercise Tips",
      "Diet Recommendations",
      "When to See a Doctor",
    ];
  }

  static String getResponse(String userInput) {
    // TODO: Replace with actual API integration
    if (userInput.toLowerCase().contains("pain")) {
      return "There are several ways to manage period pain:\n"
          "1. Over-the-counter pain relievers\n"
          "2. Heat therapy (using a heating pad)\n"
          "3. Light exercise\n"
          "4. Proper rest\n"
          "Would you like more specific information about any of these methods?";
    }
    return "How can I help you manage your period pain today?";
  }
}
