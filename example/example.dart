// ignore_for_file: avoid_print

import 'dart:io';
import 'package:featurama/client.dart';

Future<void> main(List<String> args) async {
  if ((Platform.environment['FEATURAMA_API_KEY'] ?? '').isEmpty) {
    stderr.writeln('Set FEATURAMA_API_KEY before running the example.');
    exitCode = 64;
    return;
  }
  // Keep the key paired with its issuing backend. For a legacy project, set
  // FEATURAMA_BASE_URL=https://api.featurama.app explicitly.
  late final FeaturamaClient client;
  try {
    client = FeaturamaClient(
      apiKey: Platform.environment['FEATURAMA_API_KEY'] ?? '',
      baseUrl: Platform.environment['FEATURAMA_BASE_URL'] ??
          FeaturamaClient.defaultBaseUrl,
    );
  } on ArgumentError catch (error) {
    stderr.writeln('Configuration error: ${error.message}');
    exitCode = 64;
    return;
  }

  try {
    // Example 1: List feature requests with pagination
    print('--- Fetching feature requests ---');
    final response = await client.getRequests(page: 1, pageSize: 10);

    print('Total requests: ${response.totalCount}');
    print('Current page: ${response.page}/${response.totalPages}');
    print('Has next page: ${response.hasNextPage}');

    for (final request in response.items) {
      print('  - ${request.title} (${request.voteCount} votes)');
    }

    // Creation is opt-in. Read-only listing is safe to run repeatedly.
    if (!args.contains('--create')) return;

    // Example 2: Create a new feature request
    print('\n--- Creating a feature request ---');
    final newRequest = await client.createRequest(
      CreateRequestDto(
        title: 'Dark mode support',
        description: 'Please add a dark mode option to reduce eye strain '
            'when using the app at night.',
        submitterIdentifier: 'user_123',
        email: Platform.environment['FEATURAMA_EMAIL'],
      ),
    );

    print('Created request: ${newRequest.title}');
    print('Request ID: ${newRequest.id}');
    print('Status: ${newRequest.status.value}');

    // New requests require owner approval before voting.
    if (!newRequest.isApproved) {
      print(
          'Pending approval. View it by listing with its submitter identifier.');
      return;
    }

    // Example 3: Vote on a feature request
    print('\n--- Voting on a request ---');
    final votedRequest = await client.vote(newRequest.id, 'user_456');
    print('Vote count after voting: ${votedRequest.voteCount}');

    // Example 4: Update a feature request
    print('\n--- Updating a request ---');
    final updatedRequest = await client.updateRequest(
      newRequest.id,
      const UpdateRequestDto(
        title: 'Dark mode support (Updated)',
        description: 'Please add a dark mode option with customizable colors.',
      ),
      'user_123', // Must match the original submitter
    );

    print('Updated title: ${updatedRequest.title}');
    print('Updated description: ${updatedRequest.description}');

    // Example 5: Remove a vote
    print('\n--- Removing a vote ---');
    final unvotedRequest = await client.removeVote(newRequest.id, 'user_456');
    print('Vote count after removing vote: ${unvotedRequest.voteCount}');
  } on UnauthorizedException catch (e) {
    // Check the key/origin pair. Never try the same key on another host.
    stderr.writeln('Authentication error: ${e.message}');
    exitCode = 1;
  } on ConflictException catch (e) {
    // Handle duplicate vote
    print('Conflict error: ${e.message}');
  } on NotFoundException catch (e) {
    // Handle resource not found
    print('Not found error: ${e.message}');
  } on FeaturamException catch (e) {
    // Handle other API errors
    print('API error: ${e.message} (status: ${e.statusCode})');
  } finally {
    // Clean up resources
    client.close();
  }
}

/// Example of integrating Featurama in a Flutter app.
///
/// This shows how you might use the SDK in a real Flutter application
/// with a state management solution.
class FeatureRequestManager {
  FeatureRequestManager({required this.apiKey, required this.baseUrl})
      : _client = FeaturamaClient(apiKey: apiKey, baseUrl: baseUrl);

  final String apiKey;
  final String baseUrl;
  final FeaturamaClient _client;

  String? _userId;

  /// Set the current user ID for voting and request submission.
  void setUserId(String userId) {
    _userId = userId;
  }

  /// Load feature requests for display in a list.
  Future<List<FeatureRequest>> loadRequests({int page = 1}) async {
    final response = await _client.getRequests(
      page: page,
      pageSize: 20,
      submitterIdentifier: _userId,
    );
    return response.items;
  }

  /// Submit a new feature request from the current user.
  Future<FeatureRequest> submitRequest({
    required String title,
    required String description,
  }) async {
    if (_userId == null) {
      throw StateError('User ID must be set before submitting requests');
    }

    return _client.createRequest(
      CreateRequestDto(
        title: title,
        description: description,
        submitterIdentifier: _userId!,
      ),
    );
  }

  /// Toggle vote on a feature request.
  Future<FeatureRequest> toggleVote(
    FeatureRequest request, {
    required bool hasVoted,
  }) async {
    if (_userId == null) {
      throw StateError('User ID must be set before voting');
    }

    if (hasVoted) {
      return _client.removeVote(request.id, _userId!);
    } else {
      return _client.vote(request.id, _userId!);
    }
  }

  /// Clean up resources.
  void dispose() {
    _client.close();
  }
}
