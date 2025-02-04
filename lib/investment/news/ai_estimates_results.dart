import 'package:flutter/material.dart';

class NewsBasedInvestmentPrediction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  // 왼쪽 정렬
        children: [
          Text(
            '뉴스 기반 투자 예상 결과',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 10),  // 간격 추가
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox.shrink(),  // 회색 네모칸 안에는 텍스트 없이 빈 공간
          ),
          SizedBox(height: 10),  // 회색 네모칸과 아래 텍스트 사이의 간격
          Text(
            '어제보다 상승할 것으로 예상됩니다.',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
