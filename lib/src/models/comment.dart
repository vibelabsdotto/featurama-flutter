/// A discussion comment on a feature request.
class Comment {
  const Comment({
    required this.id,
    required this.featureRequestId,
    required this.content,
    required this.authorIdentifier,
    required this.authorRole,
    required this.voteCount,
    required this.createdAt,
    this.authorName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        featureRequestId: json['featureRequestId'] as String,
        content: json['content'] as String,
        authorIdentifier: json['authorIdentifier'] as String? ?? '',
        authorName: json['authorName'] as String?,
        authorRole: json['authorRole'] as String? ?? 'user',
        voteCount: json['voteCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String featureRequestId;
  final String content;

  /// The public API may anonymize this value; do not use it for authorization.
  final String authorIdentifier;
  final String? authorName;
  final String authorRole;
  final int voteCount;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'featureRequestId': featureRequestId,
        'content': content,
        'authorIdentifier': authorIdentifier,
        'authorName': authorName,
        'authorRole': authorRole,
        'voteCount': voteCount,
        'createdAt': createdAt.toIso8601String(),
      };
}
