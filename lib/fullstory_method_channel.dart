import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fullstory_platform_interface.dart';

/// An implementation of [FullstoryPlatform] that uses method channels.
class MethodChannelFullstory extends FullstoryPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fullstory');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
