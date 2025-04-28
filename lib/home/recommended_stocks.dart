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

  final List<Color> iconColors = [
 Color.fromARGB(255, 255, 255, 255),
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
  final screenWidth = MediaQuery.of(context).size.width;
  final containerWidth = screenWidth * 0.17; // 조금 작게 25%로 조정

  return Container(
    width: containerWidth,
    height: containerWidth * 1.05,
    // 패딩 줄임
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2),
          ),
          child: Icon(
            icon,
            size: 40,
            color: const Color.fromARGB(255, 23, 71, 43),
          ),
        ),
        const SizedBox(height: 2), // 간격도 약간 줄임
        Text(
          name,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'MinSans',
            fontWeight: FontWeight.w800,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

  Widget buildCategoryGroup(String title, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontFamily: 'MinSans',
            fontWeight: FontWeight.w800,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              categories.length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: buildCategoryItem(
                  categories[index],
                  iconColors[index % iconColors.length],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
Widget buildLoadingItem() {
  return Container(
    width: 137,
    height: 140,
    decoration: BoxDecoration(
      color: Colors.white, // 흰색 배경
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFFE0E0E0)), // 연한 테두리 추가 (선택사항)
    ),
  );
}

Widget buildLoadingGroup(String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontFamily: 'MinSans',
          fontWeight: FontWeight.w800,
          color: Color.fromARGB(255, 199, 199, 199),
        ),
      ),
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            5, // 로딩 시 5개 빈박스스
            (index) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: buildLoadingItem(),
            ),
          ),
        ),
      ),
    ],
  );
}

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "오늘의 카테고리",
          style: TextStyle(
            fontFamily: 'MinSans',
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        isLoading
            ? buildLoadingGroup("추천")
            : buildCategoryGroup("추천", recommendedCategories),
        const SizedBox(height: 20),
        isLoading
            ? buildLoadingGroup("비추천")
            : buildCategoryGroup("비추천", unrecommendedCategories),
      ],
    ),
  );
}

}