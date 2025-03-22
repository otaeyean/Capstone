import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockapp/server/investment/user_balance_server.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/investment/stock_buy_server.dart';
import 'package:stockapp/investment/investment_main/dialog/success_purchase_dialog.dart';
import 'dialog/buy_error_message_widget.dart'; 
import 'dialog/buy_confirmation_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 

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
  int? confirmedQuantity;
  String? _errorMessage;

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

  // 서버에서 현재가를 가져오는 함수
  Future<void> _fetchStockPrice() async {
    final response = await http.get(Uri.parse('http://withyou.me:8080/current-price?stockCode=${widget.stockCode}'));

    if (response.statusCode == 200) {
      
      final data = json.decode(response.body);
      setState(() {
        _price = data['stockPrice']?.toDouble();  
      });
    } else {
      setState(() {
        _errorMessage = "현재가를 가져오지 못했습니다.";
      });
    }
  }

  Future<void> _buyStock() async {
    if (userId == null || confirmedQuantity == null) {
      setState(() {
        _errorMessage = "로그인을 확인하거나 수량을 입력하세요.";
      });
      return;
    }

    if (_balance != null && _balance! < (_price! * confirmedQuantity!)) {
      setState(() {
        _errorMessage = "보유 금액이 부족합니다.";
      });
      return;
    }

    bool success = await StockServer.buyStock(userId!, widget.stockCode, confirmedQuantity!);
    if (success) {
      print("구매 성공");
      _loadBalance(userId!);
      setState(() {
        confirmedQuantity = null;
        _errorMessage = null;
      });
      _showSuccessDialog();
    } else {
      print("구매 실패");
      setState(() {
        _errorMessage = "매수 실패. 다시 시도해주세요.";
      });
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
        _errorMessage = null;
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          price: _price != null ? _price!.toStringAsFixed(0) : '가격을 불러오는 중...',
          quantity: confirmedQuantity!,
          onConfirm: () {
            Navigator.of(context).pop();
            _buyStock();
          },
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
            if (_errorMessage != null) _buildErrorMessageWidget(),
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
            _price != null ? '${_price!.toStringAsFixed(0)}원' : '로딩 중...',
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
            decoration: InputDecoration(hintText: '몇 주 매수할까요?', border: InputBorder.none),
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
        Text('매수 확인', style: TextStyle(fontFamily: 'MinSans', color: Colors.red, fontSize: 20, fontWeight: FontWeight.w800)),
        SizedBox(height: 8),
        Text(
          '체결 가격: ${( _price != null ? _price!.toStringAsFixed(0) : "정보 없음")}원\n구매 수량: $confirmedQuantity주',
        ),
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
        child: Text('매수하기', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  Widget _buildErrorMessageWidget() {
    return ErrorMessageWidget(errorMessage: _errorMessage);
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }
}