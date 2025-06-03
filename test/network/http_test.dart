import 'package:flutter_test/flutter_test.dart';
import 'package:fullstory_flutter/network/http.dart';
import 'package:fullstory_flutter/src/fullstory_flutter_platform_interface.dart';
import 'package:http/http.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  group(FSInterceptor, () {
    late FakeFullstoryFlutterPlatform fakePlatform;

    setUp(() {
      fakePlatform = FakeFullstoryFlutterPlatform();
      FullstoryFlutterPlatform.instance = fakePlatform;
    });

    test('captures fields from network event', () async {
      final interceptor = FSInterceptor();

      final request = Request('GET', Uri.parse('https://example.com'))
        ..body = '123';
      final response = Response('1234', 200, request: request);

      interceptor.interceptRequest(request: request);
      interceptor.interceptResponse(response: response);

      expect(fakePlatform.eventProperties.length, 1);
      final event = fakePlatform.eventProperties.first;
      expect(event['eventType'], 1);
      expect(event['url'], 'https://example.com');
      expect(event['method'], 'GET');
      expect(event['statusCode'], 200);
      expect(event['requestSize'], 3);
      expect(event['responseSize'], 4);
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
