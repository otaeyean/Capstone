import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ranking_tile.dart';

class RankingScreen extends StatefulWidget {
  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<dynamic> rankings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRankings();
  }

  Future<void> fetchRankings() async {
    final response = await http.get(Uri.parse('http://withyou.me:8080/user-info/user-profits'));
    if (response.statusCode == 200) {
      setState(() {
        rankings = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FBF5), // 🌿 더 연한 초록색
    appBar: AppBar(
  title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        '🏆 수익률 순위 🏆',
        style: TextStyle(
          color: Color(0xFF1B1F3B),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    ],
  ),
  backgroundColor: Colors.transparent,
  elevation: 0,
  foregroundColor: Color(0xFF1B1F3B),
  centerTitle: true,
),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                final item = rankings[index];
                return RankingTile(
                  rank: index + 1,
                  userId: item['userId'],
                  profit: item['totalProfit'].toDouble(),
                );
              },
            ),
    );
  }
}
