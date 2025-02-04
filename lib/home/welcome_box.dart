import 'package:flutter/material.dart';

class WelcomeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
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
                backgroundImage: AssetImage('assets/user_image.png'), // 예시 이미지
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
