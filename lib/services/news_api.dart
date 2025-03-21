import 'dart:convert';
import 'package:http/http.dart' as http;

// 뉴스 아이템 모델
class NewsItem {
  final String title;
  final String imageUrl;
  final String newsUrl;
  final String date;
  final String source;

  NewsItem({
    required this.title,
    required this.imageUrl,
    required this.newsUrl,
    required this.date,
    required this.source,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      newsUrl: json['link'] ?? '',
      date: json['pubDate'] ?? '',
      source: json['source'] ?? '네이버 뉴스',
    );
  }
}

class NewsApiService {
  // 실제 네이버 API를 사용하려면 네이버 개발자 센터에서 클라이언트 ID와 시크릿을 발급받아야 합니다.
  // https://developers.naver.com/docs/serviceapi/search/news/news.md
  static Future<List<NewsItem>> fetchNews(String keyword) async {
    try {
      final url = Uri.parse('https://openapi.naver.com/v1/search/news.json?query=${Uri.encodeComponent(keyword)}&display=10&sort=date');
      
      final response = await http.get(
        url,
        headers: {
          'X-Naver-Client-Id': '아이디', // 네이버 개발자 센터에서 발급받은 클라이언트 ID       assets/config/.env 파일에 저장
          'X-Naver-Client-Secret': '비번', // 네이버 개발자 센터에서 발급받은 클라이언트 시크릿
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        return items.map((item) => NewsItem.fromJson(item)).toList();
      } else {
        // 에러 처리를 위해 빈 리스트 대신 더미 데이터 반환
        return _getDummyNewsData();
      }
    } catch (e) {
      // 예외 발생 시 더미 데이터 반환
      return _getDummyNewsData();
    }
  }

  // 더미 뉴스 데이터 (API 연결 전 테스트용)
  static List<NewsItem> _getDummyNewsData() {
    return [
      NewsItem(
        title: '공유 킥보드 이용자 안전수칙 강화... 헬멧 착용 의무화',
        imageUrl: 'https://via.placeholder.com/150',
        newsUrl: 'https://www.example.com/news/1',
        date: '2023-03-20',
        source: '교통안전공단',
      ),
      NewsItem(
        title: '서울시, 공유 킥보드 전용 주차구역 400곳 추가 설치',
        imageUrl: 'https://via.placeholder.com/150',
        newsUrl: 'https://www.example.com/news/2',
        date: '2023-03-18',
        source: '서울신문',
      ),
      NewsItem(
        title: '공유 킥보드 사고 증가... 안전교육 필요성 제기',
        imageUrl: 'https://via.placeholder.com/150',
        newsUrl: 'https://www.example.com/news/3',
        date: '2023-03-15',
        source: '안전뉴스',
      ),
      NewsItem(
        title: '킥보드 음주운전 적발 시 면허취소 법안 발의',
        imageUrl: 'https://via.placeholder.com/150',
        newsUrl: 'https://www.example.com/news/4',
        date: '2023-03-12',
        source: '법률신문',
      ),
      NewsItem(
        title: '공유 킥보드 업체, 헬멧 무료 대여 서비스 시작',
        imageUrl: 'https://via.placeholder.com/150',
        newsUrl: 'https://www.example.com/news/5',
        date: '2023-03-10',
        source: '모빌리티 타임즈',
      ),
      NewsItem(
        title: '한국도로공사, 도로 위 공유 킥보드 안전 가이드라인 발표',
        imageUrl: 'https://via.placeholder.com/150',
        newsUrl: 'https://www.example.com/news/6',
        date: '2023-03-08',
        source: '도로교통공단',
      ),
      NewsItem(
        title: '공유 킥보드 배터리 안전성 검사 강화',
        imageUrl: 'https://via.placeholder.com/150',
        newsUrl: 'https://www.example.com/news/7',
        date: '2023-03-05',
        source: '전자신문',
      ),
      NewsItem(
        title: '야간 킥보드 이용 시 발광 조끼 착용 권고',
        imageUrl: 'https://via.placeholder.com/150',
        newsUrl: 'https://www.example.com/news/8',
        date: '2023-03-03',
        source: '국민일보',
      ),
      NewsItem(
        title: '대학가 주변 공유 킥보드 주차 문제 심각',
        imageUrl: 'https://via.placeholder.com/150',
        newsUrl: 'https://www.example.com/news/9',
        date: '2023-03-01',
        source: '대학신문',
      ),
      NewsItem(
        title: '겨울철 공유 킥보드 사고 증가, 노면 관리 강화',
        imageUrl: 'https://via.placeholder.com/150',
        newsUrl: 'https://www.example.com/news/10',
        date: '2023-02-28',
        source: '기상신문',
      ),
    ];
  }
}