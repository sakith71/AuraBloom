import 'package:flutter/material.dart';
import 'package:frontend/widgets/chat-widgets.dart';
import '../models/chat-message.dart';
import '../services/chatbot-service.dart';

class PeriodPainChatScreen extends StatefulWidget {
  const PeriodPainChatScreen({super.key});

  @override
  _PeriodPainChatScreenState createState() => _PeriodPainChatScreenState();
}

class _PeriodPainChatScreenState extends State<PeriodPainChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService(); // Initialize the service
  bool _isTyping = false; // To show typing indicator

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

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true; // Show typing indicator
    });

    _textController.clear();
    _scrollToBottom();
    
    // Test connection first
    bool isConnected = await _chatService.testConnection();
    if (!isConnected) {
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: "Cannot connect to the server. Please check your network connection and server status.",
            isUser: false,
            timestamp: DateTime.now(),
            type: MessageType.warning,
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    // Send the message to the backend and get a response
    try {
      final response = await _chatService.sendMessage(text);
      
      setState(() {
        _isTyping = false; // Hide typing indicator
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isTyping = false; // Hide typing indicator
        _messages.add(
          ChatMessage(
            text: "Sorry, I couldn't process your request. Please try again later.",
            isUser: false,
            timestamp: DateTime.now(),
            type: MessageType.warning,
          ),
        );
      });
      
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'CareBot',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        // actions: [
        //   // Add debug button
        //   IconButton(
        //     icon: const Icon(Icons.bug_report),
        //     onPressed: () => showNetworkDebugInfo(context),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessageList(
              messages: _messages,
              scrollController: _scrollController,
            ),
          ),
          // Show typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bot is typing...",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
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