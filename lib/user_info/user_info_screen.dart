import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/user_info/user_balance.dart';
import 'package:stockapp/data/user_stock_data.dart';
import 'package:stockapp/user_info/mystock_list.dart';
import 'package:stockapp/user_info/portfolio_summary.dart';
import 'package:stockapp/user_info/sort_dropdown.dart';
import 'package:stockapp/user_info/user_profile.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  List<UserStockData> _userStocks = [];
  String userId = ''; 

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadStockData();
  }

  void _loadUserId() async {
    String? savedUserId = await AuthService.getUserId(); // ✅ AuthService 사용
    if (savedUserId == null || savedUserId.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        userId = savedUserId;
      });
    }
  }

  void _loadStockData() async {
    List<UserStockData> stocks = await loadUserStockData();
    setState(() {
      _userStocks = stocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return userId.isEmpty // ✅ userId가 없으면 로딩 표시
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
                    SortDropdown(),
                    SizedBox(height: 10),
                    MyStockList(stocks: _userStocks),
                  ],
                ),
              ),
            ),
          );
  }
}
