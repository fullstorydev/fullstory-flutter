import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fullstory_flutter/fs.dart';

import 'fullstory_flutter_platform_interface.dart';

class MethodChannelFullstoryFlutter extends FullstoryFlutterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('fullstory_flutter');

  final List<FSStatusListener> _statusListeners = [];

  MethodChannelFullstoryFlutter() {
    WidgetsFlutterBinding.ensureInitialized();
    methodChannel.setMethodCallHandler(handle);
  }

  HostCallbacks? _callbacks;

  @override
  Future<int?> register(Uint8List canvasDefinition) async {
    return await methodChannel.invokeMethod<int>('register', {
      'canvasDefinition': canvasDefinition,
    });
  }

  @override
  Future<Uint8List?> fetchSessionData() =>
      methodChannel.invokeMethod('fetchSessionData');

  @override
  Future<Uint8List?> fetchBlockRules() =>
      methodChannel.invokeMethod('fetchBlockRules');

  @override
  Future<Map<String, Uint8List?>?> fetchPrivacyRules() =>
      methodChannel.invokeMapMethod<String, Uint8List?>('fetchPrivacyRules');

  @override
  void setUpCallbacks(HostCallbacks? callbacks) {
    _callbacks = callbacks;
    methodChannel.setMethodCallHandler(handle);
  }

  Future<Object?> handle(MethodCall call) async {
    switch (call.method) {
      case 'onSession':
        for (final statusListener in _statusListeners) {
          statusListener.onFSSession(call.arguments as String);
        }
        return null;

      case 'scanUi':
        final mode = ScanMode.fromChannelValue(call.arguments['mode']);
        final consent = call.arguments['consent'] as bool;
        final result = await _callbacks?.scanUi(mode, consent);
        return result?.toMap() ??
            FlutterScanResult.withError(
              _callbacks == null
                  ? 'No HostCallbacks registered'
                  : 'HostCallbacks returned null result',
            ).toMap();
      default:
        throw MissingPluginException(
          'Unexpected FullStory channel method call: ${call.method}',
        );
    }
  }

  @override
  void setStatusListener(FSStatusListener? listener) {
    if (listener == null) {
      _statusListeners.clear();
    } else {
      _statusListeners.add(listener);
    }
  }

  @override
  void addStatusListener(FSStatusListener listener) {
    _statusListeners.add(listener);
  }

  @override
  void removeStatusListener(FSStatusListener listener) {
    _statusListeners.remove(listener);
  }

  @override
  Future<String?> fsVersion() async {
    final version = await methodChannel.invokeMethod<String>('fsVersion');
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
  Future<void> log({
    FSLogLevel level = FSLogLevel.info,
    required String message,
  }) async {
    await methodChannel.invokeMethod<void>('log', {
      'level': level.index,
      'message': message,
    });
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
  Future<void> captureEvent(Map<String, Object?> properties) async {
    await methodChannel.invokeMethod<void>('captureEvent', properties);
  }

  @override
  Future<void> consent(bool consented) async {
    await methodChannel.invokeMethod<void>('consent', consented);
  }

  @override
  Future<void> identify(Map<String, Object?> args) async {
    await methodChannel.invokeMethod<void>('identify', args);
  }

  @override
  Future<void> anonymize() async {
    await methodChannel.invokeMethod<void>('anonymize');
  }

  @override
  Future<void> setUserVars(Map<String, Object?> userVars) async {
    await methodChannel.invokeMethod<void>('setUserVars', userVars);
  }

  @override
  Future<String?> getCurrentSession() async {
    return await methodChannel.invokeMethod<String>('getCurrentSession');
  }

  @override
  Future<String?> getCurrentSessionURL([bool now = false]) async {
    return await methodChannel.invokeMethod<String>(
      'getCurrentSessionURL',
      now,
    );
  }

  @override
  Future<int> page(String pageName, Map<String, Object?> properties) async {
    final id = await methodChannel.invokeMethod<int>('page', {
      'pageName': pageName,
      'properties': properties,
    });
    return id!;
  }

  @override
  Future<void> startPage(int pageId, Map<String, Object?> propertyUpdates) {
    return methodChannel.invokeMethod('startPage', {
      'pageId': pageId,
      'propertyUpdates': propertyUpdates,
    });
  }

  @override
  Future<void> endPage(int pageId) {
    return methodChannel.invokeMethod('endPage', pageId);
  }

  @override
  Future<void> updatePageProperties(
    int pageId,
    Map<String, Object?> properties,
  ) {
    return methodChannel.invokeMethod('updatePageProperties', {
      'pageId': pageId,
      'properties': properties,
    });
  }

  @override
  Future<void> releasePage(int pageId) {
    return methodChannel.invokeMethod('releasePage', pageId);
  }
}
