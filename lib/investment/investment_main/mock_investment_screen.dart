import 'package:flutter/material.dart';
import 'mock_buy.dart'; 
import 'mock_sell.dart'; 
class MockInvestmentScreen extends StatefulWidget {
  @override
  _MockInvestmentScreenState createState() => _MockInvestmentScreenState();
}

class _MockInvestmentScreenState extends State<MockInvestmentScreen> {
  int _selectedTabIndex = 0; 

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _onTabSelected(0),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  child: Text(
                    '매수',
                    style: TextStyle(
                      color: _selectedTabIndex == 0 ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _onTabSelected(1),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  child: Text(
                    '매도',
                    style: TextStyle(
                      color: _selectedTabIndex == 1 ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _onTabSelected(2),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  child: Text(
                    '주문 내역',
                    style: TextStyle(
                      color: _selectedTabIndex == 2 ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Expanded(
            child: _selectedTabIndex == 0
                ? MockBuyScreen() 
                : _selectedTabIndex == 1
                    ? MockSellScreen() 
                    : Center(child: Text('전체 주문 내역')), 
          ),
        ],
      ),
    );
  }
}
