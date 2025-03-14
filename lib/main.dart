import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // ??Provider ?�키지 추�?
import 'home/home_screen.dart';
import 'investment/investment_screen.dart';
import 'chatbot/chatbot_main_screen.dart';
import 'user_info/user_info_screen.dart';
import 'investment/chart/stock_provider.dart';  // ??StockProvider import

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),  // ??Provider ?�록
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WithYou',
      theme: ThemeData(
        fontFamily: 'NotoSans',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // ?�체 배경???�색?�로 ?�정
      ),
      debugShowCheckedModeBanner: false, // ?�버�?배너 ?�거
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // ?�재 ?�택????�� ?�덱??
  // �??�이지???�당?�는 ?�젯?�을 준비합?�다.
  final List<Widget> _pages = [
    HomeScreen(),      // ??    InvestmentScreen(), // 모의 ?�자
    ChatbotScreen(),   // 챗봇
    UserInfoScreen(),   // ???�보
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // ??변�????�재 ???�덱???�데?�트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // ?�재 ?�택????�� 맞는 ?�면??보여�?        children: _pages, // �??�이지 ?�젯 리스??      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // ?�재 ??�� ?�시
        onTap: _onItemTapped, // ??�� ?�르�??�출?�는 ?�수
        backgroundColor: Colors.white, // ?�단 �??�상 ?�색
        selectedItemColor: Colors.black, // ?�택???�이???�상
        unselectedItemColor: Colors.grey, // ?�택?��? ?��? ?�이???�상 ?�색
        elevation: 0, // 그림???�애�?        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '??,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: '모의?�자',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '챗봇',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '???�보',
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}

