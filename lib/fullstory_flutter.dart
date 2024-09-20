import 'fullstory_flutter_platform_interface.dart';

class FullstoryFlutter {
  Future<String?> getPlatformVersion() {
    return FullstoryFlutterPlatform.instance.getPlatformVersion();
  }

  Future<void> shutdown() {
    return FullstoryFlutterPlatform.instance.shutdown();
  }

  Future<void> restart() {
    return FullstoryFlutterPlatform.instance.restart();
  }

  Future<void> log() {
    return FullstoryFlutterPlatform.instance.log();
  }

  Future<void> resetIdleTimer() {
    return FullstoryFlutterPlatform.instance.resetIdleTimer();
  }

  Future<void> event() {
    return FullstoryFlutterPlatform.instance.event();
  }

  Future<void> consent() {
    return FullstoryFlutterPlatform.instance.consent();
  }

  Future<void> identity() {
    return FullstoryFlutterPlatform.instance.identity();
  }

  Future<void> anonymize() {
    return FullstoryFlutterPlatform.instance.anonymize();
  }

  Future<void> setUserVars() {
    return FullstoryFlutterPlatform.instance.anonymize();
  }

  Future<void> getCurrentSession([bool now = false]) {
    return FullstoryFlutterPlatform.instance.getCurrentSession(now);
  }

  Future<void> getCurrentSessionURL() {
    return FullstoryFlutterPlatform.instance.getCurrentSessionURL();
  }
}
