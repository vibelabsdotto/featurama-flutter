import 'package:dio/dio.dart';

/// Base exception class for Featurama SDK errors.
class FeaturamException implements Exception {
  /// Creates a new [FeaturamException].
  const FeaturamException({
    required this.message,
    this.statusCode,
  });

  /// Creates a [FeaturamException] from a [DioException].
  factory FeaturamException.fromDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message;
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          error.message ??
          'Unknown error occurred';
    } else if (data is String && data.isNotEmpty) {
      message = data;
    } else {
      message = error.message ?? 'Unknown error occurred';
    }

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message);
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

/// Exception thrown when the API key is invalid or missing.
class UnauthorizedException extends FeaturamException {
  /// Creates a new [UnauthorizedException].
  const UnauthorizedException({
    String message = 'Invalid or missing API key',
  }) : super(message: message, statusCode: 401);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception thrown when the requested resource is not found.
class NotFoundException extends FeaturamException {
  /// Creates a new [NotFoundException].
  const NotFoundException({
    String message = 'Resource not found',
  }) : super(message: message, statusCode: 404);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when there is a conflict, such as duplicate vote.
class ConflictException extends FeaturamException {
  /// Creates a new [ConflictException].
  const ConflictException({
    String message = 'Conflict: Resource already exists',
  }) : super(message: message, statusCode: 409);

  @override
  String toString() => 'ConflictException: $message';
}
