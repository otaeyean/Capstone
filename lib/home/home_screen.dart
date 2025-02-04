import 'package:flutter/material.dart';
import '../user_info/user_info_screen.dart';
import 'stock_list_widget.dart';
import 'welcome_box.dart';  // 반갑습니다! 상자
import 'stock_list_widget.dart';   // 내 종목보기
import 'stock_ranking.dart'; // 실시간 랭킹

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WithYou"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 주식 검색창
            TextField(
              decoration: InputDecoration(
                hintText: '주식 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // 반갑습니다! user님 박스
            WelcomeBox(),

            SizedBox(height: 20),

            // 내 종목보기 버튼
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfoScreen()),
                );
              },
              child: Text(
                '내 종목보기 >',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
            SizedBox(height: 20),

            // 실시간 랭킹
            StockRanking(),

            SizedBox(height: 20),

            // 내 종목보기
            StockList(),
          ],
        ),
      ),
    );
  }
}
