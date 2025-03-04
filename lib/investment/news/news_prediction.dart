import 'package:flutter/material.dart';

class NewsPredictionWidget extends StatelessWidget {
  final String predictionText;

  const NewsPredictionWidget({required this.predictionText, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '뉴스 기반 투자 예상 결과',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              predictionText,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
