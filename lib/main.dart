import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'investment/investment_screen.dart';
import 'chatbot/chatbot_screen.dart';
import 'user_info/user_info_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '주식 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // 전체 배경을 흰색으로 설정
      ),
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // 현재 선택된 탭의 인덱스

  // 각 페이지에 해당하는 위젯들을 준비합니다.
  final List<Widget> _pages = [
    HomeScreen(),      // 홈
    InvestmentScreen(), // 모의 투자
    ChatbotScreen(),   // 챗봇
    UserInfoScreen(),   // 내 정보
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // 탭 변경 시 현재 탭 인덱스 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("주식 앱"),
      ),
      body: IndexedStack(
        index: _currentIndex, // 현재 선택된 탭에 맞는 화면을 보여줌
        children: _pages, // 각 페이지 위젯 리스트
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // 현재 탭을 표시
        onTap: _onItemTapped, // 탭을 누르면 호출되는 함수
        backgroundColor: Colors.white, // 하단 바 색상 흰색
        selectedItemColor: Colors.blue, // 선택된 아이템 색상 파란색
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: '모의투자',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '챗봇',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
      ),
    );
  }
}
