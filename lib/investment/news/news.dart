import 'package:flutter/material.dart';
import './ai_estimates_results.dart';  // 파일 import

class NewsScreen extends StatelessWidget {
  final List<Map<String, String>> articles = [
    {
      'title': '틀잡기용 제목 1',
      'subtitle': '소제목 1',
      'image': 'https://via.placeholder.com/150?text=Android+Image',
      'time': '1시간전'
    },
    {
      'title': '틀잡기용 제목 2',
      'subtitle': '소제목 2',
      'image': 'https://via.placeholder.com/150?text=Android+Image',
      'time': '2시간전'
    },
    {
      'title': '틀잡기용 제목 3',
      'subtitle': '소제목 3',
      'image': 'https://via.placeholder.com/150?text=Android+Image',
      'time': '3시간전'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(  // 전체 화면 스크롤 가능하도록 감싸기
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              '실시간 주요 뉴스',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,  // 부모 스크롤뷰에 맞게 크기 조정
            physics: NeverScrollableScrollPhysics(),  // 내부 스크롤 비활성화
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                color: Colors.white,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(
                    article['title']!,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article['subtitle']!,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      SizedBox(height: 8),  // 소제목 아래 간격 추가
                      Text(
                        article['time']!,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Image.network(
                    article['image']!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  onTap: () {},
                ),
              );
            },
          ),
          NewsBasedInvestmentPrediction(),  // 뉴스 기반 투자 예상 결과 추가
        ],
      ),
    );
  }
}
