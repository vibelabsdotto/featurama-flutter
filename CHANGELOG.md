# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

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
