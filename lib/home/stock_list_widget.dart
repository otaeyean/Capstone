import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart'; // UserStockModel import

class StockListWidget extends StatelessWidget {
  final List<UserStockModel>? stocks; // nullable로 변경 (로딩 고려)
  final bool isLoading;

  const StockListWidget({
    Key? key,
    required this.stocks,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "내 종목 보기",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'MinSans',
                color: Colors.black,
              ),
            ),
          ),

          SizedBox(height: 30),

          SizedBox(
            height: 130, // 항상 고정
            child: isLoading
                ? _buildLoadingList()
                : (stocks == null || stocks!.isEmpty)
                    ? _buildEmptyMessage()
                    : _buildStockList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    // 로딩 중인 상태에서 shimmer나 skeleton 대신 회색 박스 보여줌
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      padding: EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (_, __) => SizedBox(width: 40),
      itemBuilder: (_, __) => Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 64,
            height: 14,
            color: Colors.grey[300],
          ),
          SizedBox(height: 4),
          Container(
            width: 64,
            height: 12,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage() {
    return Center(
      child: Text(
        "보유한 종목이 없습니다",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontFamily: 'MinSans',
        ),
      ),
    );
  }

  Widget _buildStockList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: stocks!.length,
      padding: EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (context, index) => SizedBox(width: 40),
      itemBuilder: (context, index) {
        final stock = stocks![index];
        final profitRate = stock.profitRate ?? 0.0;
        final profitText =
            "${profitRate >= 0 ? "+" : ""}${profitRate.toStringAsFixed(2)}%";
        final changeColor = profitRate >= 0 ? Colors.red : Colors.blue;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEFF9F8),
              ),
              child: Icon(Icons.android, size: 36, color: Color(0xFF03314B)),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 64,
              child: Text(
                stock.name ?? '이름 없음',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MinSans',
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(
              width: 64,
              child: Text(
                profitText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'MinSans',
                  color: changeColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}
