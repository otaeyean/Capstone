import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../user_info/user_info_screen.dart';
import 'stock_list_widget.dart';
import 'stock_ranking.dart';
import 'welcome_box.dart';
import '/login/login.dart';
import 'searchable_stock_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false;
  List<Map<String, String>> stockList = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchStockList();
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
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "WithYou",
            style: TextStyle(fontFamily: 'MinSans', fontWeight: FontWeight.w800),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
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
              style: TextStyle(fontFamily: 'MinSans', fontWeight: FontWeight.w900, color: Colors.black),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SearchableStockList(stockList: stockList),  // 🔹 검색 기능을 별도 위젯으로 사용
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: WelcomeBox(),
          ),
          SizedBox(height: 20),
          if (isLoggedIn) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserInfoScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart, color: Colors.black),
                        SizedBox(width: 8),
                        Text("내 종목보기", style: TextStyle(fontFamily: 'MinSans', fontWeight: FontWeight.w900, fontSize: 18)),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: StockListWidget(),
              ),
            ),
            SizedBox(height: 5),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                SizedBox(width: 8),
                Text("주식 랭킹", style: TextStyle(fontFamily: 'MinSans', fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: StockRanking(),
            ),
          ),
        ],
      ),
    );
  }
}
