import 'package:flutter_test/flutter_test.dart';
import 'package:fullstory_flutter/fs.dart';
import 'package:fullstory_flutter/fullstory_flutter_platform_interface.dart';
import 'package:fullstory_flutter/fullstory_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFullstoryFlutterPlatform
    with MockPlatformInterfaceMixin
    implements FullstoryFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> anonymize() {
    // TODO: implement anonymize
    throw UnimplementedError();
  }

  @override
  Future<void> consent() {
    // TODO: implement consent
    throw UnimplementedError();
  }

  @override
  Future<void> event({
    required String name,
    Map<String, Object?> properties = const {},
  }) {
    // TODO: implement event
    throw UnimplementedError();
  }

  @override
  Future<void> getCurrentSession([bool now = false]) {
    // TODO: implement getCurrentSession
    throw UnimplementedError();
  }

  @override
  Future<void> getCurrentSessionURL() {
    // TODO: implement getCurrentSessionURL
    throw UnimplementedError();
  }

  @override
  Future<void> identify(Map<String, dynamic> args) {
    // TODO: implement identity
    throw UnimplementedError();
  }

  @override
  Future<void> log(
      {FSLogLevel level = FSLogLevel.info, required String message}) {
    // TODO: implement log
    throw UnimplementedError();
  }

  @override
  Future<void> resetIdleTimer() {
    // TODO: implement resetIdleTimer
    throw UnimplementedError();
  }

  @override
  Future<void> restart() {
    // TODO: implement restart
    throw UnimplementedError();
  }

  @override
  Future<void> setUserVars(Map<String, Object?> userVars) {
    // TODO: implement setUserVars
    throw UnimplementedError();
  }

  @override
  Future<void> shutdown() {
    // TODO: implement shutdown
    throw UnimplementedError();
  }
}

void main() {
  final FullstoryFlutterPlatform initialPlatform =
      FullstoryFlutterPlatform.instance;

  test('$MethodChannelFullstoryFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFullstoryFlutter>());
  });

  test('getPlatformVersion', () async {
    MockFullstoryFlutterPlatform fakePlatform = MockFullstoryFlutterPlatform();
    FullstoryFlutterPlatform.instance = fakePlatform;

    expect(await FS.getPlatformVersion(), '42');
  });
}
