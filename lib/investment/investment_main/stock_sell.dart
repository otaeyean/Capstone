import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; 
import 'package:stockapp/server/investment/user_balance_server.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/investment/stock_sell_server.dart';
import 'package:stockapp/investment/investment_main/dialog/success_sell_dialog.dart'; 

class MockSellScreen extends StatefulWidget {
  final String stockCode;

  MockSellScreen({required this.stockCode});

  @override
  _MockSellScreenState createState() => _MockSellScreenState();
}

class _MockSellScreenState extends State<MockSellScreen> {
  TextEditingController _quantityController = TextEditingController();
  final UserBalanceService _balanceService = UserBalanceService();
  double? _balance;
  double _price = 10; // 가격을 10원으로 하드코딩
  String? userId;
  int? confirmedQuantity;

  @override
  void initState() {
    super.initState();
    _loadUserId();
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

  Future<void> _sellStock() async {
    if (userId == null || confirmedQuantity == null) return;

    bool success = await StockServer.sellStock(userId!, widget.stockCode, confirmedQuantity!);
    if (success) {
      print("매도 성공");
      _loadBalance(userId!);
      setState(() {
        confirmedQuantity = null; 
      });
      _showSuccessDialog();
    } else {
      print("매도 실패");
    }
  }

void _showConfirmationDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, 
        title: Row(
          children: [
            Text("매도 확인"),
            SizedBox(width: 8), 
            Icon(Icons.help_outline, color: Colors.black), 
          ],
        ),
        content: Text(
          "체결 가격: ${_price.toStringAsFixed(0)}원\n매도 수량: $confirmedQuantity주\n\n진행하시겠습니까?",
          style: TextStyle(color: Colors.black), 
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: Text("취소",style: TextStyle(color: Colors.black), 
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              _sellStock();
            },
            child: Text("확인", style: TextStyle(color: Colors.blue), 
            ),
          ),
        ],
      );
    },
  );
}

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessSellDialog();
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); 
      }
    });
  }

  void _confirmQuantity() {
    int quantity = int.tryParse(_quantityController.text.replaceAll(RegExp(r'\D'), '')) ?? 0;
    if (quantity > 0) {
      setState(() {
        confirmedQuantity = quantity;
      });
    }
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
            _buildPriceWidget(),
            SizedBox(height: 20),
            _buildQuantityWidget(),
            if (confirmedQuantity != null) _buildConfirmedBox(),
            SizedBox(height: 30),
            Spacer(),
            _buildSellButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceWidget() {
    return _balance != null
        ? Text(
            '보유 금액 ${_balance!.toStringAsFixed(0)}원',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        : Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.grey[300]!,
            child: Container(width: 180, height: 24, color: Colors.white),
          );
  }

  Widget _buildPriceWidget() {
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
          Text('현재가', style: TextStyle(color: Colors.black, fontSize: 16)),
          SizedBox(height: 8),
          Text(
            '${_price.toStringAsFixed(0)}원',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityWidget() {
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
          Text('수량', style: TextStyle(color: Colors.black, fontSize: 16)),
          SizedBox(height: 8),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: '몇 주 매도할까요?', border: InputBorder.none),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            onChanged: (value) => _confirmQuantity(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedBox() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 241, 241, 241),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('매도 확인', style: TextStyle(fontFamily: 'MinSans', color: Colors.blue, fontSize: 20,fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('체결 가격: ${_price.toStringAsFixed(0)}원\n매도 수량: $confirmedQuantity주'),
        ],
      ),
    );
  }

Widget _buildSellButton() {
  return Container(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: confirmedQuantity != null ? _showConfirmationDialog : null, 
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('매도하기', style: TextStyle(color: Colors.white, fontSize: 18)),
    ),
  );
}
}