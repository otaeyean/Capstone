import 'package:flutter/material.dart';

class WelcomeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '반갑습니다! user님',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white, 
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white, 
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey, 
                ),
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '총 자산: 10,000,000원',
                    style: TextStyle(color: Colors.white), 
                  ),
                  Text(
                    '보유 주식: 100',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
