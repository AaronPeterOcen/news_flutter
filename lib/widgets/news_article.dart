class NewsArticle {
  final String title;
  final String link;
  final String description;
  final String pubDate;

  NewsArticle({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
  });

  factory NewsArticle.fromJson(Map json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      link: json['link'] ?? '',
      description: json['description'] ?? 'No Description',
      pubDate: json['pubDate'] ?? 'No Date',
    );
  }
}
