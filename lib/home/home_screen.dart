import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_info/user_info_screen.dart';
import 'stock_list_widget.dart';
import 'stock_ranking.dart';
import 'welcome_box.dart';
import '/login/login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 로그인 상태 확인
  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.containsKey('nickname'); 
    });
  }

  // 로그아웃 기능
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
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
                    Text("내 종목보기", style: TextStyle(fontFamily: 'MinSans', fontWeight: FontWeight.w900, fontSize: 18)),
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
