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

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm your Period Pain Management Assistant. "
            "How can I help you today?",
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

    // Get chatbot response
    String response = ChatbotService.getResponse(text);

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(
          ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Period Pain Assistant',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFF4C2CA), // Light Pink from splash screen
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4C2CA), // Light Pink
              Color(0xFFD4C0D6), // Light Purple
            ],
          ),
        ),
        child: Column(
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
      ),
    );
  }
}
