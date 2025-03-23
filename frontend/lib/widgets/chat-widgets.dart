import 'package:flutter/material.dart';
import '../models/chat-message.dart';

// Custom painter for chevron arrow shape
class TriangleArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final path = Path();
    // Create a chevron/arrow pointing right
    path.moveTo(0, 0); // Top left
    path.lineTo(size.width, size.height / 2); // Middle right
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width / 4, size.height / 2); // Middle indent
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(16.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatMessageBubble(message: message);
      },
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          // Changed bot message color to white, keeping user messages pink
          color: message.isUser ? Colors.pink[100] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
          // Add a subtle border for bot messages to distinguish them from background
          border:
              message.isUser
                  ? null
                  : Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
    );
  }
}

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryPink = const Color(0xFFFF5B9D);

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 5,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: primaryPink, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          SizedBox(width: 8),
          // Updated with circular button matching post detail screen
          GestureDetector(
            onTap: () {
              if (controller.text.isNotEmpty) {
                onSubmitted(controller.text);
              }
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryPink,
                shape:
                    BoxShape
                        .circle, // Change from borderRadius to circular shape
              ),
              child: Center(
                child: Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
