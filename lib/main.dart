import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // ??Provider ?¨í‚¤ì§€ ì¶”ê?
import 'home/home_screen.dart';
import 'investment/investment_screen.dart';
import 'chatbot/chatbot_main_screen.dart';
import 'user_info/user_info_screen.dart';
import 'investment/chart/stock_provider.dart';  // ??StockProvider import

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),  // ??Provider ?±ë¡
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
        scaffoldBackgroundColor: Colors.white, // ?„ì²´ ë°°ê²½???°ìƒ‰?¼ë¡œ ?¤ì •
      ),
      debugShowCheckedModeBanner: false, // ?”ë²„ê·?ë°°ë„ˆ ?œê±°
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // ?„ì¬ ? íƒ????˜ ?¸ë±??
  // ê°??˜ì´ì§€???´ë‹¹?˜ëŠ” ?„ì ¯?¤ì„ ì¤€ë¹„í•©?ˆë‹¤.
  final List<Widget> _pages = [
    HomeScreen(),      // ??    InvestmentScreen(), // ëª¨ì˜ ?¬ì
    ChatbotScreen(),   // ì±—ë´‡
    UserInfoScreen(),   // ???•ë³´
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // ??ë³€ê²????„ì¬ ???¸ë±???…ë°?´íŠ¸
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // ?„ì¬ ? íƒ????— ë§ëŠ” ?”ë©´??ë³´ì—¬ì¤?        children: _pages, // ê°??˜ì´ì§€ ?„ì ¯ ë¦¬ìŠ¤??      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // ?„ì¬ ??„ ?œì‹œ
        onTap: _onItemTapped, // ??„ ?„ë¥´ë©??¸ì¶œ?˜ëŠ” ?¨ìˆ˜
        backgroundColor: Colors.white, // ?˜ë‹¨ ë°??‰ìƒ ?°ìƒ‰
        selectedItemColor: Colors.black, // ? íƒ???„ì´???‰ìƒ
        unselectedItemColor: Colors.grey, // ? íƒ?˜ì? ?Šì? ?„ì´???‰ìƒ ?Œìƒ‰
        elevation: 0, // ê·¸ë¦¼???†ì• ê¸?        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '??,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'ëª¨ì˜?¬ì',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'ì±—ë´‡',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '???•ë³´',
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}

