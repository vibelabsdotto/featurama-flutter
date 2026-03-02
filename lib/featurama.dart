/// Flutter SDK for Featurama Feature Request Management.
///
/// This library provides a client for interacting with the Featurama API,
/// allowing you to collect and manage feature requests from your mobile app
/// users.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:featurama/featurama.dart';
///
/// final client = FeaturamaClient(
///   apiKey: 'fm_live_your_api_key_here',
///   baseUrl: 'https://your-deployment.convex.site',
/// );
///
/// // List feature requests
/// final requests = await client.getRequests();
///
/// // Create a feature request
/// final request = await client.createRequest(
///   CreateRequestDto(
///     title: 'Dark mode',
///     description: 'Please add dark mode support',
///     submitterIdentifier: 'user_123',
///   ),
/// );
///
/// // Vote on a request
/// await client.vote(request.id, 'user_456');
/// ```
library featurama;

export 'src/exceptions/featurama_exception.dart';
export 'src/featurama_client.dart';
export 'src/models/create_request_dto.dart';
export 'src/models/feature_request.dart';
export 'src/models/paginated_response.dart';
export 'src/models/update_request_dto.dart';
export 'src/ui/featurama_screen.dart';
export 'src/ui/strings/featurama_strings.dart';
