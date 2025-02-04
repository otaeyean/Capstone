import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:stockapp/investment/stock_detail_screen.dart';

class InvestmentScreen extends StatelessWidget {
  final List<Map<String, dynamic>> stocks = [
    {
      "name": "삼성전자",
      "ticker": "005930",
      "price": "71,800",
      "change_value": -1200,
      "rise_percent": null,
      "fall_percent": 1.64,
      "quantity": 50,
      "market": "국내",
      "description": "삼성전자는 반도체, 스마트폰, 디스플레이 등 다양한 전자 제품을 제조하는 글로벌 기업이다."
    },
    {
      "name": "네이버",
      "ticker": "035420",
      "price": "187,500",
      "change_value": 500,
      "rise_percent": 0.27,
      "fall_percent": null,
      "quantity": 15,
      "market": "국내",
      "description": "네이버는 검색 포털, 클라우드, AI 기술을 기반으로 다양한 인터넷 서비스를 제공하는 IT 기업이다."
    },
    {
      "name": "LG전자",
      "ticker": "066570",
      "price": "145,000",
      "change_value": -1000,
      "rise_percent": null,
      "fall_percent": 0.68,
      "quantity": 25,
      "market": "국내",
      "description": "LG전자는 전자 및 가전 제품을 생산하는 글로벌 기업으로, 스마트폰, TV 등 다양한 제품을 제공한다."
    },
    {
      "name": "Tesla",
      "ticker": "TSLA",
      "price": "584,296",
      "change_value": -8335,
      "rise_percent": null,
      "fall_percent": 1.4,
      "quantity": 20,
      "market": "해외",
      "description": "Tesla는 전기차, 에너지 저장 시스템, 자율주행 기술을 개발하는 글로벌 자동차 및 에너지 기업이다."
    },
    {
      "name": "Apple",
      "ticker": "AAPL",
      "price": "189,000",
      "change_value": 1200,
      "rise_percent": 0.64,
      "fall_percent": null,
      "quantity": 30,
      "market": "해외",
      "description": "Apple은 iPhone, Mac, iPad 등 혁신적인 제품과 소프트웨어 서비스를 제공하는 IT 기업이다."
    },
    {
      "name": "Microsoft",
      "ticker": "MSFT",
      "price": "320,000",
      "change_value": 2500,
      "rise_percent": 0.79,
      "fall_percent": null,
      "quantity": 18,
      "market": "해외",
      "description": "Microsoft는 Windows, Office, Azure와 같은 소프트웨어 및 클라우드 서비스를 제공하는 글로벌 IT 기업이다."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('모의 투자'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
         
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        
          DefaultTabController(
            length: 4,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: '전체'),
                    Tab(text: '국내'),
                    Tab(text: '해외'),
                    Tab(text: '관심'),
                  ],
                ),
                SizedBox(
                  height: 400, 
                  child: TabBarView(
                    children: [
                      _buildStockList(stocks), 
                      _buildStockList(stocks.where((stock) => stock['market'] == '국내').toList()), 
                      _buildStockList(stocks.where((stock) => stock['market'] == '해외').toList()), 
                      Center(child: Text('관심 탭')), 
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildStockList(List<Map<String, dynamic>> stocks) {
  return ListView.builder(
    itemCount: stocks.length,
    itemBuilder: (context, index) {
      final stock = stocks[index];
      return Card(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: ListTile(
          title: Text(stock['name']),
          subtitle: Text('${stock['price']}원 (${stock['change_value']}원)'),
          trailing: Icon(
            stock['change_value'] > 0
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: stock['change_value'] > 0 ? Colors.green : Colors.red,
          ),
          onTap: () {
           
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StockDetailScreen(stock: stock),
              ),
            );
          },
        ),
      );
    },
  );
}
}