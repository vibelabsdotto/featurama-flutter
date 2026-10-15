import 'review_links_config.dart';

class ProjectConfig {
  const ProjectConfig({
    required this.branding,
    required this.emailCollection,
    this.reviewLinks = const ReviewLinksConfig(),
  });

  factory ProjectConfig.fromJson(Map<String, dynamic> json) {
    return ProjectConfig(
      branding:
          BrandingConfig.fromJson(json['branding'] as Map<String, dynamic>),
      emailCollection: json['emailCollection'] as String? ?? 'none',
      reviewLinks: json['reviewLinks'] is Map<String, dynamic>
          ? ReviewLinksConfig.fromJson(
              json['reviewLinks'] as Map<String, dynamic>)
          : const ReviewLinksConfig(),
    );
  }

  final BrandingConfig branding;
  final String emailCollection;
  final ReviewLinksConfig reviewLinks;
}

class BrandingConfig {
  const BrandingConfig({required this.showBranding});

  factory BrandingConfig.fromJson(Map<String, dynamic> json) {
    return BrandingConfig(
      showBranding: json['showBranding'] as bool? ?? true,
    );
  }

  final bool showBranding;
}
