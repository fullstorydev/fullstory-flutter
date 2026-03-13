import 'dart:typed_data';

import 'package:fullstory_flutter/fs_status_listener.dart';
import 'package:fullstory_flutter/fs_log_level.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fullstory_flutter_method_channel.dart';

abstract class FullstoryFlutterPlatform extends PlatformInterface {
  FullstoryFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FullstoryFlutterPlatform _instance = MethodChannelFullstoryFlutter();

  static FullstoryFlutterPlatform get instance => _instance;

  static set instance(FullstoryFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<int?> register(Uint8List canvasDefinition) {
    throw UnimplementedError('register() has not been implemented.');
  }

  Future<Uint8List?> fetchSessionData() {
    throw UnimplementedError('fetchSessionData() has not been implemented.');
  }

  Future<Uint8List?> fetchBlockRules() {
    throw UnimplementedError('fetchBlockRules() has not been implemented.');
  }

  Future<Map<String, Uint8List?>?> fetchPrivacyRules() {
    throw UnimplementedError('fetchPrivacyRules() has not been implemented.');
  }

  void setUpCallbacks(HostCallbacks? callbacks) {
    throw UnimplementedError('setUpCallbacks() has not been implemented.');
  }

  Future<String?> fsVersion() {
    throw UnimplementedError('fsVersion() has not been implemented.');
  }

  Future<void> shutdown() {
    throw UnimplementedError('shutdown() has not been implemented.');
  }

  Future<void> restart() {
    throw UnimplementedError('restart() has not been implemented.');
  }

  Future<void> log({
    FSLogLevel level = FSLogLevel.info,
    required String message,
  }) {
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

  Future<void> captureEvent(Map<String, Object?> properties) {
    throw UnimplementedError('captureEvent() has not been implemented.');
  }

  Future<void> consent(bool consented) {
    throw UnimplementedError('consent() has not been implemented.');
  }

  Future<void> identify(Map<String, Object?> args) {
    throw UnimplementedError('identify() has not been implemented.');
  }

  Future<void> anonymize() {
    throw UnimplementedError('anonymize() has not been implemented.');
  }

  Future<void> setUserVars(Map<String, Object?> userVars) {
    throw UnimplementedError('setUserVars() has not been implemented.');
  }

  Future<String?> getCurrentSession() {
    throw UnimplementedError('getCurrentSession() has not been implemented.');
  }

  Future<String?> getCurrentSessionURL([bool now = false]) {
    throw UnimplementedError(
      'getCurrentSessionURL() has not been implemented.',
    );
  }

  void setStatusListener(FSStatusListener? listener) {
    throw UnimplementedError('setStatusListener() has not been implemented.');
  }

  void addStatusListener(FSStatusListener listener) {
    throw UnimplementedError('addStatusListener() has not been implemented.');
  }

  void removeStatusListener(FSStatusListener listener) {
    throw UnimplementedError(
      'removeStatusListener() has not been implemented.',
    );
  }

  Future<int> page(String pageName, Map<String, Object?> properties) {
    throw UnimplementedError();
  }

  Future<void> startPage(int pageId, Map<String, Object?> propertyUpdates) {
    throw UnimplementedError();
  }

  Future<void> endPage(int pageId) {
    throw UnimplementedError();
  }

  Future<void> updatePageProperties(
    int pageId,
    Map<String, Object?> properties,
  ) {
    throw UnimplementedError();
  }

  Future<void> releasePage(int pageId) {
    throw UnimplementedError();
  }
}

abstract class HostCallbacks {
  Future<FlutterScanResult> scanUi(ScanMode mode, bool consent);
}

class FlutterScanResult {
  final Uint8List views;
  final List<String> strings;
  final Uint8List canvases;
  final List<List<int>> blockedRegions;
  final String? error;

  FlutterScanResult({
    required this.views,
    required this.strings,
    required this.canvases,
    required this.blockedRegions,
    this.error,
  });

  FlutterScanResult.withError(this.error)
    : views = Uint8List(0),
      strings = [],
      canvases = Uint8List(0),
      blockedRegions = [];
  Map<String, dynamic> toMap() => {
    'views': views,
    'strings': strings,
    'canvases': canvases,
    'blockedRegions': blockedRegions,
    if (error != null) 'error': error,
  };

  static final empty = FlutterScanResult(
    views: Uint8List(0),
    strings: [],
    canvases: Uint8List(0),
    blockedRegions: [],
  );
}

enum ScanMode {
  unspecified(-1),
  first(0),
  keyframe(1),
  intermediate(2),
  idle(3),
  unload(4);

  final int channelValue;

  const ScanMode(this.channelValue);

  static ScanMode fromChannelValue(int value) {
    return ScanMode.values.firstWhere(
      (e) => e.channelValue == value,
      orElse: () => ScanMode.unspecified,
    );
  }
}
