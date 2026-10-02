# Featurama Flutter SDK

Flutter SDK for [Featurama](https://featurama.app). Collect feature requests and discussion from your app.

The client and feedback screen default to `https://newapi.featurama.app`.
Configure the project SDK key and its issuing backend origin together. For a
legacy project, set `baseUrl: 'https://api.featurama.app'` explicitly and keep
using that backend's key. Changing the default does not migrate keys or data.

## Current backend behavior

- New requests are pending moderation and include the submitter's first vote.
- Pass `submitterIdentifier` to `getRequests` to see that user's pending requests
  and receive `hasVoted`. Other users see approved requests only.
- Pending requests cannot be voted on. Owner approval happens in the dashboard,
  not through a shipped project API key.
- `filter` accepts `new`, `planned`, `in_progress`, and `done`.
- `CreateRequestDto` accepts optional `email` and caller-provided `deviceInfo`.
  Read `getConfig().emailCollection` before submission. Required email policy is
  enforced by the server. The SDK does not collect device metadata automatically.
- `FeatureRequest` includes `isApproved`, `hasVoted`, and `commentCount`. Public
  list/vote responses omit private email/device metadata and anonymize identifiers.
- A stable submitter identifier is not secure user authentication. Keep dashboard
  credentials out of shipped apps; the API key is project-scoped public SDK access.

## Feedback screen and runnable app

```dart
final client = FeaturamaClient(
  apiKey: projectKey,
  baseUrl: 'https://newapi.featurama.app',
);
// Keep this client in State and close it from dispose(), not on each build.
FeaturamaScreen(
  client: client,
  submitterIdentifier: currentUserId, // Optional; defaults to persisted device ID.
  onClose: () => Navigator.of(context).pop(),
);
```

The screen includes filters, explicit refresh, request pagination, pending badges,
request voting and a built-in detail view. Open **View details** to read the full
request, refresh comments, write a comment or toggle a comment vote. The original
submitter sees **Edit request**, including for a pending request. Other viewers
never receive the edit action. These checks supplement the server's ownership
rules; a caller-supplied identifier is not secure authentication.

Pending requests accept comments from their submitter only. The built-in UI keeps
request and comment voting disabled until approval. Comments are fetched as one
array by the current API and displayed in batches of 20 with **Load more**. Request
pagination is server-side. Changing filters, client or identity invalidates old
results. Switching identity or client discards the previous user's form state.

Failed edits and comments retain drafts. Duplicate submissions and back navigation
are disabled during writes. Network failures are not retried automatically: a
server may have committed before its response was lost. Refresh the discussion
before manually resending an uncertain comment. Drafts are in-memory only and
are discarded when leaving their view. Title/description fields require content
and allow 200/5000 characters; comments allow 2000. These are built-in UI limits.

Email policy, accessible field labels, large-text layouts and retryable errors
are included. Override `FeaturamaStrings` to localize the controls and messages.
Comment vote responses do not expose viewer vote state, so the control says
**Toggle comment vote** rather than claiming an unknown selection.

The existing test app now resolves this checkout directly:

```sh
cd test-app
flutter pub get
flutter run -d web-server --web-port 3041
```

Open the reported URL and enter a project key in Settings. The app defaults to
`https://newapi.featurama.app`. For local development use `http://localhost:3000`
in Settings, or `--dart-define=FEATURAMA_BASE_URL=http://localhost:3000`.
`FEATURAMA_API_KEY` is an optional build-time define, but it becomes part of the
client bundle. Never use an owner credential there. Settings validates both
fields before saving. It does not silently trim or repair malformed values.
The runnable test app is available in the repository, not the pub package.

For a Dart client example, import `package:featurama/client.dart` rather than the
UI library. After `flutter pub get`, run `dart run example/example.dart` with
`FEATURAMA_API_KEY` and optional `FEATURAMA_BASE_URL` in the environment.
It only reads by default; `--create` opts into creating one pending request.
Set `FEATURAMA_EMAIL` when that project requires email collection.

## Comments and votes

```dart
final comments = await client.getComments(requestId);
final comment = await client.addComment(
  requestId,
  content: 'This would help our workflow.',
  authorIdentifier: currentUserId,
  authorName: 'App user',
);
await client.voteComment(requestId, comment.id, currentUserId);
await client.removeCommentVote(requestId, comment.id, currentUserId);
// Duplicate votes produce 409; toggle helpers remove only on that conflict.
await client.toggleCommentVote(requestId, comment.id, currentUserId);
await client.toggleVote(requestId, currentUserId);
```

`getConfig` returns exported `ProjectConfig` and `BrandingConfig` models.
`ValidationException` maps HTTP 400, `ForbiddenException` maps 403, and the
existing 401/404/409 types are unchanged. `FeaturamaException` is an alias for
legacy `FeaturamException`. Other HTTP and transport failures retain the base
exception and optional status code.

## Development checks

```sh
flutter pub get
flutter analyze
flutter test
cd test-app
flutter build web --release
```

This checkout was checked with Flutter 3.47.5 and Dart 3.13.4 against an isolated
current-backend project. Browser checks exercised details, owner editing, comment
creation, comment votes, validation and error recovery. Scratch native consumers
compile for iOS Simulator and Android arm64. Compilation does not imply physical
device, release-signing, store distribution or publication verification.


## Features

- Collect feature requests from your app users
- Allow users to vote on feature requests
- Update and manage requests programmatically
- Typed Dart models with sound null safety

## Installation

Requires Flutter 3.22 or later and Dart 3.4 or later. The Fetch-backed web
transport requires `http >=1.3.0` to reject redirects before forwarding a key.
The main verification toolchain is Flutter 3.47.5 and Dart 3.13.4. A clean
consumer also resolves, analyzes and compiles the web UI with the declared
minimum Flutter 3.22.0 and Dart 3.4.0. Minimum-version native builds are not implied.

This checkout is an unpublished 1.0.0 release candidate. Use the path dependency
below now. After publication, hosted consumers can use:

```yaml
dependencies:
  featurama: ^1.0.0
```

Then run:

```bash
flutter pub get
```

For an unreleased checkout, use a path dependency instead of assuming the same
changes are already on pub.dev:

```yaml
dependencies:
  featurama:
    path: /absolute/path/to/featurama-flutter
```

Source and issue tracker: [vibelabsdotto/featurama-flutter](https://github.com/vibelabsdotto/featurama-flutter).

### Package readiness

Run `flutter pub publish --dry-run` to inspect the files and validation results
without publishing. `.pubignore` excludes the runnable test app, local logs,
build output and agent reports. Keep the library, example, license and changelog
in the package. A dirty checkout produces a pub warning; do not reset unrelated
work to suppress it. Before a release, review the version and changelog and
repeat analysis from a clean consumer with a path dependency. A dry run does
not publish the package or prove a hosted version contains these changes.

## Quick Start

```dart
import 'package:featurama/featurama.dart';

// Initialize the client with your API key.
final client = FeaturamaClient(
  apiKey: 'fm_live_your_api_key_here',
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

// New requests are pending. Vote only after dashboard approval.
final approved = response.items.where((request) => request.isApproved);
if (approved.isNotEmpty) {
  await client.vote(approved.first.id, 'user_456');
  await client.removeVote(approved.first.id, 'user_456');
}

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
  String baseUrl = FeaturamaClient.defaultBaseUrl,
  Dio? dio,
})
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `apiKey` | `String` | Project SDK key issued by the selected backend. Nonempty printable ASCII without whitespace; no fixed prefix or length is imposed. |
| `baseUrl` | `String` | Backend origin. Defaults to `https://newapi.featurama.app`. Explicit legacy override: `https://api.featurama.app`. |
| `dio` | `Dio?` | Optional shared transport; defaults are not mutated and the caller retains ownership |

### Backend configuration and authentication

`baseUrl` accepts an HTTPS origin with an optional trailing slash. Do not append
`/api` or `/api/public`; the SDK adds the public API paths. Credentials, query
strings, fragments and whitespace are rejected. HTTP is allowed only for
`localhost`, `127.0.0.1` and `[::1]` development servers. Invalid configuration
throws `ArgumentError` without including the supplied key or URL.

An HTTP 401 reports the selected origin and asks you to check the key/origin
pair. Confirm the key was issued for that backend and has not been revoked.
Do not probe other hosts with the same key. The SDK never retries another
backend and does not infer a host from the key prefix.

SDK-owned transports block redirects, including on web via Fetch. Browser
redirect failures may appear as transport errors because Fetch does not expose
the redirect response. When injecting `Dio`, retain these protections in the
adapter and interceptors. Do not use Dio's default XMLHttpRequest web adapter,
which ignores `followRedirects`. A compatible web setup is:

```dart
import 'package:dio/dio.dart';
import 'package:dio_compatibility_layer/dio_compatibility_layer.dart';
import 'package:http/http.dart' as http;

final dio = Dio()
  ..httpClientAdapter = ConversionLayerAdapter(http.Client());
final client = FeaturamaClient(apiKey: projectSdkKey, dio: dio);
// client.close() does not close an injected Dio. Close dio yourself when done.
```

Declare `dio`, `dio_compatibility_layer` and `http: ^1.3.0` as direct dependencies
if you use this setup. Do not install interceptors that change the destination,
retry a different origin, or log `X-Api-Key`. Custom transports are trusted code.

#### Methods

##### `getRequests`

Retrieves a paginated list of feature requests.

```dart
Future<PaginatedResponse<FeatureRequest>> getRequests({
  int page = 1,
  int pageSize = 20,
  String? filter,
  String? submitterIdentifier,
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
