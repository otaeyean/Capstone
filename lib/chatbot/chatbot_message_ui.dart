import 'package:flutter/material.dart';

class ChatbotMessage extends StatefulWidget {
  final String message;
  final bool isHistory; // 히스토리 메시지인지 여부

  ChatbotMessage({required this.message, this.isHistory = false});

  @override
  _ChatbotMessageState createState() => _ChatbotMessageState();
}

class _ChatbotMessageState extends State<ChatbotMessage> {
  String _displayedMessage = ''; 
  int _index = 0;  
  late List<String> _messageList;

  @override
  void initState() {
    super.initState();
    if (widget.isHistory) {
      // 히스토리 메시지는 바로 표시
      _displayedMessage = widget.message;
    } else {
      // 사용자의 메시지나 챗봇 메시지는 한 글자씩 출력
      _messageList = widget.message.split('');
      _displayMessage(); 
    }
  }

  void _displayMessage() {
    Future.delayed(Duration(milliseconds: 50), () {
      if (_index < _messageList.length) {
        setState(() {
          _displayedMessage += _messageList[_index];
          _index++;
        });
        _displayMessage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9, // 최대 가로 크기 설정
        ),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_circle, size: 24, color: Colors.black),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                _displayedMessage,
                style: TextStyle(fontSize: 16),
                softWrap: true, // 자동 줄바꿈
              ),
            ),
          ],
        ),
      ),
    );
  }
}
