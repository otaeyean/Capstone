import 'dart:async';
import 'package:flutter/material.dart';
import '../server/userInfo/user_balance_server.dart';
import '../server/userInfo/portfolio_server.dart';

class UserBalance extends StatefulWidget {
  final String userId; 

  UserBalance({required this.userId}); 

  @override
  _UserBalanceState createState() => _UserBalanceState();
}

class _UserBalanceState extends State<UserBalance> {
  double balance = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchBalance(); 
    _startBalanceUpdateTimer(); 
  }

  // 서버에서 balance 값을 받아오는 함수
  void _fetchBalance() async {
    try {
      final data = await PortfolioService.fetchPortfolioData(widget.userId);
      setState(() {
        balance = data['balance'].toDouble(); 
      });
    } catch (e) {
      print("Balance fetch error: $e");
    }
  }

  // 10초마다 금액 갱신(타이머 설정)
  void _startBalanceUpdateTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchBalance(); 
    });
  }

  @override
  void dispose() {
    _timer.cancel(); 
    super.dispose();
  }

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
        balance = 0; 
      });
    }
  }

  void _showBalanceInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, 
          title: Text(
            "금액 입력",
            style: TextStyle(color: Colors.black), 
          ),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "금액을 입력하세요",
              hintStyle: TextStyle(color: Colors.black45), 
            ),
            style: TextStyle(color: Colors.black), 
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _updateBalance();
                Navigator.pop(context);
              },
              child: Text("확인", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _confirmResetBalance(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, 
          title: Text(
            "금액 초기화",
            style: TextStyle(color: Colors.black), 
          ),
          content: Text(
            "설정해놓으신 금액이 초기화됩니다. 진행하시겠습니까?",
            style: TextStyle(color: Colors.black), 
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("취소", style: TextStyle(color: Colors.black)), 
            ),
            TextButton(
              onPressed: () {
                _resetBalance(); 
                Navigator.pop(context);
              },
              child: Text("확인", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
              onTap: () => _confirmResetBalance(context), 
              child: Text("초기화", style: TextStyle(color: Colors.red, fontSize: 14, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ],
    );
  }
}
