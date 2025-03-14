import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/userInfo/stock_service.dart';
import 'package:stockapp/user_info/user_balance.dart';
import 'package:stockapp/data/user_stock_model.dart';  // ?òÏ†ï??Î™®Îç∏ ?åÏùº ?¨Ïö©
import 'package:stockapp/user_info/mystock_list.dart';
import 'package:stockapp/user_info/portfolio_summary.dart';
import 'package:stockapp/user_info/sort_dropdown.dart';
import 'package:stockapp/user_info/user_profile.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  List<UserStockModel> _userStocks = [];  // UserStockModel???¨Ïö©
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadStockData();
  }

  void _loadUserId() async {
    String? savedUserId = await AuthService.getUserId(); // AuthService ?¨Ïö©
    if (savedUserId == null || savedUserId.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        userId = savedUserId;
      });
      _loadStockData(); // userIdÍ∞Ä ?§Ï†ï???ÑÏóê Ï£ºÏãù ?∞Ïù¥?∞Î? Î°úÎìú
    }
  }

  void _loadStockData() async {
    try {
      List<UserStockModel> stocks = await StockService.fetchStockList(userId);
      setState(() {
        _userStocks = stocks;
      });
    } catch (e) {
      // ?§Î•ò Ï≤òÎ¶¨ (?? ?úÎ≤Ñ ?∞Í≤∞ ?§Ìå® ??
      print("Error loading stock data: $e");
    }
  }

  // ?ïÎ†¨??Ï£ºÏãù Î¶¨Ïä§?∏Î? Î∞õÏïÑ?§Îäî ?®Ïàò
  void _onSortChanged(List<UserStockModel> sortedStocks) {
    setState(() {
      _userStocks = sortedStocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return userId.isEmpty // userIdÍ∞Ä ?ÜÏúºÎ©?Î°úÎî© ?úÏãú
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Text("???ïÎ≥¥"),
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
                    // SortDropdown??stocks?Ä onSortChanged ?ÑÎã¨
                    SortDropdown(
                      stocks: _userStocks,
                      onSortChanged: _onSortChanged,
                    ),
                    SizedBox(height: 10),
                    MyStockList(stocks: _userStocks), // ?ïÎ†¨??Ï£ºÏãù Î¶¨Ïä§???úÏãú
                  ],
                ),
              ),
            ),
          );
  }
}

