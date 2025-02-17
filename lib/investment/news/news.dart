import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stockapp/server/investment/news_server.dart'; // ✅ 뉴스 API 가져오기

class NewsScreen extends StatefulWidget {
  final String stockName;

  const NewsScreen({required this.stockName, Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<Map<String, dynamic>>> futureNews;

  @override
  void initState() {
    super.initState();
    futureNews = NewsService.fetchNews(widget.stockName); // ✅ 서비스에서 데이터 요청
  }

void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureNews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('관련 뉴스가 없습니다.'));
        }

        List<Map<String, dynamic>> articles = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];

            return Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                leading: article['imageUrl'] != null && article['imageUrl'].isNotEmpty
                    ? Image.network(
                        article['imageUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.white,
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.white,
                      ),
                title: Text(article['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(article['summary'] ?? '',
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => _launchURL(article['link']),
              ),
            );
          },
        );
      },
    );
  }
}
