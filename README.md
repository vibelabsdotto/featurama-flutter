# Featurama Flutter SDK

The official Flutter/Dart SDK for [Featurama](https://featurama.io) - a feature request management platform for mobile app developers.

> Status: Coming soon for MVP. React Native / Expo is currently the production-ready SDK.

## Features

- Collect feature requests from your app users
- Allow users to vote on feature requests
- Update and manage requests programmatically
- Full TypeScript-style type safety with Dart's sound null safety

## Installation

Add `featurama` to your `pubspec.yaml`:

```yaml
dependencies:
  featurama: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:featurama/featurama.dart';

// Initialize the client with your API key and Convex deployment URL
final client = FeaturamaClient(
  apiKey: 'fm_live_your_api_key_here',
  baseUrl: 'https://your-deployment.convex.site',
);

// List feature requests
final response = await client.getRequests();
for (final request in response.items) {
  print('${request.title} - ${request.voteCount} votes');
}

// Create a feature request
final newRequest = await client.createRequest(
  CreateRequestDto(
    title: 'Dark mode support',
    description: 'Please add dark mode to reduce eye strain',
    submitterIdentifier: 'user_123',
  ),
);

// Vote on a request
await client.vote(newRequest.id, 'user_456');

// Remove a vote
await client.removeVote(newRequest.id, 'user_456');

// Clean up
client.close();
```

## API Reference

### FeaturamaClient

The main client for interacting with the Featurama API.

#### Constructor

```dart
FeaturamaClient({
  required String apiKey,
  required String baseUrl,
  Dio? dio,
})
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `apiKey` | `String` | Your Featurama API key (format: `fm_live_xxx`) |
| `baseUrl` | `String` | Your Convex deployment URL (e.g., `https://your-deployment.convex.site`) |
| `dio` | `Dio?` | Custom Dio instance (optional, for testing) |

#### Methods

##### `getRequests`

Retrieves a paginated list of feature requests.

```dart
Future<PaginatedResponse<FeatureRequest>> getRequests({
  int page = 1,
  int pageSize = 20,
})
```

##### `createRequest`

Creates a new feature request.

```dart
Future<FeatureRequest> createRequest(CreateRequestDto dto)
```

##### `updateRequest`

Updates an existing feature request. Only the original submitter can update.

```dart
Future<FeatureRequest> updateRequest(
  String id,
  UpdateRequestDto dto,
  String submitterIdentifier,
)
```

##### `vote`

Adds a vote to a feature request.

```dart
Future<FeatureRequest> vote(String requestId, String voterIdentifier)
```

##### `removeVote`

Removes a vote from a feature request.

```dart
Future<FeatureRequest> removeVote(String requestId, String voterIdentifier)
```

##### `close`

Closes the client and releases resources.

```dart
void close()
```

### Models

#### FeatureRequest

Represents a feature request.

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier |
| `projectId` | `String` | Project ID |
| `title` | `String` | Request title |
| `description` | `String` | Request description |
| `status` | `FeatureRequestStatus` | Current status |
| `source` | `FeatureRequestSource` | Source (SDK or Dashboard) |
| `voteCount` | `int` | Number of votes |
| `submitterIdentifier` | `String` | Submitter ID |
| `createdAt` | `DateTime` | Creation timestamp |

#### FeatureRequestStatus

```dart
enum FeatureRequestStatus {
  requested,   // Initial state
  roadmap,     // Added to roadmap
  inProgress,  // Currently being worked on
  done,        // Completed
  declined,    // Declined
}
```

#### FeatureRequestSource

```dart
enum FeatureRequestSource {
  sdk,        // Created via SDK
  dashboard,  // Created from dashboard
}
```

#### PaginatedResponse<T>

Generic pagination wrapper.

| Property | Type | Description |
|----------|------|-------------|
| `items` | `List<T>` | Items in current page |
| `totalCount` | `int` | Total items across all pages |
| `page` | `int` | Current page (1-indexed) |
| `pageSize` | `int` | Items per page |
| `totalPages` | `int` | Total number of pages |
| `hasNextPage` | `bool` | Whether there's a next page |
| `hasPreviousPage` | `bool` | Whether there's a previous page |

### DTOs

#### CreateRequestDto

```dart
CreateRequestDto({
  required String title,
  required String description,
  required String submitterIdentifier,
})
```

#### UpdateRequestDto

```dart
UpdateRequestDto({
  required String title,
  required String description,
})
```

## Error Handling

The SDK throws typed exceptions for different error scenarios:

```dart
try {
  await client.vote(requestId, 'user_123');
} on UnauthorizedException catch (e) {
  // Invalid or missing API key (401)
  print('Auth error: ${e.message}');
} on ConflictException catch (e) {
  // User already voted (409)
  print('Already voted: ${e.message}');
} on NotFoundException catch (e) {
  // Request not found (404)
  print('Not found: ${e.message}');
} on FeaturamException catch (e) {
  // Other API errors
  print('Error ${e.statusCode}: ${e.message}');
}
```

### Exception Types

| Exception | HTTP Status | Description |
|-----------|-------------|-------------|
| `UnauthorizedException` | 401 | Invalid or missing API key |
| `NotFoundException` | 404 | Resource not found |
| `ConflictException` | 409 | Conflict (e.g., duplicate vote) |
| `FeaturamException` | Other | Base exception for all API errors |

## Best Practices

### User Identification

Use a consistent, unique identifier for each user:

```dart
// Good: Consistent user ID
await client.createRequest(
  CreateRequestDto(
    title: 'Feature',
    description: 'Description',
    submitterIdentifier: user.id, // e.g., 'user_abc123'
  ),
);

// Also good: Device ID for anonymous users
final deviceId = await getDeviceId();
await client.vote(requestId, deviceId);
```

### Resource Management

Always close the client when done:

```dart
final client = FeaturamaClient(apiKey: apiKey, baseUrl: baseUrl);

try {
  // Use the client...
} finally {
  client.close();
}
```

### Pagination

Handle pagination for large result sets:

```dart
Future<List<FeatureRequest>> loadAllRequests() async {
  final allRequests = <FeatureRequest>[];
  var page = 1;

  while (true) {
    final response = await client.getRequests(page: page);
    allRequests.addAll(response.items);

    if (!response.hasNextPage) break;
    page++;
  }

  return allRequests;
}
```

## License

Apache 2.0 - see [LICENSE](LICENSE) for details.
