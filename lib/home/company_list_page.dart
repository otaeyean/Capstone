// 넘기기만 함함
import 'package:flutter/material.dart';

class CompanyListPage extends StatelessWidget {
  final String category;

  const CompanyListPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dummyCompanies = [
      "$category 회사 1",
      "$category 회사 2",
      "$category 회사 3",
      "$category 회사 4",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('$category 관련 기업'),
      ),
      body: ListView.builder(
        itemCount: dummyCompanies.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(dummyCompanies[index]),
          );
        },
      ),
    );
  }
}
