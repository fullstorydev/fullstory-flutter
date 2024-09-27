import 'fullstory_flutter_platform_interface.dart';
import 'fs_log_level.dart';
export 'fs_log_level.dart';
import 'fs_status_listener.dart';
export 'fs_status_listener.dart';

class FS {
  static Future<String?> getPlatformVersion() {
    return FullstoryFlutterPlatform.instance.getPlatformVersion();
  }

  static Future<void> shutdown() {
    return FullstoryFlutterPlatform.instance.shutdown();
  }

  static Future<void> restart() {
    return FullstoryFlutterPlatform.instance.restart();
  }

  static Future<void> log(
      {FSLogLevel level = FSLogLevel.info, required String message}) {
    return FullstoryFlutterPlatform.instance
        .log(level: level, message: message);
  }

  static Future<void> resetIdleTimer() {
    return FullstoryFlutterPlatform.instance.resetIdleTimer();
  }

  static Future<void> event({
    required String name,
    Map<String, Object?> properties = const {},
  }) {
    return FullstoryFlutterPlatform.instance
        .event(name: name, properties: properties);
  }

  static Future<void> consent() {
    return FullstoryFlutterPlatform.instance.consent();
  }

  static Future<void> identify(String uid, [Map<String, Object?>? userVars]) {
    Map<String, dynamic> args = {"uid": uid};
    if (userVars != null) {
      args["userVars"] = userVars;
    }
    return FullstoryFlutterPlatform.instance.identify(args);
  }

  static Future<void> anonymize() {
    return FullstoryFlutterPlatform.instance.anonymize();
  }

  static Future<void> setUserVars(Map<String, Object?> userVars) {
    return FullstoryFlutterPlatform.instance.setUserVars(userVars);
  }

  static Future<String?> getCurrentSession() {
    return FullstoryFlutterPlatform.instance.getCurrentSession();
  }

  static Future<String?> getCurrentSessionURL([bool now = false]) {
    return FullstoryFlutterPlatform.instance.getCurrentSessionURL(now);
  }

  static void setStatusListener(FSStatusListener? listener) {
    FullstoryFlutterPlatform.instance.setStatusListener(listener);
  }
}
