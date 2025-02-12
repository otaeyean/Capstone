import 'package:flutter/material.dart';
import '../server/userInfo/user_balance_server.dart';

class UserBalance extends StatefulWidget {
  final String userId; 

  UserBalance({required this.userId}); 

  @override
  _UserBalanceState createState() => _UserBalanceState();
}

class _UserBalanceState extends State<UserBalance> {
  double balance = 0;
  final TextEditingController _controller = TextEditingController();

  void _updateBalance() async {
    double? newBalance = double.tryParse(_controller.text);
    if (newBalance != null) {
      bool success = await UserBalanceService().updateBalance(widget.userId, newBalance);
      if (success) {
        setState(() {
          balance = newBalance;
        });
      }
    }
  }

  void _resetBalance() async {
    bool success = await UserBalanceService().resetBalance(widget.userId);
    if (success) {
      setState(() {
        balance = 0; // 서버에서 초기화가 완료되면 UI에도 반영
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("보유 금액", style: TextStyle(color: Colors.white, fontSize: 16)),
              Text("${balance.toStringAsFixed(0)} 원",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => _showBalanceInputDialog(context),
              child: Text("금액설정", style: TextStyle(color: Colors.black, fontSize: 14, decoration: TextDecoration.underline)),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: _resetBalance, // 초기화 요청
              child: Text("초기화", style: TextStyle(color: Colors.red, fontSize: 14, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ],
    );
  }

  void _showBalanceInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("금액 입력"),
          content: TextField(controller: _controller, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "금액을 입력하세요")),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("취소")),
            TextButton(
              onPressed: () {
                _updateBalance(); // 서버로 전송
                Navigator.pop(context);
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }
}