import 'package:flutter_test/flutter_test.dart';
import 'package:fullstory/fullstory.dart';
import 'package:fullstory/fullstory_platform_interface.dart';
import 'package:fullstory/fullstory_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFullstoryPlatform
    with MockPlatformInterfaceMixin
    implements FullstoryPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FullstoryPlatform initialPlatform = FullstoryPlatform.instance;

  test('$MethodChannelFullstory is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFullstory>());
  });

  test('getPlatformVersion', () async {
    Fullstory fullstoryPlugin = Fullstory();
    MockFullstoryPlatform fakePlatform = MockFullstoryPlatform();
    FullstoryPlatform.instance = fakePlatform;

    expect(await fullstoryPlugin.getPlatformVersion(), '42');
  });
}
