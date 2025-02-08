//보유금액

import 'package:flutter/material.dart';

class UserBalance extends StatelessWidget {
  final double balance = 5000000;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("보유 금액", style: TextStyle(color: Colors.white, fontSize: 16)),
              Text(
                "${balance.toStringAsFixed(0)} 원",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -40, // 아래로 이동
          right: 0,
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: Text("금액설정", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
                child: Text("초기화", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
