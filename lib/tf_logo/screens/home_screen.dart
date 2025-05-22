import 'package:flutter/material.dart';
import 'detection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: Center(
        child: ElevatedButton(
          child: const Text("객체 인식 시작"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DetectionScreen()),
            );
          },
        ),
      ),
    );
  }
}