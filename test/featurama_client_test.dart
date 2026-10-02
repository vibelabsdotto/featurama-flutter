import 'package:dio/dio.dart';
import 'package:featurama/featurama.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateMocks([Dio])
import 'featurama_client_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late FeaturamaClient client;

  setUp(() {
    mockDio = MockDio();
    when(mockDio.options).thenReturn(BaseOptions());
    client = FeaturamaClient(
      apiKey: 'fm_live_test_key',
      baseUrl: 'https://api.example.test',
      dio: mockDio,
    );
  });

  group('FeaturamaClient', () {
    test('preserves injected transport defaults', () {
      final options = BaseOptions();
      when(mockDio.options).thenReturn(options);

      FeaturamaClient(
        apiKey: 'fm_live_test_key',
        dio: mockDio,
      );

      expect(options.baseUrl, isEmpty);
      expect(options.headers.containsKey('X-Api-Key'), isFalse);
      expect(FeaturamaClient.defaultBaseUrl, 'https://newapi.featurama.app');
    });

    group('getRequests', () {
      test('returns paginated response on success', () async {
        when(mockDio.get<Map<String, dynamic>>(
          'https://api.example.test/api/public/requests',
          options: anyNamed('options'),
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
              data: {
                'items': [
                  {
                    'id': '123',
                    'projectId': 'proj_1',
                    'title': 'Test Request',
                    'description': 'Test description',
                    'status': 'Requested',
                    'source': 'SDK',
                    'voteCount': 5,
                    'submitterIdentifier': 'user_1',
                    'createdAt': '2024-01-15T10:00:00Z',
                  }
                ],
                'totalCount': 1,
                'page': 1,
                'pageSize': 20,
              },
              statusCode: 200,
              requestOptions: RequestOptions(
                  path: 'https://api.example.test/api/public/requests'),
            ));

        final response = await client.getRequests();

        expect(response.items, hasLength(1));
        expect(response.items[0].title, equals('Test Request'));
        expect(response.totalCount, equals(1));
        expect(response.page, equals(1));
      });

      test('throws UnauthorizedException on 401', () async {
        when(mockDio.get<Map<String, dynamic>>(
          'https://api.example.test/api/public/requests',
          options: anyNamed('options'),
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            data: {'message': 'Invalid API key'},
            requestOptions: RequestOptions(
                path: 'https://api.example.test/api/public/requests'),
          ),
          requestOptions: RequestOptions(
              path: 'https://api.example.test/api/public/requests'),
        ));

        expect(
          () => client.getRequests(),
          throwsA(isA<UnauthorizedException>()),
        );
      });
    });

    group('createRequest', () {
      test('creates request and returns FeatureRequest', () async {
        when(mockDio.post<Map<String, dynamic>>(
          'https://api.example.test/api/public/requests',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response(
              data: {
                'id': '456',
                'projectId': 'proj_1',
                'title': 'New Feature',
                'description': 'Feature description',
                'status': 'Requested',
                'source': 'SDK',
                'voteCount': 0,
                'submitterIdentifier': 'user_2',
                'createdAt': '2024-01-15T11:00:00Z',
              },
              statusCode: 201,
              requestOptions: RequestOptions(
                  path: 'https://api.example.test/api/public/requests'),
            ));

        final request = await client.createRequest(
          const CreateRequestDto(
            title: 'New Feature',
            description: 'Feature description',
            submitterIdentifier: 'user_2',
          ),
        );

        expect(request.id, equals('456'));
        expect(request.title, equals('New Feature'));
        expect(request.voteCount, equals(0));
      });
    });

    group('updateRequest', () {
      test('updates request and returns FeatureRequest', () async {
        when(mockDio.put<Map<String, dynamic>>(
          'https://api.example.test/api/public/requests/123',
          data: anyNamed('data'),
          options: anyNamed('options'),
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
              data: {
                'id': '123',
                'projectId': 'proj_1',
                'title': 'Updated Title',
                'description': 'Updated description',
                'status': 'Requested',
                'source': 'SDK',
                'voteCount': 5,
                'submitterIdentifier': 'user_1',
                'createdAt': '2024-01-15T10:00:00Z',
              },
              statusCode: 200,
              requestOptions: RequestOptions(
                  path: 'https://api.example.test/api/public/requests/123'),
            ));

        final request = await client.updateRequest(
          '123',
          const UpdateRequestDto(
            title: 'Updated Title',
            description: 'Updated description',
          ),
          'user_1',
        );

        expect(request.title, equals('Updated Title'));
        expect(request.description, equals('Updated description'));
      });

      test('throws NotFoundException on 404', () async {
        when(mockDio.put<Map<String, dynamic>>(
          'https://api.example.test/api/public/requests/invalid',
          data: anyNamed('data'),
          options: anyNamed('options'),
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            data: {'message': 'Request not found'},
            requestOptions: RequestOptions(
                path: 'https://api.example.test/api/public/requests/invalid'),
          ),
          requestOptions: RequestOptions(
              path: 'https://api.example.test/api/public/requests/invalid'),
        ));

        expect(
          () => client.updateRequest(
            'invalid',
            const UpdateRequestDto(title: 'Test', description: 'Test'),
            'user_1',
          ),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('vote', () {
      test('adds vote and returns updated FeatureRequest', () async {
        when(mockDio.post<Map<String, dynamic>>(
          'https://api.example.test/api/public/requests/123/vote',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response(
              data: {
                'id': '123',
                'projectId': 'proj_1',
                'title': 'Test Request',
                'description': 'Test description',
                'status': 'Requested',
                'source': 'SDK',
                'voteCount': 6,
                'submitterIdentifier': 'user_1',
                'createdAt': '2024-01-15T10:00:00Z',
              },
              statusCode: 200,
              requestOptions: RequestOptions(
                  path:
                      'https://api.example.test/api/public/requests/123/vote'),
            ));

        final request = await client.vote('123', 'user_3');

        expect(request.voteCount, equals(6));
      });

      test('throws ConflictException on duplicate vote', () async {
        when(mockDio.post<Map<String, dynamic>>(
          'https://api.example.test/api/public/requests/123/vote',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 409,
            data: {'message': 'Already voted'},
            requestOptions: RequestOptions(
                path: 'https://api.example.test/api/public/requests/123/vote'),
          ),
          requestOptions: RequestOptions(
              path: 'https://api.example.test/api/public/requests/123/vote'),
        ));

        expect(
          () => client.vote('123', 'user_1'),
          throwsA(isA<ConflictException>()),
        );
      });
    });

    group('removeVote', () {
      test('removes vote and returns updated FeatureRequest', () async {
        when(mockDio.delete<Map<String, dynamic>>(
          'https://api.example.test/api/public/requests/123/vote',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response(
              data: {
                'id': '123',
                'projectId': 'proj_1',
                'title': 'Test Request',
                'description': 'Test description',
                'status': 'Requested',
                'source': 'SDK',
                'voteCount': 4,
                'submitterIdentifier': 'user_1',
                'createdAt': '2024-01-15T10:00:00Z',
              },
              statusCode: 200,
              requestOptions: RequestOptions(
                  path:
                      'https://api.example.test/api/public/requests/123/vote'),
            ));

        final request = await client.removeVote('123', 'user_3');

        expect(request.voteCount, equals(4));
      });
    });
  });

  group('FeatureRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'abc123',
        'projectId': 'proj_1',
        'title': 'Test Title',
        'description': 'Test Description',
        'status': 'InProgress',
        'source': 'Dashboard',
        'voteCount': 10,
        'submitterIdentifier': 'user_1',
        'createdAt': '2024-01-15T12:00:00Z',
      };

      final request = FeatureRequest.fromJson(json);

      expect(request.id, equals('abc123'));
      expect(request.title, equals('Test Title'));
      expect(request.status, equals(FeatureRequestStatus.inProgress));
      expect(request.source, equals(FeatureRequestSource.dashboard));
      expect(request.voteCount, equals(10));
    });

    test('toJson serializes correctly', () {
      final request = FeatureRequest(
        id: 'abc123',
        projectId: 'proj_1',
        title: 'Test Title',
        description: 'Test Description',
        status: FeatureRequestStatus.done,
        source: FeatureRequestSource.sdk,
        voteCount: 5,
        submitterIdentifier: 'user_1',
        createdAt: DateTime.utc(2024, 1, 15, 12, 0, 0),
      );

      final json = request.toJson();

      expect(json['id'], equals('abc123'));
      expect(json['status'], equals('Done'));
      expect(json['source'], equals('SDK'));
    });
  });

  group('PaginatedResponse', () {
    test('calculates totalPages correctly', () {
      const response = PaginatedResponse<String>(
        items: ['a', 'b', 'c'],
        totalCount: 25,
        page: 1,
        pageSize: 10,
      );

      expect(response.totalPages, equals(3));
      expect(response.hasNextPage, isTrue);
      expect(response.hasPreviousPage, isFalse);
    });

    test('hasNextPage is false on last page', () {
      const response = PaginatedResponse<String>(
        items: ['a', 'b'],
        totalCount: 12,
        page: 2,
        pageSize: 10,
      );

      expect(response.hasNextPage, isFalse);
      expect(response.hasPreviousPage, isTrue);
    });
  });

  group('FeaturamException', () {
    test('fromDioError creates correct exception type', () {
      final error401 = DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
        requestOptions: RequestOptions(path: '/test'),
      );

      final error404 = DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/test'),
        ),
        requestOptions: RequestOptions(path: '/test'),
      );

      final error409 = DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 409,
          requestOptions: RequestOptions(path: '/test'),
        ),
        requestOptions: RequestOptions(path: '/test'),
      );

      expect(FeaturamException.fromDioError(error401),
          isA<UnauthorizedException>());
      expect(
          FeaturamException.fromDioError(error404), isA<NotFoundException>());
      expect(
          FeaturamException.fromDioError(error409), isA<ConflictException>());
    });
  });
}
