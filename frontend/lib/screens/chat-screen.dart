import 'package:flutter/material.dart';
import 'package:frontend/widgets/chat-widgets.dart';
import '../models/chat-message.dart';
// import '../services/chatbot-service.dart';
import '../helpers/Service.dart';

class PeriodPainChatScreen extends StatefulWidget {
  const PeriodPainChatScreen({super.key});

  @override
  _PeriodPainChatScreenState createState() => _PeriodPainChatScreenState();
}

class _PeriodPainChatScreenState extends State<PeriodPainChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm your Period Pain Management Assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

void _handleSubmitted(String text) {
  if (text.trim().isEmpty) return;

  setState(() {
    _messages.add(
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );
  });

  _textController.clear();
  _scrollToBottom();

  // Get chatbot response from the server
  ChatbotService.getResponse(text).then((response) {
    setState(() {
      _messages.add(
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();

    // Example: Get chatbot response
    String response = ChatbotService.getResponse(text);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(
          ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the global scaffold background color
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // Match the global background color so the app bar blends in
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0, // remove the drop shadow if you like a flat look
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'CareBot',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black, // ensure the title is visible on a light bg
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessageList(
              messages: _messages,
              scrollController: _scrollController,
            ),
          ),
          ChatInputField(
            controller: _textController,
            onSubmitted: _handleSubmitted,
          ),
        ],
      ),
    );
  }
}
