/// Status of a feature request.
enum FeatureRequestStatus {
  /// Initial state when a request is submitted.
  requested('Requested'),

  /// Request has been added to the roadmap.
  roadmap('Roadmap'),

  /// Request is currently being worked on.
  inProgress('InProgress'),

  /// Request has been completed.
  done('Done'),

  /// Request has been declined.
  declined('Declined');

  const FeatureRequestStatus(this.value);

  /// The string value used in API communication.
  final String value;

  /// Creates a [FeatureRequestStatus] from a string value.
  static FeatureRequestStatus fromString(String value) {
    return FeatureRequestStatus.values.firstWhere(
      (status) => status.value.toLowerCase() == value.toLowerCase(),
      orElse: () => FeatureRequestStatus.requested,
    );
  }
}

/// Source of a feature request.
enum FeatureRequestSource {
  /// Request was submitted via the SDK.
  sdk('SDK'),

  /// Request was created from the dashboard.
  dashboard('Dashboard');

  const FeatureRequestSource(this.value);

  /// The string value used in API communication.
  final String value;

  /// Creates a [FeatureRequestSource] from a string value.
  static FeatureRequestSource fromString(String value) {
    return FeatureRequestSource.values.firstWhere(
      (source) => source.value.toLowerCase() == value.toLowerCase(),
      orElse: () => FeatureRequestSource.sdk,
    );
  }
}

/// Represents a feature request in Featurama.
class FeatureRequest {
  /// Creates a new [FeatureRequest].
  const FeatureRequest({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.source,
    required this.voteCount,
    required this.submitterIdentifier,
    required this.createdAt,
    this.commentCount = 0,
    this.isApproved = true,
    this.hasVoted = false,
    this.submitterEmail,
    this.deviceInfo,
  });

  /// Creates a [FeatureRequest] from a JSON map.
  factory FeatureRequest.fromJson(Map<String, dynamic> json) {
    return FeatureRequest(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: FeatureRequestStatus.fromString(json['status'] as String),
      source: FeatureRequestSource.fromString(json['source'] as String),
      voteCount: json['voteCount'] as int,
      submitterIdentifier: json['submitterIdentifier'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      commentCount: json['commentCount'] as int? ?? 0,
      isApproved: json['isApproved'] as bool? ?? true,
      hasVoted: json['hasVoted'] as bool? ?? false,
      submitterEmail: json['submitterEmail'] as String?,
      deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
    );
  }

  /// Unique identifier of the feature request.
  final String id;

  /// ID of the project this request belongs to.
  final String projectId;

  /// Title of the feature request.
  final String title;

  /// Detailed description of the feature request.
  final String description;

  /// Current status of the feature request.
  final FeatureRequestStatus status;

  /// Source of the feature request (SDK or Dashboard).
  final FeatureRequestSource source;

  /// Number of votes this request has received.
  final int voteCount;

  /// Identifier of the user who submitted this request.
  final String submitterIdentifier;

  /// Timestamp when this request was created.
  final DateTime createdAt;

  /// Number of comments attached to this request.
  final int commentCount;

  /// Whether the owner approved this request for public viewing and voting.
  final bool isApproved;

  /// Viewer vote state, populated by listing with a submitter identifier.
  final bool hasVoted;

  /// Returned only when the backend permits contact/device metadata.
  final String? submitterEmail;
  final Map<String, dynamic>? deviceInfo;

  /// Converts this [FeatureRequest] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status.value,
      'source': source.value,
      'voteCount': voteCount,
      'submitterIdentifier': submitterIdentifier,
      'createdAt': createdAt.toIso8601String(),
      'commentCount': commentCount,
      'isApproved': isApproved,
      'hasVoted': hasVoted,
      if (submitterEmail != null) 'submitterEmail': submitterEmail,
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
    };
  }

  @override
  String toString() {
    return 'FeatureRequest(id: $id, title: $title, status: ${status.value}, voteCount: $voteCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
