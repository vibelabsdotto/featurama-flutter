import 'package:dio/dio.dart';

import 'exceptions/featurama_exception.dart';
import 'models/create_request_dto.dart';
import 'models/feature_request.dart';
import 'models/paginated_response.dart';
import 'models/project_config.dart';
import 'models/update_request_dto.dart';

/// Client for interacting with the Featurama API.
///
/// This client provides methods to manage feature requests, including
/// creating, updating, listing, and voting on requests.
///
/// Example:
/// ```dart
/// final client = FeaturamaClient(
///   apiKey: 'fm_live_your_api_key_here',
///   baseUrl: 'https://your-deployment.convex.site',
/// );
///
/// // Get feature requests
/// final response = await client.getRequests();
/// print('Found ${response.totalCount} requests');
///
/// // Create a new request
/// final request = await client.createRequest(
///   CreateRequestDto(
///     title: 'Dark mode support',
///     description: 'Please add dark mode to the app',
///     submitterIdentifier: 'user_123',
///   ),
/// );
/// ```
class FeaturamaClient {
  /// Creates a new [FeaturamaClient].
  ///
  /// The [apiKey] is required and must be a valid Featurama API key
  /// (format: `fm_live_xxxxxxxxxxxx`).
  ///
  /// The [baseUrl] should be your Convex deployment URL
  /// (e.g., `https://your-deployment.convex.site`).
  ///
  /// An optional [dio] instance can be provided for custom configuration
  /// or testing.
  FeaturamaClient({
    required String apiKey,
    required String baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['X-Api-Key'] = apiKey;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  final Dio _dio;

  /// Retrieves a paginated list of feature requests.
  ///
  /// The [page] parameter specifies which page to retrieve (1-indexed).
  /// The [pageSize] parameter specifies how many items per page.
  ///
  /// Throws [FeaturamException] if the request fails.
  Future<PaginatedResponse<FeatureRequest>> getRequests({
    int page = 1,
    int pageSize = 20,
    String? filter,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/public/requests',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (filter != null) 'filter': filter,
        },
      );

      return PaginatedResponse.fromJson(
        response.data!,
        FeatureRequest.fromJson,
      );
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e);
    }
  }

  /// Creates a new feature request.
  ///
  /// The [dto] contains the title, description, and submitter identifier
  /// for the new request.
  ///
  /// Returns the created [FeatureRequest].
  ///
  /// Throws [FeaturamException] if the request fails.
  Future<FeatureRequest> createRequest(CreateRequestDto dto) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/public/requests',
        data: dto.toJson(),
      );

      return FeatureRequest.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e);
    }
  }

  /// Updates an existing feature request.
  ///
  /// The [id] is the unique identifier of the request to update.
  /// The [dto] contains the new title and description.
  /// The [submitterIdentifier] must match the original submitter to authorize
  /// the update.
  ///
  /// Returns the updated [FeatureRequest].
  ///
  /// Throws [NotFoundException] if the request doesn't exist.
  /// Throws [UnauthorizedException] if the submitter doesn't match.
  /// Throws [FeaturamException] for other errors.
  Future<FeatureRequest> updateRequest(
    String id,
    UpdateRequestDto dto,
    String submitterIdentifier,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/public/requests/$id',
        data: dto.toJson(),
        queryParameters: {
          'submitterIdentifier': submitterIdentifier,
        },
      );

      return FeatureRequest.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e);
    }
  }

  /// Adds a vote to a feature request.
  ///
  /// The [requestId] is the unique identifier of the request to vote on.
  /// The [voterIdentifier] is a unique identifier for the voter (e.g., user ID).
  ///
  /// Returns the updated [FeatureRequest] with the new vote count.
  ///
  /// Throws [ConflictException] if the voter has already voted on this request.
  /// Throws [NotFoundException] if the request doesn't exist.
  /// Throws [FeaturamException] for other errors.
  Future<FeatureRequest> vote(String requestId, String voterIdentifier) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/public/requests/$requestId/vote',
        data: {
          'voterIdentifier': voterIdentifier,
        },
      );

      return FeatureRequest.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e);
    }
  }

  /// Removes a vote from a feature request.
  ///
  /// The [requestId] is the unique identifier of the request to remove the
  /// vote from.
  /// The [voterIdentifier] is the unique identifier of the voter who previously
  /// voted.
  ///
  /// Returns the updated [FeatureRequest] with the new vote count.
  ///
  /// Throws [NotFoundException] if the request or vote doesn't exist.
  /// Throws [FeaturamException] for other errors.
  Future<FeatureRequest> removeVote(
    String requestId,
    String voterIdentifier,
  ) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/api/public/requests/$requestId/vote',
        data: {
          'voterIdentifier': voterIdentifier,
        },
      );

      return FeatureRequest.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e);
    }
  }

  /// Toggles a vote on a feature request.
  ///
  /// If the user has not voted, adds a vote. If already voted (409 Conflict),
  /// removes the vote instead.
  Future<FeatureRequest> toggleVote(String requestId, String voterIdentifier) async {
    try {
      return await vote(requestId, voterIdentifier);
    } on ConflictException {
      return await removeVote(requestId, voterIdentifier);
    }
  }

  /// Fetches the project configuration (branding, email settings).
  ///
  /// Returns the [ProjectConfig] for the current project.
  ///
  /// Throws [FeaturamException] if the request fails.
  Future<ProjectConfig> getConfig() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/public/config',
      );

      return ProjectConfig.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e);
    }
  }

  /// Closes the client and releases resources.
  void close() {
    _dio.close();
  }
}
