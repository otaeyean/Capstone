import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../user_info/user_info_screen.dart';
import 'stock_list_widget.dart';
import 'stock_ranking.dart';
import 'welcome_box.dart';
import '/login/login.dart';
import 'searchable_stock_list.dart'; // ✅ 검색 위젯 import
import 'package:stockapp/data/user_stock_model.dart';
import 'package:stockapp/server/userInfo/stock_service.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import './recommended_stocks.dart';
import '../home/my_stock_news.dart';
import '../tf_logo/screens/detection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false;
  List<Map<String, String>> stockList = [];
  List<UserStockModel> _userStocks = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchStockList();
    _fetchUserStocks();
  }

  void refreshUserStocks() {
    _fetchUserStocks();
  }

  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.containsKey('nickname');
    });
  }

  _fetchStockList() async {
    final response = await http.get(Uri.parse('http://withyou.me:8080/stock-list'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        stockList = data.map((item) => {
              'stockCode': item['stockCode'].toString(),
              'stockName': utf8.decode(item['stockName'].codeUnits),
            }).toList();
      });
    } else {
      throw Exception('Failed to load stock list');
    }
  }

  Future<void> _fetchUserStocks() async {
    final userId = await AuthService.getUserId();
    if (userId != null && userId.isNotEmpty) {
      final stocks = await StockService.fetchStockList(userId);
      setState(() {
        _userStocks = stocks;
      });
    }
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('nickname');
    await prefs.remove('balance');
    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: Color(0xFFE9F8F2),
              child: Column(
                children: [
                  // 상단 배경 + 검색 + WelcomeBox
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7CC993), Color(0xFF22B379)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.only(bottom: 24),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "WithYou",
                                  style: TextStyle(
                                    fontFamily: 'MinSans',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (isLoggedIn) {
                                      _logout();
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginPage()),
                                      ).then((_) => _checkLoginStatus());
                                    }
                                  },
                                  child: Text(
                                    isLoggedIn ? "로그아웃" : "로그인",
                                    style: TextStyle(
                                      fontFamily: 'MinSans',
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            // ✅ 검색창 + 자동완성 리스트 삽입
                            SearchableStockList(stockList: stockList),

                            SizedBox(height: 20),

                            WelcomeBox(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 보유 주식
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: StockListWidget(stocks: _userStocks),
                  ),

                  SizedBox(height: 30),

                  // 내 종목 뉴스
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const UserNewsScreen(),
                  ),

                  SizedBox(height: 30),

                  // 추천 주식
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: RecommendedStocks(),
                  ),

                  SizedBox(height: 30),

                  // 주식 랭킹
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 650,
                      child: StockRanking(),
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // 카메라 말풍선
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '궁금하신 기업이 있으신가요?\n사진 찍어 검색해보세요!',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                    textAlign: TextAlign.right,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DetectionScreen()),
                    );
                  },
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}