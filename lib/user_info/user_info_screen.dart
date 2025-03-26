import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/userInfo/stock_service.dart';
import 'package:stockapp/user_info/user_balance.dart';
import 'package:stockapp/data/user_stock_model.dart';
import 'package:stockapp/user_info/mystock_list.dart';
import 'package:stockapp/user_info/portfolio_summary.dart';
import 'package:stockapp/user_info/sort_dropdown.dart';
import 'package:stockapp/user_info/user_profile.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key); // GlobalKey용 생성자

  @override
  UserInfoScreenState createState() => UserInfoScreenState();
}

class UserInfoScreenState extends State<UserInfoScreen> {
  List<UserStockModel> _userStocks = [];
  String userId = '';

  // ✅ 외부에서 호출 가능한 새로고침 함수
  void refreshStock() {
    if (userId.isNotEmpty) {
      _loadStockData();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    String? savedUserId = await AuthService.getUserId();
    if (savedUserId == null || savedUserId.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        userId = savedUserId;
      });
      _loadStockData();
    }
  }

  void _loadStockData() async {
    try {
      List<UserStockModel> stocks = await StockService.fetchStockList(userId);
      setState(() {
        _userStocks = stocks;
      });
    } catch (e) {
      print("Error loading stock data: $e");
    }
  }

  void _onSortChanged(List<UserStockModel> sortedStocks) {
    setState(() {
      _userStocks = sortedStocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return userId.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Text("내 정보"),
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
                    SortDropdown(
                      stocks: _userStocks,
                      onSortChanged: _onSortChanged,
                    ),
                    SizedBox(height: 10),
                    MyStockList(stocks: _userStocks),
                  ],
                ),
              ),
            ),
          );
  }
}
