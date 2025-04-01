import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart';
import 'package:stockapp/investment/stock_detail_screen.dart';
import 'package:intl/intl.dart';

class MyStockList extends StatelessWidget {
  final List<UserStockModel> stocks;

  MyStockList({required this.stocks});
  final formatter = NumberFormat('#,###'); // 숫자 포맷터

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 좌우 꽉 채우기
      color: const Color(0xFFEFF9F8), // 연한 초록 배경
      child: stocks.isEmpty
          ? Center(child: Text("보유한 주식이 없습니다."))
          : ListView.builder(
              padding: EdgeInsets.zero, // 전체 리스트 패딩 제거
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: stocks.length,
              itemBuilder: (context, index) {
                var stock = stocks[index];

                String stockName = stock.name ?? '상장이 폐지되었습니다';

                double stockPrice = stock.price ?? 0.0;
                double stockProfitRate = stock.profitRate ?? 0.0;
                int stockQuantity = stock.quantity ?? 0;
                double totalValue = stock.totalValue ?? 0.0;
                String stockCode = stock.stockCode ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Material(
                    color: Colors.white, // 카드 배경 흰색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 모서리 살짝 둥글게
                    ),
                    elevation: 5, // 입체감 추가
                    shadowColor: Colors.grey.withOpacity(0.2), // 그림자 효과 추가
                    child: InkWell(
                      splashColor: Colors.transparent, // 클릭 효과 제거
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent, // hover 효과 제거
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockDetailScreen(
                              stock: {
                                'stockName': stockName,
                                'currentPrice': stockPrice.toString(),
                                'changeRate': stockProfitRate.toString(),
                                'tradeVolume': stockQuantity.toString(),
                                'stockCode': stockCode,
                              },
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 왼쪽: 이름 + 수량
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stockName,
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text(
                                  '$stockQuantity 주 | 총 보유액: ${formatter.format(totalValue)} 원',
                                  style: TextStyle(
                                    color: Colors.grey[600], // 연한 회색 텍스트
                                  ),
                                ),
                              ],
                            ),
                            // 오른쪽: 가격 + 수익률
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${formatter.format(stockPrice)} 원',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('${stockProfitRate.toStringAsFixed(2)} %',
                                    style: TextStyle(
                                      color: stockProfitRate >= 0 ? Colors.red : Colors.blue,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
