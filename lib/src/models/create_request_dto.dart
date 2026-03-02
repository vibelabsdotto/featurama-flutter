/// Data transfer object for creating a new feature request.
class CreateRequestDto {
  /// Creates a new [CreateRequestDto].
  const CreateRequestDto({
    required this.title,
    required this.description,
    required this.submitterIdentifier,
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

  /// Converts this [CreateRequestDto] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'submitterIdentifier': submitterIdentifier,
    };
  }

  @override
  String toString() {
    return 'CreateRequestDto(title: $title, submitterIdentifier: $submitterIdentifier)';
  }
}
