import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/userInfo/stock_service.dart';
import 'package:stockapp/user_info/user_balance.dart';
import 'package:stockapp/data/user_stock_model.dart';  // 수정된 모델 파일 사용
import 'package:stockapp/user_info/mystock_list.dart';
import 'package:stockapp/user_info/portfolio_summary.dart';
import 'package:stockapp/user_info/sort_dropdown.dart';
import 'package:stockapp/user_info/user_profile.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  List<UserStockModel> _userStocks = [];  // UserStockModel을 사용
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadStockData();
  }

  void _loadUserId() async {
    String? savedUserId = await AuthService.getUserId(); // AuthService 사용
    if (savedUserId == null || savedUserId.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        userId = savedUserId;
      });
      _loadStockData(); // userId가 설정된 후에 주식 데이터를 로드
    }
  }

  void _loadStockData() async {
    try {
      List<UserStockModel> stocks = await StockService.fetchStockList(userId);
      setState(() {
        _userStocks = stocks;
      });
    } catch (e) {
      // 오류 처리 (예: 서버 연결 실패 시)
      print("Error loading stock data: $e");
    }
  }

  // 정렬된 주식 리스트를 받아오는 함수
  void _onSortChanged(List<UserStockModel> sortedStocks) {
    setState(() {
      _userStocks = sortedStocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return userId.isEmpty // userId가 없으면 로딩 표시
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
                    // SortDropdown에 stocks와 onSortChanged 전달
                    SortDropdown(
                      stocks: _userStocks,
                      onSortChanged: _onSortChanged,
                    ),
                    SizedBox(height: 10),
                    MyStockList(stocks: _userStocks), // 정렬된 주식 리스트 표시
                  ],
                ),
              ),
            ),
          );
  }
}