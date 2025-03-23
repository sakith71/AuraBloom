import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/chat-message.dart';

void main() {
  group('ChatMessage', () {
    test('should create a chat message with all required properties', () {
      // Arrange
      final text = 'Hello, how are you?';
      final isUser = true;
      final timestamp = DateTime(2023, 5, 10, 14, 30);

      // Act
      final message = ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: timestamp,
      );

      // Assert
      expect(message.text, equals(text));
      expect(message.isUser, equals(isUser));
      expect(message.timestamp, equals(timestamp));
      expect(message.type, equals(MessageType.text)); // Default type
    });

    test('should create a chat message with custom message type', () {
      // Arrange
      final text = 'You might be experiencing cramps';
      final isUser = false;
      final timestamp = DateTime(2023, 5, 10, 14, 35);
      final type = MessageType.symptom;

      // Act
      final message = ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: timestamp,
        type: type,
      );

      // Assert
      expect(message.text, equals(text));
      expect(message.isUser, equals(isUser));
      expect(message.timestamp, equals(timestamp));
      expect(message.type, equals(MessageType.symptom));
    });

    test('should create different message types correctly', () {
      // Create messages with different types
      final textMessage = ChatMessage(
        text: 'Regular message',
        isUser: true,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );

      final symptomMessage = ChatMessage(
        text: 'You might be experiencing symptoms',
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.symptom,
      );

      final adviceMessage = ChatMessage(
        text: 'Try drinking more water',
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.advice,
      );

      final warningMessage = ChatMessage(
        text: 'Warning: consult a doctor if symptoms persist',
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.warning,
      );

      // Assert each message has the correct type
      expect(textMessage.type, equals(MessageType.text));
      expect(symptomMessage.type, equals(MessageType.symptom));
      expect(adviceMessage.type, equals(MessageType.advice));
      expect(warningMessage.type, equals(MessageType.warning));

      print('Test completed successfully!');
    });
  });

  group('MessageType enum', () {
    test('should have the correct values', () {
      // Assert all enum values exist
      expect(
        MessageType.values,
        containsAll([
          MessageType.text,
          MessageType.symptom,
          MessageType.advice,
          MessageType.warning,
        ]),
      );

      // Check enum length to ensure no new types were added without tests
      expect(MessageType.values.length, equals(4));
    });
  });
}
