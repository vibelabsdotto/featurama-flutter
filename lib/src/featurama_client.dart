import 'package:dio/dio.dart';
import 'package:dio_compatibility_layer/dio_compatibility_layer.dart';
import 'package:http/http.dart' as http;

import 'exceptions/featurama_exception.dart';
import 'models/create_request_dto.dart';
import 'models/comment.dart';
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
///   apiKey: 'fm_li...re',
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
  /// Current hosted API origin. Keys are specific to their issuing backend.
  static const defaultBaseUrl = 'https://newapi.featurama.app';

  /// Creates a new [FeaturamaClient].
  ///
  /// The [apiKey] must be a nonempty, whitespace-free project SDK key.
  /// No prefix or length is imposed; the issuing backend validates the key.
  ///
  /// The [baseUrl] is an HTTPS backend origin without an API path, credentials,
  /// query or fragment. HTTP is allowed only for loopback development. For a
  /// legacy key, explicitly use `https://api.featurama.app`. Changing the origin
  /// does not migrate keys or project data. Invalid input throws [ArgumentError]
  /// without including the supplied value.
  ///
  /// An optional [dio] remains caller-owned and is never reconfigured. Its
  /// adapters and interceptors must honor `followRedirects: false`, must not
  /// retarget requests and must not log the `X-Api-Key` header. Dio's default
  /// web adapter cannot block redirects; use a Fetch-backed adapter instead.
  FeaturamaClient({
    required String apiKey,
    String baseUrl = defaultBaseUrl,
    Dio? dio,
  })  : _apiKey = validateApiKey(apiKey),
        _baseUrl = validateBaseUrl(baseUrl),
        _dio = dio ?? _createDio(),
        _ownsDio = dio == null;

  /// Validates a project key without changing it or including it in errors.
  static String validateApiKey(String apiKey) {
    if (apiKey.isEmpty ||
        apiKey.codeUnits.any((code) => code < 0x21 || code > 0x7e)) {
      throw ArgumentError(
        'apiKey must be a nonempty project SDK key without whitespace or '
        'control characters. Copy it from the selected backend.',
      );
    }
    return apiKey;
  }

  /// Validates a backend origin, accepting an optional trailing slash.
  static String validateBaseUrl(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    if (!RegExp(r'^https?://[^/?#\\%@]+/?$').hasMatch(baseUrl) ||
        baseUrl.codeUnits.any((code) => code <= 0x20 || code >= 0x7f) ||
        uri == null ||
        !uri.hasAuthority ||
        baseUrl.endsWith(':') ||
        baseUrl.endsWith(':/') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.port < 1 ||
        uri.port > 65535) {
      throw ArgumentError(
        'baseUrl must be a backend origin such as https://newapi.featurama.app, '
        'without credentials, an API path, query or fragment.',
      );
    }
    if (uri.scheme == 'http' &&
        uri.host != 'localhost' &&
        uri.host != '127.0.0.1' &&
        uri.host != '::1') {
      throw ArgumentError(
        'baseUrl must use HTTPS. HTTP is allowed only for localhost, '
        '127.0.0.1 or [::1] development servers.',
      );
    }
    return uri.origin;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    // XMLHttpRequest ignores followRedirects. http >=1.3 uses Fetch with
    // redirect: 'error', so the browser never forwards the key on redirects.
    if (const bool.fromEnvironment('dart.library.js_interop')) {
      dio.httpClientAdapter = ConversionLayerAdapter(http.Client());
    }
    return dio;
  }

  final Dio _dio;
  final bool _ownsDio;
  final String _apiKey;
  final String _baseUrl;
  bool _closed = false;

  // Never mutate an injected transport: multiple projects may share it.
  String _url(String path) {
    if (_closed) throw StateError('FeaturamaClient is closed');
    return '$_baseUrl$path';
  }

  Options get _options => Options(
        headers: {'X-Api-Key': _apiKey, 'Content-Type': 'application/json'},
        responseType: ResponseType.json,
        // Keep SDK status handling reliable even with custom Dio defaults.
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
        followRedirects: false,
        maxRedirects: 0,
      );

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
    String? submitterIdentifier,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _url('/api/public/requests'),
        options: _options,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (filter != null) 'filter': filter,
          if (submitterIdentifier != null)
            'submitterIdentifier': submitterIdentifier,
        },
      );

      return PaginatedResponse.fromJson(
        response.data!,
        FeatureRequest.fromJson,
      );
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e, baseUrl: _baseUrl);
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
        _url('/api/public/requests'),
        options: _options,
        data: dto.toJson(),
      );

      return FeatureRequest.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e, baseUrl: _baseUrl);
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
  /// Throws [ForbiddenException] if the submitter does not match.
  /// Throws [FeaturamException] for other errors.
  Future<FeatureRequest> updateRequest(
    String id,
    UpdateRequestDto dto,
    String submitterIdentifier,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        _url('/api/public/requests/${Uri.encodeComponent(id)}'),
        options: _options,
        data: dto.toJson(),
        queryParameters: {
          'submitterIdentifier': submitterIdentifier,
        },
      );

      return FeatureRequest.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e, baseUrl: _baseUrl);
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
        _url('/api/public/requests/${Uri.encodeComponent(requestId)}/vote'),
        options: _options,
        data: {
          'voterIdentifier': voterIdentifier,
        },
      );

      return FeatureRequest.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e, baseUrl: _baseUrl);
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
        _url('/api/public/requests/${Uri.encodeComponent(requestId)}/vote'),
        options: _options,
        data: {
          'voterIdentifier': voterIdentifier,
        },
      );

      return FeatureRequest.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e, baseUrl: _baseUrl);
    }
  }

  /// Toggles a vote on a feature request.
  ///
  /// If the user has not voted, adds a vote. If already voted (409 Conflict),
  /// removes the vote instead.
  Future<FeatureRequest> toggleVote(
      String requestId, String voterIdentifier) async {
    try {
      return await vote(requestId, voterIdentifier);
    } on ConflictException {
      return removeVote(requestId, voterIdentifier);
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
        _url('/api/public/config'),
        options: _options,
      );

      return ProjectConfig.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e, baseUrl: _baseUrl);
    }
  }

  /// Lists discussion comments in chronological order.
  Future<List<Comment>> getComments(String requestId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        _url('/api/public/requests/${Uri.encodeComponent(requestId)}/comments'),
        options: _options,
      );
      return response.data!
          .map((item) => Comment.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e, baseUrl: _baseUrl);
    }
  }

  /// Adds a comment. Pending requests accept comments only from their submitter.
  Future<Comment> addComment(
    String requestId, {
    required String content,
    required String authorIdentifier,
    String? authorName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _url('/api/public/requests/${Uri.encodeComponent(requestId)}/comments'),
        options: _options,
        data: {
          'content': content,
          'authorIdentifier': authorIdentifier,
          if (authorName != null) 'authorName': authorName,
        },
      );
      return Comment.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e, baseUrl: _baseUrl);
    }
  }

  /// Adds a vote to a comment; duplicate votes throw [ConflictException].
  Future<Comment> voteComment(
    String requestId,
    String commentId,
    String voterIdentifier,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _url(
            '/api/public/requests/${Uri.encodeComponent(requestId)}/comments/${Uri.encodeComponent(commentId)}/vote'),
        options: _options,
        data: {'voterIdentifier': voterIdentifier},
      );
      return Comment.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e, baseUrl: _baseUrl);
    }
  }

  /// Removes a comment vote; missing votes throw [NotFoundException].
  Future<Comment> removeCommentVote(
    String requestId,
    String commentId,
    String voterIdentifier,
  ) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        _url(
            '/api/public/requests/${Uri.encodeComponent(requestId)}/comments/${Uri.encodeComponent(commentId)}/vote'),
        options: _options,
        data: {'voterIdentifier': voterIdentifier},
      );
      return Comment.fromJson(response.data!);
    } on DioException catch (e) {
      throw FeaturamException.fromDioError(e, baseUrl: _baseUrl);
    }
  }

  /// Adds a comment vote, or removes it when the API reports a duplicate.
  Future<Comment> toggleCommentVote(
    String requestId,
    String commentId,
    String voterIdentifier,
  ) async {
    try {
      return await voteComment(requestId, commentId, voterIdentifier);
    } on ConflictException {
      return removeCommentVote(requestId, commentId, voterIdentifier);
    }
  }

  /// Closes this client. An injected Dio remains owned by the caller.
  void close() {
    if (_closed) return;
    _closed = true;
    if (_ownsDio) _dio.close();
  }
}
