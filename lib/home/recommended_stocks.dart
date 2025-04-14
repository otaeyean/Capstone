import 'package:flutter/material.dart';
import 'package:stockapp/server/home/recommended_server.dart';
import 'package:stockapp/data/category_icon_map.dart';

class RecommendedStocks extends StatefulWidget {
  const RecommendedStocks({Key? key});

  @override
  State<RecommendedStocks> createState() => _RecommendedStocksState();
}

class _RecommendedStocksState extends State<RecommendedStocks> {
  List<String> recommendedCategories = [];
  List<String> unrecommendedCategories = [];
  bool isLoading = true;

  // 단일 색상 리스트로 변경
  final List<Color> iconColors = [
    Color(0xFF25478C), // 네이비 블루
    Color(0xFF135338), // 다크 그린
    Color(0xFF804600), // 브라운
  ];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final result = await RecommendedService.fetchRecommendedCategories();

      final half = result.length ~/ 2;
      setState(() {
        recommendedCategories = result.sublist(0, half);
        unrecommendedCategories = result.sublist(half);
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCategoryItem(String name, Color backgroundColor) {
    final icon = categoryIconMap[name] ?? Icons.category;
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor, // 단일 색상 적용
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'MinSans',
              fontFamilyFallback: ['sans-serif'],
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  SizedBox(width: 18),
                  Text(
                    "오늘의 카테고리",
                    style: TextStyle(
                      fontFamily: 'MinSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Loading
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Recommended
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '추천',
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'MinSans',
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03314B),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    recommendedCategories.length,
                    (index) => buildCategoryItem(
                      recommendedCategories[index],
                      iconColors[index % iconColors.length],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Unrecommended
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '비추천',
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'MinSans',
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03314B),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    unrecommendedCategories.length,
                    (index) => buildCategoryItem(
                      unrecommendedCategories[index],
                      iconColors[index % iconColors.length],
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }
}
