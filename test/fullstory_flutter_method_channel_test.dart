import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fullstory_flutter/src/fullstory_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFullstoryFlutter platform = MethodChannelFullstoryFlutter();
  const MethodChannel channel = MethodChannel('fullstory_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.fsVersion(), '42');
  });
}
