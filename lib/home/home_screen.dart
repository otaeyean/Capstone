import 'package:flutter/material.dart';
import '../user_info/user_info_screen.dart';
import 'stock_list_widget.dart';
import 'stock_ranking.dart';
import 'welcome_box.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WithYou"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 주식 검색창
            TextField(
              decoration: InputDecoration(
                hintText: '검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 20),

            // 🔹 반갑습니다 박스
            WelcomeBox(),
            SizedBox(height: 20),

            // 🔹 내 종목보기 (텍스트와 > 아이콘을 함께 감싸 클릭 가능하도록 변경)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfoScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("내 종목보기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blue),
                ],
              ),
            ),
            SizedBox(height: 10),

            // 🔹 내 종목 리스트 (3개만 표시)
            StockListWidget(),

            SizedBox(height: 20),

            // 🔹 실시간 랭킹
            StockRanking(),
          ],
        ),
      ),
    );
  }
}
