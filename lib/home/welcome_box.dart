import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/login/login.dart'; // LoginPage import
import 'package:stockapp/user_info/user_info_screen.dart'; // UserInfoScreen import

class WelcomeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black, // 검정색 배경
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        } else if (snapshot.hasError) {
          return _buildLoginRequiredBox(context); // 오류 발생 시 로그인 유도
        } else if (snapshot.hasData) {
          final userId = snapshot.data!;
          return _buildUserInfoScreenButton(context, userId);
        } else {
          return _buildLoginRequiredBox(context); // 데이터 없을 시 로그인 유도
        }
      },
    );
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname'); // SharedPreferences에서 닉네임 가져오기
  }

  // 로그인 필요 메시지 및 로그인 페이지 이동 버튼
  Widget _buildLoginRequiredBox(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black, // 검정색 배경
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '로그인을 진행해주세요!', // 변경된 텍스트
              style: TextStyle(
                fontFamily: 'MinSans',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[800], // 프로필 사진 배경색 회색
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('총 자산: -',
                        style: TextStyle(fontFamily: 'MinSans', fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('보유 주식: -',
                        style: TextStyle(fontFamily: 'MinSans', fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 로그인 되었을 때 UserInfoScreen으로 이동하는 버튼
  Widget _buildUserInfoScreenButton(BuildContext context, String userId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserInfoScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black, // 검정색 배경
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Colors.grey),
                ),
                SizedBox(width: 20),

                /// ✅ `da 님`을 프로필 옆으로 이동
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$userId 님',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 5), // 간격 추가

                    /// ✅ `총 자산` & `보유 주식`을 프로필 네임 아래로 이동
                    Text('총 자산: 5,000,000원', style: TextStyle(color: Colors.white)),
                    Text('보유 주식: 500주', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
