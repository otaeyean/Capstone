import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // ??Provider ?¨ν€μ§ μΆκ?
import 'home/home_screen.dart';
import 'investment/investment_screen.dart';
import 'chatbot/chatbot_main_screen.dart';
import 'user_info/user_info_screen.dart';
import 'investment/chart/stock_provider.dart';  // ??StockProvider import

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),  // ??Provider ?±λ‘
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
        scaffoldBackgroundColor: Colors.white, // ?μ²΄ λ°°κ²½???°μ?Όλ‘ ?€μ 
      ),
      debugShowCheckedModeBanner: false, // ?λ²κ·?λ°°λ ?κ±°
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // ?μ¬ ? ν???? ?Έλ±??
  // κ°??μ΄μ§???΄λΉ?λ ?μ ―?€μ μ€λΉν©?λ€.
  final List<Widget> _pages = [
    HomeScreen(),      // ??    InvestmentScreen(), // λͺ¨μ ?¬μ
    ChatbotScreen(),   // μ±λ΄
    UserInfoScreen(),   // ???λ³΄
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // ??λ³κ²????μ¬ ???Έλ±???λ°?΄νΈ
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // ?μ¬ ? ν???? λ§λ ?λ©΄??λ³΄μ¬μ€?        children: _pages, // κ°??μ΄μ§ ?μ ― λ¦¬μ€??      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // ?μ¬ ?? ?μ
        onTap: _onItemTapped, // ?? ?λ₯΄λ©??ΈμΆ?λ ?¨μ
        backgroundColor: Colors.white, // ?λ¨ λ°??μ ?°μ
        selectedItemColor: Colors.black, // ? ν???μ΄???μ
        unselectedItemColor: Colors.grey, // ? ν?μ? ?μ? ?μ΄???μ ?μ
        elevation: 0, // κ·Έλ¦Ό???μ κΈ?        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '??,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'λͺ¨μ?¬μ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'μ±λ΄',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '???λ³΄',
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}

