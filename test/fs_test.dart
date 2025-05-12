import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

    test('crashEvent captures crash details', () async {
      final exception = Exception('Test exception');
      final stackTrace = StackTrace.current;

      await FS.crashEvent(
        name: 'Test Crash',
        exception: exception,
        stackTrace: stackTrace,
      );

      expect(fakePlatform.eventProperties.length, 1);
      final event = fakePlatform.eventProperties.first;
      expect(event['eventType'], 2);
      expect(event['name'], 'Test Crash');
      expect(event['frames'], contains(exception.toString()));
      expect(event['frames'], contains(stackTrace.toString()));
    });

    testWidgets('captureErrors allows capture of flutter build errors',
        (tester) async {
      FS.captureErrors();

      var exception = Exception('Test exception message');
      await tester.pumpWidget(Builder(
        builder: (context) {
          throw exception;
        },
      ));

      FlutterError.onError = FlutterError.presentError;

      expect(fakePlatform.eventProperties.length, 1);
      final event = fakePlatform.eventProperties.first;
      expect(event, isNotNull);
      expect(event['eventType'], 2);
      expect(event['name'], 'Flutter error');

      final frames = event['frames'] as List<String>;
      expect(frames, contains(exception.toString()));
      expect(frames[1], contains('fs_test.dart'));
    });

    test('captureErrors allows capture of PlatformDispatcher errors',
        () {
      FS.captureErrors();

      final exception = Exception('Test exception message');
      PlatformDispatcher.instance.onError?.call(exception, StackTrace.current);

      FlutterError.onError = FlutterError.presentError;

      expect(fakePlatform.eventProperties.length, 1);
      final event = fakePlatform.eventProperties.first;
      expect(event, isNotNull);
      expect(event['eventType'], 2);
      expect(event['name'], 'Platform error');

      final frames = event['frames'] as List<String>;
      expect(frames, contains(exception.toString()));
      expect(frames[1], contains('fs_test.dart'));
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
