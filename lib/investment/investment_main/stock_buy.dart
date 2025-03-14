import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; 
import 'package:stockapp/server/investment/user_balance_server.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/investment/stock_buy_server.dart';
import 'package:stockapp/investment/investment_main/dialog/success_purchase_dialog.dart'; 

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
  double _price = 10; // 가격을 10?�으�??�드코딩
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

  Future<void> _buyStock() async {
    if (userId == null || confirmedQuantity == null) return;

    bool success = await StockServer.buyStock(userId!, widget.stockCode, confirmedQuantity!);
    if (success) {
      print("구매 ?�공");
      _loadBalance(userId!);
      setState(() {
        confirmedQuantity = null; 
      });
      _showSuccessDialog();
    } else {
      print("구매 ?�패");
    }
  }
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AnimatedSuccessDialog();
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

void _showConfirmationDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, 
        title: Row(
          children: [
            Text("매수 ?�인"),
            SizedBox(width: 8), 
            Icon(Icons.help_outline, color: Colors.black), 
          ],
        ),
        content: Text(
          "체결 가�? ${_price.toStringAsFixed(0)}??n구매 ?�량: $confirmedQuantity�?n\n진행?�시겠습?�까?",
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
              _buyStock(); 
            },
            child: Text(
              "?�인",
              style: TextStyle(color: Colors.red), 
            ),
          ),
        ],
      );
    },
  );
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
            _buildBuyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceWidget() {
    return _balance != null
        ? Text(
            '보유 금액 ${_balance!.toStringAsFixed(0)}??,
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
          Text('?�재가', style: TextStyle(color: Colors.black, fontSize: 16)),
          SizedBox(height: 8),
          Text(
            '${_price.toStringAsFixed(0)}??,
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
          Text('?�량', style: TextStyle(color: Colors.black, fontSize: 16)),
          SizedBox(height: 8),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: '�?�?매수?�까??', border: InputBorder.none),
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
          Text('매수 ?�인', style: TextStyle(fontFamily: 'MinSans', color: Colors.red, fontSize: 20,fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('체결 가�? ${_price.toStringAsFixed(0)}??n구매 ?�량: $confirmedQuantity�?),
        ],
      ),
    );
  }

  Widget _buildBuyButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: confirmedQuantity != null ? _showConfirmationDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('매수?�기', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}

