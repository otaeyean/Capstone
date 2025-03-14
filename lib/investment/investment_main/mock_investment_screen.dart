import 'package:flutter/material.dart';
import 'stock_buy.dart';
import 'stock_sell.dart';
import 'stock_history_list.dart';

class MockInvestmentScreen extends StatefulWidget {
  final String stockCode;

  MockInvestmentScreen({required this.stockCode});

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
      body: SingleChildScrollView(  // ?μ²΄ ?€ν¬λ‘€μ κ°?₯νκ²?λ§λ¦
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _onTabSelected(0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    child: Text(
                      'λ§€μ',
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
                      'λ§€λ',
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
                      'μ£Όλ¬Έ ?΄μ­',
                      style: TextStyle(
                        color: _selectedTabIndex == 2 ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ?? λ§λ ?λ©΄???μ?κ³ , ?€ν¬λ‘€μ΄ κ°?₯ν?λ‘ ??            Container(
              // ?? λ§λ ?λ©΄ ?μ
              height: MediaQuery.of(context).size.height * 0.7, // ?λ©΄ ?μ΄??λ§κ² λΉμ¨???€μ 
              child: _selectedTabIndex == 0
                  ? MockBuyScreen(stockCode: widget.stockCode) // stockCode ?λ¬
                  : _selectedTabIndex == 1
                      ? MockSellScreen(stockCode: widget.stockCode) // stockCode ?λ¬
                      : OrderHistoryScreen(stockCode: widget.stockCode),
            ),
          ],
        ),
      ),
    );
  }
}

