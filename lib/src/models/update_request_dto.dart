/// Data transfer object for updating an existing feature request.
class UpdateRequestDto {
  /// Creates a new [UpdateRequestDto].
  const UpdateRequestDto({
    required this.title,
    required this.description,
  });

  /// New title for the feature request.
  final String title;

  /// New description for the feature request.
  final String description;

  /// Converts this [UpdateRequestDto] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'UpdateRequestDto(title: $title)';
  }
}
