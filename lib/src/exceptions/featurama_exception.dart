import 'package:dio/dio.dart';

/// Base exception class for Featurama SDK errors.
class FeaturamException implements Exception {
  /// Creates a new [FeaturamException].
  const FeaturamException({
    required this.message,
    this.statusCode,
  });

  /// Creates a [FeaturamException] from a [DioException].
  factory FeaturamException.fromDioError(
    DioException error, {
    String? baseUrl,
  }) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (statusCode == 401) {
      // Do not echo the response body, request headers or an untrusted URL.
      final origin = Uri.tryParse(baseUrl ?? '');
      final target = origin != null &&
              (origin.scheme == 'https' || origin.scheme == 'http') &&
              origin.host.isNotEmpty &&
              origin.userInfo.isEmpty &&
              !origin.hasQuery &&
              !origin.hasFragment &&
              (origin.path.isEmpty || origin.path == '/')
          ? ' at ${origin.origin}'
          : '';
      return UnauthorizedException(
        message: 'Authentication failed$target. Check that the project SDK key '
            'was issued by this backend and has not been revoked. Configure '
            'apiKey and baseUrl as a pair. Current hosting uses '
            'https://newapi.featurama.app; legacy hosting requires an explicit '
            'https://api.featurama.app override with its matching key. '
            'The SDK does not retry another host.',
      );
    }
    if (statusCode != null && statusCode >= 300 && statusCode < 400) {
      return FeaturamException(
        message: 'The API returned a redirect. Redirects are not followed. '
            'Use the direct backend origin and a key issued by that backend.',
        statusCode: statusCode,
      );
    }

    String message;
    if (data is Map<String, dynamic>) {
      final value = data['message'] ?? data['error'];
      message = value is List
          ? value.join('; ')
          : value?.toString() ?? error.message ?? 'Unknown error occurred';
    } else if (data is String && data.isNotEmpty) {
      message = data;
    } else {
      message = error.message ?? 'Unknown error occurred';
    }

    for (final header in error.requestOptions.headers.entries) {
      if (header.key.toLowerCase() == 'x-api-key') {
        final key = header.value?.toString() ?? '';
        if (key.isNotEmpty) {
          message = message
              .replaceAll(key, '[redacted]')
              .replaceAll(Uri.encodeComponent(key), '[redacted]');
        }
      }
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 409:
        return ConflictException(message: message);
      default:
        return FeaturamException(
          message: message,
          statusCode: statusCode,
        );
    }
  }

  /// HTTP status code of the error, if available.
  final int? statusCode;

  /// Human-readable error message.
  final String message;

  @override
  String toString() {
    if (statusCode != null) {
      return 'FeaturamException: $message (status: $statusCode)';
    }
    return 'FeaturamException: $message';
  }
}

/// Correctly spelled alias, preserving the original public exception type.
typedef FeaturamaException = FeaturamException;

/// Exception thrown when input does not satisfy the API requirements.
class ValidationException extends FeaturamException {
  const ValidationException({super.message = 'Invalid request'})
      : super(statusCode: 400);
}

/// Exception thrown for ownership or moderation restrictions.
class ForbiddenException extends FeaturamException {
  const ForbiddenException({super.message = 'Forbidden'})
      : super(statusCode: 403);
}

/// Exception thrown when the API key is invalid or missing.
class UnauthorizedException extends FeaturamException {
  /// Creates a new [UnauthorizedException].
  const UnauthorizedException({
    super.message = 'Invalid or missing API key',
  }) : super(statusCode: 401);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception thrown when the requested resource is not found.
class NotFoundException extends FeaturamException {
  /// Creates a new [NotFoundException].
  const NotFoundException({
    super.message = 'Resource not found',
  }) : super(statusCode: 404);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when there is a conflict, such as duplicate vote.
class ConflictException extends FeaturamException {
  /// Creates a new [ConflictException].
  const ConflictException({
    super.message = 'Conflict: Resource already exists',
  }) : super(statusCode: 409);

  @override
  String toString() => 'ConflictException: $message';
}
