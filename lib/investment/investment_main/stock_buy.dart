import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // ✅ Shimmer 추가

import 'package:stockapp/server/investment/user_balance_server.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/investment/stock_buy_server.dart';

class MockBuyScreen extends StatefulWidget {
  final String stockCode;

  MockBuyScreen({required this.stockCode});

  @override
  _MockBuyScreenState createState() => _MockBuyScreenState();
}

class _MockBuyScreenState extends State<MockBuyScreen> {
  TextEditingController _quantityController = TextEditingController();
  final UserBalanceService _balanceService = UserBalanceService();
  double? _balance;
  double? _price;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchStockPrice();
  }

  Future<void> _loadUserId() async {
    String? id = await AuthService.getUserId();
    if (id != null) {
      setState(() {
        userId = id;
      });
      _loadBalance(id);
    }
  }

  Future<void> _loadBalance(String id) async {
    double? balance = await _balanceService.fetchBalance(id);
    if (balance != null) {
      setState(() {
        _balance = balance;
      });
    }
  }

  Future<void> _fetchStockPrice() async {
    double? fetchedPrice = await StockServer.fetchStockPrice(widget.stockCode);
    if (fetchedPrice != null) {
      setState(() {
        _price = fetchedPrice;
      });
    }
  }

  Future<void> _buyStock() async {
    if (userId == null || _quantityController.text.isEmpty) return;

    int quantity = int.tryParse(_quantityController.text.replaceAll(RegExp(r'\D'), '')) ?? 0;
    if (quantity <= 0) {
      print("잘못된 수량 입력");
      return;
    }

    bool success = await StockServer.buyStock(userId!, widget.stockCode, quantity);
    if (success) {
      print("구매 성공");
      _loadBalance(userId!); // 구매 후 잔액 업데이트
      _showSuccessDialog();
    } else {
      print("구매 실패");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AnimatedSuccessDialog();
      },
    );

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceWidget(), // ✅ 보유 금액 위젯
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 241, 241, 241),
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('구매할 가격', style: TextStyle(color: Colors.black, fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    _price != null ? '${_price!.toStringAsFixed(0)}원' : '가격 로딩 중...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 241, 241, 241),
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('수량', style: TextStyle(color: Colors.black, fontSize: 16)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '몇 주 구매할까요?',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Spacer(),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _buyStock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('구매하기', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

    // ✅ Shimmer 애니메이션 적용한 보유 금액 위젯
  Widget _buildBalanceWidget() {
    return _balance != null
        ? Text(
            '보유 금액 ${_balance!.toStringAsFixed(0)}원',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        : Shimmer.fromColors(
            baseColor: Colors.white,  // ✅ 배경을 흰색으로 변경
            highlightColor: Colors.grey[300]!, // ✅ 밝은 회색으로 반짝이게 설정
            child: Container(
              width: 180,
              height: 24,
              color: Colors.white,
            ),
          );
  }
  }

// ✅ 애니메이션 다이얼로그
class _AnimatedSuccessDialog extends StatefulWidget {
  @override
  __AnimatedSuccessDialogState createState() => __AnimatedSuccessDialogState();
}

class __AnimatedSuccessDialogState extends State<_AnimatedSuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      reverseDuration: Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _sizeAnimation = Tween<double>(begin: 50, end: 70).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        width: 300,
        height: 200,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _sizeAnimation,
              builder: (context, child) {
                return Icon(Icons.celebration, color: Colors.orange, size: _sizeAnimation.value);
              },
            ),
            SizedBox(height: 20),
            Text("구매가 완료되었습니다!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("성공적인 투자이길 바랍니다", style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
