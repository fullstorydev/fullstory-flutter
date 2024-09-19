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

  Future<void> shutdown() {
    throw UnimplementedError('shutdown() has not been implemented.');
  }

  Future<void> restart() {
    throw UnimplementedError('restart() has not been implemented.');
  }

  Future<void> log() {
    throw UnimplementedError('log() has not been implemented.');
  }

  Future<void> resetIdleTimer() {
    throw UnimplementedError('resetIdleTimer() has not been implemented.');
  }

  Future<void> event() {
    throw UnimplementedError('event() has not been implemented.');
  }

  Future<void> consent() {
    throw UnimplementedError('consent() has not been implemented.');
  }

  Future<void> identity() {
    throw UnimplementedError('identity() has not been implemented.');
  }

  Future<void> anonymize() {
    throw UnimplementedError('anonymize() has not been implemented.');
  }

  Future<void> setUserVars() {
    throw UnimplementedError('anonymize() has not been implemented.');
  }

  Future<void> getCurrentSession([bool now = false]) {
    throw UnimplementedError('getCurrentSession() has not been implemented.');
  }

  Future<void> getCurrentSessionURL() {
    throw UnimplementedError(
        'getCurrentSessionURL() has not been implemented.');
  }

  // todo: start/stop/terminate callbacks
  // todo: webview injection disable
}
