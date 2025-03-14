import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/userInfo/stock_service.dart';
import 'package:stockapp/user_info/user_balance.dart';
import 'package:stockapp/data/user_stock_model.dart';  // ?�정??모델 ?�일 ?�용
import 'package:stockapp/user_info/mystock_list.dart';
import 'package:stockapp/user_info/portfolio_summary.dart';
import 'package:stockapp/user_info/sort_dropdown.dart';
import 'package:stockapp/user_info/user_profile.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  List<UserStockModel> _userStocks = [];  // UserStockModel???�용
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadStockData();
  }

  void _loadUserId() async {
    String? savedUserId = await AuthService.getUserId(); // AuthService ?�용
    if (savedUserId == null || savedUserId.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        userId = savedUserId;
      });
      _loadStockData(); // userId가 ?�정???�에 주식 ?�이?��? 로드
    }
  }

  void _loadStockData() async {
    try {
      List<UserStockModel> stocks = await StockService.fetchStockList(userId);
      setState(() {
        _userStocks = stocks;
      });
    } catch (e) {
      // ?�류 처리 (?? ?�버 ?�결 ?�패 ??
      print("Error loading stock data: $e");
    }
  }

  // ?�렬??주식 리스?��? 받아?�는 ?�수
  void _onSortChanged(List<UserStockModel> sortedStocks) {
    setState(() {
      _userStocks = sortedStocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return userId.isEmpty // userId가 ?�으�?로딩 ?�시
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Text("???�보"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserProfile(userId: userId),
                    SizedBox(height: 16),
                    UserBalance(userId: userId),
                    SizedBox(height: 16),
                    PortfolioSummary(userId: userId),
                    SizedBox(height: 16),
                    // SortDropdown??stocks?� onSortChanged ?�달
                    SortDropdown(
                      stocks: _userStocks,
                      onSortChanged: _onSortChanged,
                    ),
                    SizedBox(height: 10),
                    MyStockList(stocks: _userStocks), // ?�렬??주식 리스???�시
                  ],
                ),
              ),
            ),
          );
  }
}

