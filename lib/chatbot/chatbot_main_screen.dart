import 'package:flutter/material.dart';
import 'chat_messages_ui.dart';
import 'chat_textfield.dart';
import 'package:stockapp/server/Chatbot/chatbot_server.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<Map<String, String>> chatMessages = [];
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  String userId = '';

  @override
  void initState() {
    super.initState();
    _getUserNickname().then((_) {
      _fetchChatHistory();
    });
  }

  Future<void> _getUserNickname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('nickname') ?? 'defaultUser';
    });
  }

  Future<void> _fetchChatHistory() async {
    if (userId.isEmpty) return;
    final url = Uri.parse('http://withyou.me:8080/chatbot/chat-log?userName=$userId&size=6');

    try {
      final response = await http.get(url, headers: {'accept': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> content = data['content'];
        content.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

        List<Map<String, String>> loadedMessages = [];
        for (int i = 0; i < content.length; i++) {
          var chat = content[i];
          String sender = (i % 2 == 0) ? 'user' : 'bot';
          loadedMessages.add({'sender': sender, 'message': chat['message']});
        }

        if (loadedMessages.length % 2 != 0) {
          loadedMessages.add({'sender': 'bot', 'message': ''});
        }

        setState(() {
          chatMessages = loadedMessages;
          if (chatMessages.isEmpty) {
            chatMessages.add({'sender': 'bot', 'message': '무엇을 도와드릴까요?'});
          }
        });
        _scrollToBottom();
      } else {
        print('Failed to load chat history: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching chat history: $error');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessageToServer(String message) async {
    if (userId.isEmpty) return;

    try {
      String botResponse = await _chatbotService.sendMessage(message, userId);

      setState(() {
        chatMessages.add({'sender': 'user', 'message': message});
        chatMessages.add({'sender': 'bot', 'message': botResponse});
      });

      _scrollToBottom();
    } catch (error) {
      print('Error: $error');
    }
  }

  void _addUserMessage(String message) {
    if (message.isNotEmpty) {
      _sendMessageToServer(message);
      _messageController.clear();
    }
  }

  // 고정 질문 처리 함수
  Future<void> _handleFixedQuestion(String question) async {
    setState(() {
      chatMessages.add({'sender': 'user', 'message': question});
    });

    // 서버에 질문 보내기
    try {
      String botResponse = await _chatbotService.sendMessage(question, userId);
      setState(() {
        chatMessages.add({'sender': 'bot', 'message': botResponse});
      });
      _scrollToBottom();
    } catch (error) {
      print('Error sending fixed question: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 챗봇'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 고정 질문 영역
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 각 질문을 가로로 정렬
              children: [
                GestureDetector(
                  onTap: () => _handleFixedQuestion("주식 시작 방법은?"),
                  child: Chip(
                    backgroundColor: Colors.black,  // 배경색을 검정으로 설정
                    label: Text(
                      "주식 시작 방법?",
                      style: TextStyle(color: Colors.white),  // 텍스트 색을 흰색으로 설정
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _handleFixedQuestion("매수/매도?"),
                  child: Chip(
                    backgroundColor: Colors.black,
                    label: Text(
                      "매수/매도?",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _handleFixedQuestion("투자금 설정은 어떻게 해야 적절할까?"),
                  child: Chip(
                    backgroundColor: Colors.black,
                    label: Text(
                      "투자금 설정은 어떻게 해야 적절할까?",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 채팅 메시지 영역
          Expanded(
            child: ChatMessages(chatMessages: chatMessages, scrollController: _scrollController),
          ),
          // 사용자 입력 필드
          ChatInput(
            messageController: _messageController,
            onSendMessage: _addUserMessage,
          ),
        ],
      ),
    );
  }
}