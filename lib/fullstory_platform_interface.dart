import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fullstory_method_channel.dart';

abstract class FullstoryPlatform extends PlatformInterface {
  /// Constructs a FullstoryPlatform.
  FullstoryPlatform() : super(token: _token);

  static final Object _token = Object();

  static FullstoryPlatform _instance = MethodChannelFullstory();

  /// The default instance of [FullstoryPlatform] to use.
  ///
  /// Defaults to [MethodChannelFullstory].
  static FullstoryPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FullstoryPlatform] when
  /// they register themselves.
  static set instance(FullstoryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
