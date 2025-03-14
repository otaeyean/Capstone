import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart';
import 'package:stockapp/investment/stock_detail_screen.dart'; // ?�정??모델 ?�일 ?�용

class MyStockList extends StatelessWidget {
  final List<UserStockModel> stocks;

  MyStockList({required this.stocks}); 

  @override
  Widget build(BuildContext context) {
    return stocks.isEmpty
        ? Center(child: Text("보유??주식???�습?�다."))
        : ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              var stock = stocks[index];

              // ??null 방어 로직 추�?
              String stockName = stock.name ?? '?�름 ?�음';
              double stockPrice = stock.price ?? 0.0;
              double stockProfitRate = stock.profitRate ?? 0.0;
              int stockQuantity = stock.quantity ?? 0;
              double totalValue = stock.totalValue ?? 0.0;
              String stockCode = stock.stockCode ?? ''; // ??종목 코드 추�?

              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Color(0xFFF9F7F0),  // ?�이보리 ?�상
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(stockName, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$stockQuantity �?| �?보유?? ${totalValue.toStringAsFixed(0)} ??),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${stockPrice.toStringAsFixed(0)} ??, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${stockProfitRate.toStringAsFixed(2)} %',
                          style: TextStyle(color: stockProfitRate >= 0 ? Colors.red : Colors.blue)),
                    ],
                  ),
                  onTap: () {
                    // ???�이???�달 ??`null` 방어 �?String 변??처리
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDetailScreen(
                          stock: {
                            'stockName': stockName,  // ??`null` 방어 기본�?                            'currentPrice': stockPrice.toString(),  // ??`double` ??`String`
                            'changeRate': stockProfitRate.toString(),  // ??`double` ??`String`
                            'tradeVolume': stockQuantity.toString(),  // ??`int` ??`String`
                            'stockCode': stockCode,  // ??종목 코드 추�?
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}

