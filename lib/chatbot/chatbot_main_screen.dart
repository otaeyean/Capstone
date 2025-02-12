// chatbot_screen.dart
import 'package:flutter/material.dart';
import 'chat_messages.dart';
import 'chat_textfield.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<String> exampleQuestions = [
    '배당금 받는 방법?',
    '주식 사는 방법?',
    '주식 현재 가격 확인하는 방법?',
    '주식 파는 방법?',
  ];

  List<Map<String, String>> chatMessages = [
    {'sender': 'bot', 'message': '무엇을 도와드릴까요?'},
  ];

  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _addExampleQuestionResponse(String question) {
    setState(() {
      chatMessages.add({'sender': 'user', 'message': question});
      chatMessages.add({'sender': 'bot', 'message': '테스트용 예시 답변'});
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        chatMessages.add({'sender': 'user', 'message': message});
        _messageController.clear();
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('챗봇'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(chatMessages: chatMessages, scrollController: _scrollController),
          ),
          ChatInput(
            messageController: _messageController,
            onSendMessage: _addUserMessage,
            exampleQuestions: exampleQuestions,
            onExampleSelected: _addExampleQuestionResponse,
          ),
        ],
      ),
    );
  }
}