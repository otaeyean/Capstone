// chat_input.dart
import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController messageController;
  final Function(String) onSendMessage;
  final List<String> exampleQuestions;
  final Function(String) onExampleSelected;

  ChatInput({
    required this.messageController,
    required this.onSendMessage,
    required this.exampleQuestions,
    required this.onExampleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: exampleQuestions.map((question) {
              return GestureDetector(
                onTap: () => onExampleSelected(question),
                child: Chip(
                  label: Text(question),
                  backgroundColor: Colors.grey[300],
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  onSubmitted: onSendMessage,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(messageController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
