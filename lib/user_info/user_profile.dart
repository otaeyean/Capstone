import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 40, color: Colors.black),
        ),
        SizedBox(width: 10),
        Text(
          "OOOO 유저님!\n즐거운 주식 되세요~",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
