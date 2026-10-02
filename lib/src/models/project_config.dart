class ProjectConfig {
  const ProjectConfig({
    required this.branding,
    required this.emailCollection,
  });

  factory ProjectConfig.fromJson(Map<String, dynamic> json) {
    return ProjectConfig(
      branding:
          BrandingConfig.fromJson(json['branding'] as Map<String, dynamic>),
      emailCollection: json['emailCollection'] as String? ?? 'none',
    );
  }

  final BrandingConfig branding;
  final String emailCollection;
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
