import 'package:flutter_test/flutter_test.dart';
import 'package:fullstory_flutter/fullstory_flutter.dart';
import 'package:fullstory_flutter/fullstory_flutter_platform_interface.dart';
import 'package:fullstory_flutter/fullstory_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFullstoryFlutterPlatform
    with MockPlatformInterfaceMixin
    implements FullstoryFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FullstoryFlutterPlatform initialPlatform =
      FullstoryFlutterPlatform.instance;

  test('$MethodChannelFullstoryFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFullstoryFlutter>());
  });

  test('getPlatformVersion', () async {
    FullstoryFlutter fullstoryFlutterPlugin = FullstoryFlutter();
    MockFullstoryFlutterPlatform fakePlatform = MockFullstoryFlutterPlatform();
    FullstoryFlutterPlatform.instance = fakePlatform;

    expect(await fullstoryFlutterPlugin.getPlatformVersion(), '42');
  });
}
