import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stockapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); 

  bool isLoggedIn = false; // 로그인 상태 추적 변수

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 앱 시작 시 로그인 상태 확인
  }

  // 로그인 상태 확인
  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getString('nickname') != null; // SharedPreferences에서 닉네임이 있으면 로그인된 상태
    });
  }

  // 로그인 함수
  Future<void> _login() async {
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text.trim();

    if (nickname.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임과 비밀번호를 입력해주세요.')),
      );
      return;
    }

    final url = Uri.parse('http://withyou.me:8080/login');
    final body = jsonEncode({
      "userId": nickname,
      "password": password,
    });

    print('✅요청 Body: $body');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: body,
      );

      print('✅응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final message = response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$nickname 님 어서오세요!')),
        );

        // 로그인 성공 시 닉네임을 SharedPreferences에 저장
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('nickname', nickname);

        // 로그인 상태 변경
        setState(() {
          isLoggedIn = true;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      } else {
        final error = jsonDecode(response.body)['message'] ?? '로그인 실패!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  // 로그아웃 함수
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('nickname'); // SharedPreferences에서 닉네임 삭제

    setState(() {
      isLoggedIn = false; // 로그인 상태 업데이트
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // 로그아웃 후 로그인 페이지로 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '로그인',
          style: TextStyle(fontFamily: "GmarketBold"),
        ),
        actions: [
          // 로그인이 되어있다면 로그아웃 버튼 표시
          if (isLoggedIn)
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _logout, // 로그아웃 함수 실행
            ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 60),
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontFamily: "GmarketBold",
                ),
                children: [
                  TextSpan(text: ' 반갑습니다!\n '),
                  TextSpan(
                    text: '로그인',
                    style: TextStyle(
                      color: const Color.fromARGB(173, 13, 13, 14),
                      fontFamily: "GmarketBold",
                    ),
                  ),
                  TextSpan(text: '을 해주세요.\n\n'),
                ],
              ),
            ),
            Text('닉네임', style: TextStyle(fontSize: 16, fontFamily: "GmarketBold")),
            SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: '닉네임을 입력해주세요',
                hintStyle: TextStyle(fontFamily: "GmarketMedium"),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('비밀번호', style: TextStyle(fontSize: 16, fontFamily: "GmarketBold")),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: '비밀번호를 입력해주세요',
                hintStyle: TextStyle(fontFamily: "GmarketMedium"),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 150),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoggedIn ? null : _login, // 로그인 된 상태에서는 버튼 비활성화
                  child: Text(
                    isLoggedIn ? '로그인됨' : '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "GmarketBold",
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
