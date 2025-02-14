import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart'; 

class WelcomeBox extends StatelessWidget {
  Future<String?> _getUserId() async {
    return await AuthService.getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserId(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); 
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final userId = snapshot.data;
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
                  '반갑습니다! $userId 님', 
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
        } else {
          return Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
        }
      },
    );
  }
}
