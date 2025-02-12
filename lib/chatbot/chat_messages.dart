// chat_messages.dart
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  final List<Map<String, String>> chatMessages;
  final ScrollController scrollController;

  ChatMessages({required this.chatMessages, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(16),
      itemCount: chatMessages.length,
      itemBuilder: (context, index) {
        bool isUser = chatMessages[index]['sender'] == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUser ? Colors.white : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(chatMessages[index]['message']!),
          ),
        );
      },
    );
  }
}