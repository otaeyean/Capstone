import 'package:flutter/material.dart';
import 'package:stockapp/server/investment/recommend/recommend_list_server.dart';
import 'package:stockapp/data/category_icon_map.dart';
import 'dart:math';

class RecommendationTab extends StatefulWidget {
  @override
  _RecommendationTabState createState() => _RecommendationTabState();
}

class _RecommendationTabState extends State<RecommendationTab> {
  List<String> todayCategories = [];
  List<String> allCategories = [];
  final RecommendListServer apiService = RecommendListServer();

  final List<List<Color>> iconGradientPairs = [ 
    [Color(0xFF3EC8AC), Color(0xFFB2A5FF)],
    [Color(0xFF4CA1AF), Color(0xFFC4E0E5)],
    [Color(0xFF373B44), Color(0xFF4286f4)],
    [Color(0xFF89F7FE), Color(0xFF66A6FF)],
    [Color(0xFF1A2980), Color(0xFF26D0CE)],
    [Color(0xFF4D8994), Color(0xFF42B2A7)],
    [Color(0xFF47C1B0), Color(0xFFB0E9AE)],
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAllCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      List<String> categories = await apiService.fetchCategories();
      setState(() {
        todayCategories = categories;
      });
    } catch (e) {
      print('Error fetching today categories: $e');
    }
  }

  Future<void> _fetchAllCategories() async {
    try {
      List<String> categories = await apiService.fetchAllCategories();
      setState(() {
        allCategories = categories;
      });
    } catch (e) {
      print('Error fetching all categories: $e');
    }
  }

  List<Color> getGradientColors() {
    final rand = Random();
    return iconGradientPairs[rand.nextInt(iconGradientPairs.length)];
  }

 @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(thickness: 1),
        SizedBox(height: 8),
        Text(
          "전체 카테고리 리스트",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Color(0xFF03314B),
          ),
        ),
        SizedBox(height: 8),
        allCategories.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 25, //아래거랑 이거는 위아래 간격 조절 하는 거 
                  mainAxisSpacing: 25,
                  childAspectRatio: 5.0, //간격 조절 하는 거 이상하게 숫자가 커지면 더 좁아짐
                ),
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  String categoryName = allCategories[index];
                  IconData? categoryIcon = categoryIconMap[categoryName] ?? Icons.disabled_by_default; 
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container( //아이콘 크기
                            width: 70,
                            height: 70, 
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: getGradientColors(),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                categoryIcon,
                                size: 40, //아이콘 안에 이미지 크기 조절하는거
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10), 
                        Expanded(
                          child: Text(
                            categoryName,
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    ),
  );
}
}