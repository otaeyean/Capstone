import 'package:flutter/material.dart';

class WelcomeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('반갑습니다! user님', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 30), // 아이콘으로 사용자 이미지 대체
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('총 자산: 10,000,000원'),
                  Text('보유 주식: 100'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
