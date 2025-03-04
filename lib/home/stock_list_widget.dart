import 'package:flutter/material.dart';

class StockListWidget extends StatefulWidget {
  @override
  _StockListWidgetState createState() => _StockListWidgetState();
}

class _StockListWidgetState extends State<StockListWidget> {
  final List<Map<String, dynamic>> myStocks = [
    {"name": "테슬라", "price": "1,234원", "change": "-37(2.8%)"},
    {"name": "애플", "price": "1,234원", "change": "-37(2.8%)"},
    {"name": "삼성전자", "price": "1,234원", "change": "+37(2.8%)"},
    {"name": "MSFT", "price": "1,234원", "change": "+37(2.8%)"},
    {"name": "아마존", "price": "1,234원", "change": "+50(3.5%)"},
    {"name": "넷플릭스", "price": "1,234원", "change": "-25(1.9%)"},
    {"name": "엔비디아", "price": "1,234원", "change": "+42(2.2%)"},
    {"name": "구글", "price": "1,234원", "change": "-15(1.1%)"},
  ];

  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (myStocks.length / 4).ceil(); 

    return Column(
      children: [
        SizedBox(
          height: 260, 
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, pageIndex) {
              int startIndex = pageIndex * 4;
              int endIndex = startIndex + 4;
              List<Map<String, dynamic>> pageStocks = myStocks.sublist(
                startIndex,
                endIndex > myStocks.length ? myStocks.length : endIndex,
              );

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildStockCard(pageStocks[0]),
                        if (pageStocks.length > 1) _buildVerticalDivider(),
                        if (pageStocks.length > 1) buildStockCard(pageStocks[1]),
                      ],
                    ),
                    if (pageStocks.length > 2) _buildHorizontalDivider(),
                    if (pageStocks.length > 2)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildStockCard(pageStocks[2]),
                          if (pageStocks.length > 3) _buildVerticalDivider(),
                          if (pageStocks.length > 3) buildStockCard(pageStocks[3]),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),
        _buildPageIndicator(totalPages),
      ],
    );
  }
  Widget buildStockCard(Map<String, dynamic> stock) {
    return Expanded(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              stock["name"],
              style: TextStyle(fontFamily: 'MinSans', fontWeight: FontWeight.w900, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              stock["price"],
              style: TextStyle(fontSize: 14, fontFamily: 'MinSans', fontWeight: FontWeight.w900),
            ),
            Text(
              stock["change"],
              style: TextStyle(
                fontFamily: 'MinSans',
                fontWeight: FontWeight.w900,
                color: stock["change"].contains("+") ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 80, 
      color:  const Color.fromARGB(255, 75, 75, 75), 
      margin: EdgeInsets.symmetric(horizontal: 5),
    );
  }

  Widget _buildHorizontalDivider() {
    return Container(
      height: 1, 
      width: double.infinity, 
      color: const Color.fromARGB(255, 75, 75, 75), 
      margin: EdgeInsets.symmetric(vertical: 5),
    );
  }

  Widget _buildPageIndicator(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            index == _currentPage ? "●" : "○", 
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
      }),
    );
  }
}
