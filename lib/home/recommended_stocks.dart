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

  // 통일된 색상 리스트
  final Color unifiedColor = Color(0xFF25478C); // 네이비 블루

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

  Widget buildCategoryItem(String name) {
    final icon = categoryIconMap[name] ?? Icons.category;
    return Column(
      children: [
        Container(
          width: 70,
          height: 70, //아이콘 크기 증가
          decoration: BoxDecoration(
            color: unifiedColor, 
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: unifiedColor.withOpacity(0.4),
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 35),  //아이콘 크기
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80, 
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'MinSans',
              fontFamilyFallback: ['sans-serif'],
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,  // 텍스트 넘침 처리
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
                      color: Color(0xFF03314B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

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
                    (index) => buildCategoryItem(recommendedCategories[index]),
                  ),
                ),

                const SizedBox(height: 15),

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
                    (index) => buildCategoryItem(unrecommendedCategories[index]),
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
