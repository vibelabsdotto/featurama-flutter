# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - Unreleased

### Release candidate updates

- Default backend is `https://newapi.featurama.app`. Legacy integrations must
  explicitly pair their existing key with `https://api.featurama.app`.
- Validate backend origins and project keys without logging credentials. SDK-owned
  web and native transports reject redirects and never try another backend.
- Built-in Cupertino detail view, submitter-only editing, discussion comments and
  comment vote toggling. Failed writes keep drafts; client/identity changes discard
  stale state and prevent follow-up writes for the previous viewer.
- Pending moderation, email policy, filtered request pagination, comment display
  batches, accessible controls and input limits in the feedback screen.
- Public comment/config models, current backend error mappings and caller-owned
  Dio support. Imports support both the Flutter UI and a standalone Dart client.
- Repository metadata points to `vibelabsdotto/featurama-flutter`. Local test-app
  uses a path dependency and is excluded from the pub archive.
- Flutter 3.22 and Dart 3.4 are the package lower bounds, verified with a clean
  web consumer. Flutter 3.47.5 / Dart 3.13.4 also pass web and native builds.

The initial API entries are retained below. This checkout remains version 1.0.0;
this verification did not publish it.

### Added

- Initial release of the Featurama Flutter SDK
- `FeaturamaClient` with full API support:
  - `getRequests()` - Paginated feature request listing
  - `createRequest()` - Create new feature requests
  - `updateRequest()` - Update existing requests
  - `vote()` - Add votes to requests
  - `removeVote()` - Remove votes from requests
- Models:
  - `FeatureRequest` - Feature request data model
  - `PaginatedResponse<T>` - Generic pagination wrapper
  - `CreateRequestDto` - DTO for creating requests
  - `UpdateRequestDto` - DTO for updating requests
  - `FeatureRequestStatus` - Enum for request status
  - `FeatureRequestSource` - Enum for request source
- Exception handling:
  - `FeaturamException` - Base exception class
  - `UnauthorizedException` - For 401 errors
  - `NotFoundException` - For 404 errors
  - `ConflictException` - For 409 errors
- Full documentation and examples
- Unit tests with mocking support
