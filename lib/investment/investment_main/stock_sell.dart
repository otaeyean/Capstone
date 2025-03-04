import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/investment/user_balance_server.dart';
import 'package:stockapp/server/investment/stock_sell_server.dart';

class MockSellScreen extends StatefulWidget {
  final String stockCode;

  MockSellScreen({required this.stockCode});

  @override
  _MockSellScreenState createState() => _MockSellScreenState();
}

class _MockSellScreenState extends State<MockSellScreen> {
  TextEditingController _quantityController = TextEditingController();
  String? userId;
  double? _balance;
  double? _price = 584296; // 수정 필요
  final UserBalanceService _balanceService = UserBalanceService();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    String? id = await AuthService.getUserId();
    if (id != null) {
      setState(() {
        userId = id;
      });
      _fetchBalance(id);
    }
  }

  Future<void> _fetchBalance(String id) async {
    double? balance = await _balanceService.fetchBalance(id);
    if (balance != null) {
      setState(() {
        _balance = balance;
      });
    }
  }

  Future<void> _sellStock() async {
    if (userId == null || _quantityController.text.isEmpty) return;

    int quantity = int.tryParse(_quantityController.text.replaceAll(RegExp(r'\D'), '')) ?? 0;
    if (quantity <= 0) {
      print("잘못된 수량 입력");
      return;
    }

    bool success = await StockServer.sellStock(userId!, widget.stockCode, quantity);
    if (success) {
      print("매도 성공");
      _fetchBalance(userId!);
      _showSuccessDialog();
    } else {
      print("매도 실패");
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
            _buildBalanceWidget(),
            SizedBox(height: 20),
            _buildInfoBox('매도할 가격', _price != null ? '${_price!.toStringAsFixed(0)}원' : '가격 로딩 중...'),
            SizedBox(height: 20),
            _buildInfoBox('수량', '몇 주 매도할까요?', inputField: true),
            SizedBox(height: 30),
            Spacer(),
            _buildSellButton(),
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
            baseColor: Colors.white,
            highlightColor: Colors.grey[300]!,
            child: Container(
              width: 180,
              height: 24,
              color: Colors.white,
            ),
          );
  }

  Widget _buildInfoBox(String title, String value, {bool inputField = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 241, 241, 241),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.black, fontSize: 16)),
          SizedBox(height: 8),
          inputField
              ? TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: value,
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              : Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSellButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _sellStock,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('판매하기', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}

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
              builder: (_, __) => Icon(Icons.celebration, color: Colors.orange, size: _sizeAnimation.value),
            ),
            SizedBox(height: 20),
            Text("매도가 완료되었습니다!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
