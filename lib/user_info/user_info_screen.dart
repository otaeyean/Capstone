import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_data.dart';

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("내 종목 목록"),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<UserStockData>>(
        future: loadUserStockData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<UserStockData> userStocks = snapshot.data!;
            return ListView.builder(
              itemCount: userStocks.length,
              itemBuilder: (context, index) {
                var stock = userStocks[index];
                return ListTile(
                  title: Text(stock.name),
                  subtitle: Text('주식 수: ${stock.quantity} | 총 보유액: ${stock.totalValue} 원'),
                  trailing: Text('가격: ${stock.price} 원'),
                );
              },
            );
          } else {
            return Center(child: Text('데이터 없음'));
          }
        },
      ),
    );
  }
}
