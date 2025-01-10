import 'package:fullstory_flutter/fs_status_listener.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fullstory_flutter_method_channel.dart';
import '../fs_log_level.dart';
import '../fs_page.dart';

abstract class FullstoryFlutterPlatform extends PlatformInterface {
  /// Constructs a FullstoryFlutterPlatform.
  FullstoryFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FullstoryFlutterPlatform _instance = MethodChannelFullstoryFlutter();

  /// The default instance of [FullstoryFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFullstoryFlutter].
  static FullstoryFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FullstoryFlutterPlatform] when
  /// they register themselves.
  static set instance(FullstoryFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> fsVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> shutdown() {
    throw UnimplementedError('shutdown() has not been implemented.');
  }

  Future<void> restart() {
    throw UnimplementedError('restart() has not been implemented.');
  }

  Future<void> log(
      {FSLogLevel level = FSLogLevel.info, required String message}) {
    throw UnimplementedError('log() has not been implemented.');
  }

  Future<void> resetIdleTimer() {
    throw UnimplementedError('resetIdleTimer() has not been implemented.');
  }

  Future<void> event({
    required String name,
    Map<String, Object?> properties = const {},
  }) {
    throw UnimplementedError('event() has not been implemented.');
  }

  Future<void> consent() {
    throw UnimplementedError('consent() has not been implemented.');
  }

  Future<void> identify(Map<String, dynamic> args) {
    throw UnimplementedError('identity() has not been implemented.');
  }

  Future<void> anonymize() {
    throw UnimplementedError('anonymize() has not been implemented.');
  }

  Future<void> setUserVars(Map<String, Object?> userVars) {
    throw UnimplementedError('anonymize() has not been implemented.');
  }

  Future<String?> getCurrentSession() {
    throw UnimplementedError('getCurrentSession() has not been implemented.');
  }

  Future<String?> getCurrentSessionURL([bool now = false]) {
    throw UnimplementedError(
        'getCurrentSessionURL() has not been implemented.');
  }

  void setStatusListener(FSStatusListener? listener) {
    throw UnimplementedError('setStatusListener() has not been implemented.');
  }
  // todo: webview injection disable

  FSPage page(String pageName, Map<String, dynamic> pageVars);
  Future<void> startPage(int pageId);
  Future<void> endPage(int pageId);
  Future<void> updatePageProperties(
      int pageId, Map<String, dynamic> properties);
  Future<void> releasePage(int pageId);
}
