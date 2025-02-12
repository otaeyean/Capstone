import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // SharedPreferences에서 로그인한 사용자 닉네임 불러오는 메소드
  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('nickname') ?? ''; 
    });
  }

  // JSON에서 주식 데이터 불러오는 메소드
  void _loadStockData() async {
    List<UserStockData> stocks = await loadUserStockData();
    setState(() {
      _userStocks = stocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // userId가 없으면 로그인 안내 메시지 표시
              userId.isEmpty
                  ? Center(
                      child: Text(
                        '로그인 해주세요!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : UserProfile(userId: userId), 
              SizedBox(height: 16),
              userId.isEmpty
                  ? Container()
                  : UserBalance(userId: userId), 
              SizedBox(height: 16),
              userId.isEmpty
                  ? Container() 
                  : PortfolioSummary(),
              SizedBox(height: 16),
              userId.isEmpty
                  ? Container() 
                  : SortDropdown(),
              SizedBox(height: 10),
              userId.isEmpty
                  ? Container() 
                  : MyStockList(stocks: _userStocks),
            ],
          ),
        ),
      ),
    );
  }
}
