/// Optional store links from the project configuration.
class ReviewLinksConfig {
  const ReviewLinksConfig({this.appStoreUrl, this.playStoreUrl});

  factory ReviewLinksConfig.fromJson(Map<String, dynamic> json) {
    return ReviewLinksConfig(
      appStoreUrl:
          json['appStoreUrl'] is String ? json['appStoreUrl'] as String : null,
      playStoreUrl: json['playStoreUrl'] is String
          ? json['playStoreUrl'] as String
          : null,
    );
  }

  final String? appStoreUrl;
  final String? playStoreUrl;
}
