import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fullstory_flutter/src/fullstory_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:fullstory_flutter/dio.dart';

void main() {
  group(FullstoryInterceptor, () {
    late FakeFullstoryFlutterPlatform fakePlatform;

    setUp(() {
      fakePlatform = FakeFullstoryFlutterPlatform();
      FullstoryFlutterPlatform.instance = fakePlatform;
    });

    test('captures fields using computeSize', () {
      final interceptor = FullstoryInterceptor(
        computeRequestSize: (_) => 42,
        computeResponseSize: (_) => 25,
      );

      var requestOptions = RequestOptions(
        path: 'https://example.com',
        method: 'GET',
      );
      interceptor.onRequest(requestOptions, RequestInterceptorHandler());
      interceptor.onResponse(
        Response(
          requestOptions: requestOptions,
          statusCode: 200,
          data: 'response data',
        ),
        ResponseInterceptorHandler(),
      );

      expect(fakePlatform.eventProperties.length, 1);
      final event = fakePlatform.eventProperties.first;
      expect(event['eventType'], 1);
      expect(event['url'], 'https://example.com');
      expect(event['method'], 'GET');
      expect(event['statusCode'], 200);
      expect(event['requestSize'], 42);
      expect(event['responseSize'], 25);
    });

    test('captures fields on error', () {
      final interceptor = FullstoryInterceptor();

      var requestOptions = RequestOptions(
        path: 'https://example.com',
        method: 'GET',
      );
      interceptor.onRequest(requestOptions, RequestInterceptorHandler());

      interceptor.onError(
        DioException(
          requestOptions: requestOptions,
          response: Response(statusCode: 500, requestOptions: requestOptions),
        ),
        FakeErrorHandler(),
      );

      expect(fakePlatform.eventProperties.length, 1);
      final event = fakePlatform.eventProperties.first;
      expect(event['eventType'], 1);
      expect(event['url'], 'https://example.com');
      expect(event['method'], 'GET');
      expect(event['statusCode'], 500);
      expect(event['requestSize'], 0);
      expect(event['responseSize'], 0);
    });
  });

  group('requestFromUtf8', () {
    test('returns 0 for null data', () {
      expect(requestFromUtf8(RequestOptions()), 0);
    });

    test('returns correct size for string data', () {
      expect(requestFromUtf8(RequestOptions(data: 'Hello')), 5);
    });

    test('returns correct size for Uint8List data', () {
      final result = requestFromUtf8(RequestOptions(data: Uint8List.fromList([1, 2, 3])));
      expect(
        result,
        3,
      );
    });
  });

  group('responseFromUtf8', () {
    test('returns 0 for null response', () {
      expect(responseFromUtf8(null), 0);
    });

    final options = RequestOptions();

    test('returns correct size for string data', () {
      final result = responseFromUtf8(
        Response(requestOptions: options, data: 'Hello'),
      );
      expect(result, 5);
    });

    test('returns correct size for Uint8List data', () {
      final result = responseFromUtf8(
        Response(requestOptions: options, data: Uint8List.fromList([1, 2, 3])),
      );
      expect(result, 3);
    });
  });
}

class FakeFullstoryFlutterPlatform
    with MockPlatformInterfaceMixin, Fake
    implements FullstoryFlutterPlatform {
  List<Map<String, Object?>> eventProperties = [];

  @override
  Future<void> captureEvent(Map<String, Object?> properties) {
    eventProperties.add(properties);
    return Future.value();
  }
}

/// A fake implementation of [ErrorInterceptorHandler] that does nothing to
/// avoid error thrown when the interceptor completes.
class FakeErrorHandler with Fake implements ErrorInterceptorHandler {
  @override
  void next(DioException err) {
    // No-op
  }
}
