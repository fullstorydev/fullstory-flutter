import 'package:flutter_test/flutter_test.dart';
import 'package:fullstory_flutter/fs.dart';
import 'package:fullstory_flutter/src/fullstory_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  group(FS, () {
    late FakeFullstoryFlutterPlatform fakePlatform;

    setUp(() {
      fakePlatform = FakeFullstoryFlutterPlatform();
      FullstoryFlutterPlatform.instance = fakePlatform;
    });

    test('networkEvent captures network metrics', () async {
      await FS.networkEvent(
        url: 'https://example.com',
        method: 'GET',
        statusCode: 200,
        durationMs: 123,
        requestSize: 456,
        responseSize: 789,
      );

      expect(fakePlatform.eventProperties.length, 1);
      final event = fakePlatform.eventProperties.first;
      expect(event['eventType'], 1);
      expect(event['url'], 'https://example.com');
      expect(event['method'], 'GET');
      expect(event['statusCode'], 200);
      expect(event['durationMS'], 123);
      expect(event['requestSize'], 456);
      expect(event['responseSize'], 789);
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
