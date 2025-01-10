import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fullstory_flutter/fs.dart';

import 'fullstory_flutter_platform_interface.dart';

/// An implementation of [FullstoryFlutterPlatform] that uses method channels.
class MethodChannelFullstoryFlutter extends FullstoryFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fullstory_flutter');

  FSStatusListener? statusListener;

  MethodChannelFullstoryFlutter() {
    WidgetsFlutterBinding.ensureInitialized();
    methodChannel.setMethodCallHandler(handle);
  }

  Future<Object?> handle(MethodCall call) {
    // ignore: avoid_print
    // print(
    //   "call from native => dart: ${call.method}(${call.arguments})",
    // );
    switch (call.method) {
      case 'onSession':
        statusListener?.onFSSession(call.arguments as String);
      // case 'onStop':
      //   statusListener?.onFSShutdown();
      // case 'onError':
      //   statusListener?.onFSError();
      default:
        // ignore: avoid_print
        print(
            "WARNING: unhandled command sent from native Fullstory SDK to Flutter library: $call");
    }
    return Future.value(null);
  }

  @override
  void setStatusListener(FSStatusListener? listener) {
    statusListener = listener;
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
  Future<void> identify(Map<String, dynamic> args) async {
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
        'getCurrentSessionURL', now);
  }

  // FS Pages apis
  @override
  Future<FSPage> page(String pageName, Map<String, dynamic> pageVars) async {
    final result = await methodChannel.invokeMethod<int>('page', {
      'pageName': pageName,
      'pageVars': pageVars,
    });
    return new FSPage(result!);
  }

  @override
  Future<void> startPage(int pageId) {
    return methodChannel.invokeMethod('startPage', pageId);
  }

  @override
  Future<void> endPage(int pageId) {
    return methodChannel.invokeMethod('endPage', pageId);
  }

  @override
  Future<void> updatePageProperties(
      int pageId, Map<String, dynamic> properties) {
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
