import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/login/login.dart';
import 'package:stockapp/user_info/user_info_screen.dart';
import 'package:stockapp/server/home/user_service.dart'; // ✅ 서버 요청 분리 후 추가

class WelcomeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingWidget();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return _buildLoginRequiredBox(context);
        } else {
          final userId = snapshot.data!;
          return _buildUserInfoStream(context, userId);
        }
      },
    );
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  Widget _buildUserInfoStream(BuildContext context, String userId) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: Stream.periodic(Duration(seconds: 5)).asyncMap((_) => UserService.fetchPortfolioData(userId)), // ✅ 변경된 부분
      builder: (context, snapshot) {
        String balance = '로딩 중...';
        String totalProfitRate = '로딩 중...';

        if (snapshot.hasData) {
          balance = '${snapshot.data!['balance']} 원';
          totalProfitRate = '${snapshot.data!['totalProfitRate']} %';
        } else if (snapshot.hasError) {
          balance = '수익률 오류';
          totalProfitRate = '수익률 오류';
        }

        return _buildUserInfoBox(context, userId, balance, totalProfitRate);
      },
    );
  }

  Widget _buildUserInfoBox(BuildContext context, String userId, String balance, String totalProfitRate) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoScreen()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 2, 25, 54), Color.fromRGBO(0, 23, 54, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.lightGreen[200],
                    border: Border.all(
                      color: Colors.green[800]!,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.person_outline, size: 32, color: Colors.green[800]),
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$userId 님',
                      style: TextStyle(fontFamily: 'MinSans', fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '보유 금액: $balance',
                          style: TextStyle(fontFamily: 'Paperlogy', fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '수익률: $totalProfitRate',
                          style: TextStyle(fontFamily: 'Paperlogy', fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequiredBox(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('로그인이 필요합니다!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(radius: 35, backgroundColor: Colors.grey[800], child: Icon(Icons.person_outline, size: 32, color: Colors.white)),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('총 자산: -', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('보유 주식: -', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
