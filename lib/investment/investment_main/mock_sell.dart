import 'package:flutter/material.dart';

class MockSellScreen extends StatefulWidget {
  @override
  _MockSellScreenState createState() => _MockSellScreenState();
}

class _MockSellScreenState extends State<MockSellScreen> {
  TextEditingController _quantityController = TextEditingController();  

  @override
  void dispose() {
    _quantityController.dispose();  
    super.dispose();
  }

  void _formatQuantityInput() {
    String inputText = _quantityController.text.replaceAll(RegExp(r'\D'), ''); 
    if (inputText.isNotEmpty) {
      _quantityController.text = "$inputText 주"; 
      _quantityController.selection = TextSelection.fromPosition(TextPosition(offset: _quantityController.text.length)); // 커서 끝으로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            Text(
              '보유 금액 5,000,000원',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 241, 241, 241),
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '매도할 가격',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '584,296원',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
           
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 241, 241, 241),
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '수량',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number, 
                    decoration: InputDecoration(
                      hintText: '몇 주 매도할까요?',
                      border: InputBorder.none, 
                    ),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    onChanged: (text) {                  
                      _formatQuantityInput();
                    },
                    onEditingComplete: () {
                      _formatQuantityInput();
                    },
                    onTapOutside: (_) {
                      _formatQuantityInput();
                    },
                  ),
                  SizedBox(height: 8),
                  Text(
                    '총 1,143,500원',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
           
            Spacer(),
            
            Container(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: () {
                 
                  String enteredQuantity = _quantityController.text;
                  if (enteredQuantity.isNotEmpty) {
                   
                    print("[테스트]사용자가 입력한 수량 확인: $enteredQuantity");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, 
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '판매하기',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
