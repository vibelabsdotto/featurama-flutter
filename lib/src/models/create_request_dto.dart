/// Data transfer object for creating a new feature request.
class CreateRequestDto {
  /// Creates a new [CreateRequestDto].
  const CreateRequestDto({
    required this.title,
    required this.description,
    required this.submitterIdentifier,
    this.email,
    this.deviceInfo,
  });

  /// Title of the feature request.
  final String title;

  /// Detailed description of the feature request.
  final String description;

  /// Identifier of the user submitting this request.
  ///
  /// This should be a unique identifier for the user in your app,
  /// such as a user ID or device ID.
  final String submitterIdentifier;

  /// Contact email, required only when project configuration requires it.
  final String? email;

  /// Optional, caller-provided device metadata. Not collected automatically.
  final Map<String, dynamic>? deviceInfo;

  /// Converts this [CreateRequestDto] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'submitterIdentifier': submitterIdentifier,
      if (email != null) 'email': email,
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
    };
  }

  @override
  String toString() {
    return 'CreateRequestDto(title: $title, submitterIdentifier: $submitterIdentifier)';
  }
}
