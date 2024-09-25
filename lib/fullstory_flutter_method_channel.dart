import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fs_log_level.dart';
import 'fullstory_flutter_platform_interface.dart';

/// An implementation of [FullstoryFlutterPlatform] that uses method channels.
class MethodChannelFullstoryFlutter extends FullstoryFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fullstory_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> shutdown() async {
    await methodChannel.invokeMethod<void>('shutdown');
  }

  @override
  Future<void> restart() async {
    await methodChannel.invokeMethod<void>('restart');
  }

  @override
  Future<void> log(
      {FSLogLevel level = FSLogLevel.info, required String message}) async {
    await methodChannel
        .invokeMethod<void>('log', {'level': level.index, 'message': message});
  }

  @override
  Future<void> resetIdleTimer() async {
    await methodChannel.invokeMethod<void>('resetIdleTimer');
  }

  @override
  Future<void> event({
    required String name,
    Map<String, Object?> properties = const {},
  }) async {
    final args = {"name": name, "properties": properties};
    await methodChannel.invokeMethod<void>('event', args);
  }

  @override
  Future<void> consent() async {
    await methodChannel.invokeMethod<void>('consent');
  }

  @override
  Future<void> identity() async {
    await methodChannel.invokeMethod<void>('identity');
  }

  @override
  Future<void> anonymize() async {
    await methodChannel.invokeMethod<void>('anonymize');
  }

  @override
  Future<void> setUserVars() async {
    await methodChannel.invokeMethod<void>('setUserVars');
  }

  @override
  Future<String?> getCurrentSession([bool now = false]) async {
    return await methodChannel.invokeMethod<String>('setUserVars', now);
  }

  @override
  Future<String?> getCurrentSessionURL() async {
    return await methodChannel.invokeMethod<String>('getCurrentSessionURL');
  }
}
