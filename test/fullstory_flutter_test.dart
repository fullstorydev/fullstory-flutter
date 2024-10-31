import 'package:flutter_test/flutter_test.dart';
import 'package:fullstory_flutter/fs.dart';
import 'package:fullstory_flutter/src/fullstory_flutter_platform_interface.dart';
import 'package:fullstory_flutter/src/fullstory_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFullstoryFlutterPlatform
    with MockPlatformInterfaceMixin
    implements FullstoryFlutterPlatform {
  @override
  Future<String?> fsVersion() => Future.value('42');

  @override
  Future<void> anonymize() {
    throw UnimplementedError();
  }

  @override
  Future<void> consent() {
    throw UnimplementedError();
  }

  @override
  Future<void> event({
    required String name,
    Map<String, Object?> properties = const {},
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String?> getCurrentSession() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getCurrentSessionURL([bool now = false]) {
    throw UnimplementedError();
  }

  @override
  Future<void> identify(Map<String, dynamic> args) {
    throw UnimplementedError();
  }

  @override
  Future<void> log(
      {FSLogLevel level = FSLogLevel.info, required String message}) {
    throw UnimplementedError();
  }

  @override
  Future<void> resetIdleTimer() {
    throw UnimplementedError();
  }

  @override
  Future<void> restart() {
    throw UnimplementedError();
  }

  @override
  Future<void> setUserVars(Map<String, Object?> userVars) {
    throw UnimplementedError();
  }

  @override
  Future<void> shutdown() {
    throw UnimplementedError();
  }

  @override
  void setStatusListener(FSStatusListener? listener) {
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

    expect(await FS.fsVersion(), '42');
  });
}
