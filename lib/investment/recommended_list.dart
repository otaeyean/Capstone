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

  final List<Color> iconColors = [
      Color.fromARGB(150, 38, 107, 234), // 브라운
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

  Color getRandomColor() {
    final rand = Random();
    return iconColors[rand.nextInt(iconColors.length)];
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
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 25,
                    childAspectRatio: 5.0,
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
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: getRandomColor(),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  categoryIcon,
                                  size: 40,
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
