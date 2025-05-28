import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'fs_log_level.dart';
import 'fs_status_listener.dart';
import 'src/fullstory_flutter_platform_interface.dart';

export 'fs_log_level.dart';
export 'fs_status_listener.dart';

/// Fullstory API
///
/// Note that all methods are static.
/// Also note that methods may drop data if called when there is no Fullstory session active.
class FS {
  // This is dead code, but it prevents `dart doc` from making up a FS() constructor.
  FS._() {
    throw UnsupportedError(
        "FS is a static class, do not create instances of it.");
  }

  /// Version of the underlying native Fullstory framework, e.g. '1.54.0'
  static Future<String?> get fsVersion {
    return FullstoryFlutterPlatform.instance.fsVersion();
  }

  /// End Fullstory session.
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/fullcapture/capture-data/#stop-data-capture
  static Future<void> shutdown() {
    return FullstoryFlutterPlatform.instance.shutdown();
  }

  /// Start or resume a Fullstory session.
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/fullcapture/capture-data/#restart-data-capture
  static Future<void> restart() {
    return FullstoryFlutterPlatform.instance.restart();
  }

  /// Log a message that will appear in the Dev Tools > Console section of the Fullstory replay.
  ///
  /// Errors will also appear in the event list at the right.
  ///
  /// Capture is dependant on the logLevel setting in the Android and iOS settings.
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/fullcapture/logging/
  static Future<void> log(
      {FSLogLevel level = FSLogLevel.info, required String message}) {
    return FullstoryFlutterPlatform.instance
        .log(level: level, message: message);
  }

  /// Reset the idle timer and prevent Fullstory from going into a lower-fidelity mode that conserves power and bandwidth.
  ///
  /// Most apps do not need to call this, because Fullstory automatically resets the timer whenever user interaction is detected.
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/fullcapture/reset-idle-timer/
  static Future<void> resetIdleTimer() {
    return FullstoryFlutterPlatform.instance.resetIdleTimer();
  }

  /// Create a custom event that will appear in the event list in playback and can be used in segments, funnels, etc.
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/capture-events/analytics-events/
  static Future<void> event(String name,
      [Map<String, Object?> properties = const {}]) {
    return FullstoryFlutterPlatform.instance
        .event(name: name, properties: properties);
  }

  /// Create a network event in the Dev Log in playback.
  ///
  /// [method] should be a valid HTTP method, such as GET, POST, PUT, or DELETE.
  /// [requestSize] and [responseSize] are measured in bytes.
  static Future<void> networkEvent({
    required String url,
    required String method,
    int statusCode = 0,
    int durationMs = 0,
    int requestSize = 0,
    int responseSize = 0,
  }) =>
      FullstoryFlutterPlatform.instance.captureEvent({
        "eventType": _EventType.network.value,
        "url": url,
        "method": method,
        "statusCode": statusCode,
        "durationMS": durationMs,
        "requestSize": requestSize,
        "responseSize": responseSize,
      });

  /// Report a crash to Fullstory for display in playback.
  ///
  /// [exception] and [stackTrace] are optional, but if provided, they will be
  /// included in the event.
  ///
  /// Once called, Fullstory capture will halt, since this assumes the app has
  /// fatally exited.
  static Future<void> crashEvent({
    String name = 'Flutter crash',
    Object? exception,
    StackTrace? stackTrace,
  }) =>
      FullstoryFlutterPlatform.instance.captureEvent({
        // This event type is assigned to crash events in host SDKs
        'eventType': _EventType.crash.value,
        'name': name,
        'frames': <String>[
          if (exception != null) exception.toString(),
          if (stackTrace != null) stackTrace.toString(),
        ],
      });

  /// Configures Flutter to send errors to Fullstory for handling.
  ///
  /// If you would prefer to handle errors yourself, use [crashEvent] to
  /// report errors to Fullstory in your crash handling logic.
  ///
  /// Set [errorHandler] to run any graceful shutdown or user notification
  /// logic you would like to run after the crash has been captured.
  ///
  /// Once an error is captured, Fullstory capture will halt,
  /// since this assumes the app has fatally exited.
  static void captureErrors({
    void Function(Object? exception, StackTrace? stack)? errorHandler,
  }) {
    WidgetsFlutterBinding.ensureInitialized();

    final flutterHandler = FlutterError.onError;
    FlutterError.onError = (details) async {
      await FS.crashEvent(
        name: 'Flutter error',
        exception: details.exception,
        stackTrace: details.stack,
      );
      flutterHandler?.call(details);
      errorHandler?.call(details.exception, details.stack);
    };

    final platformHandler = PlatformDispatcher.instance.onError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FS.crashEvent(
        name: 'Platform error',
        exception: error,
        stackTrace: stack,
      );

      errorHandler?.call(error, stack);
      return platformHandler?.call(error, stack) ?? false;
    };
  }

  /// Identify a user and associate current and future sessions with that user.
  ///
  /// Will end the current session and begin a new one if a different uid was previously set.
  /// Also allows custom userVars, see [FS.setUserVars]
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/identification/identify-users/
  static Future<void> identify(String uid, [Map<String, Object?>? userVars]) {
    Map<String, Object?> args = {"uid": uid};
    if (userVars != null) {
      args["userVars"] = userVars;
    }
    return FullstoryFlutterPlatform.instance.identify(args);
  }

  /// If a user ID was previously set via [FS.identify], this will end the session, clear the user ID, and begin a new anonymous session.
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/identification/anonymize-users/
  static Future<void> anonymize() {
    return FullstoryFlutterPlatform.instance.anonymize();
  }

  /// Set arbitrary key/value pairs that are associated with the current user.
  ///
  /// Fullstory uses two keys, if set:
  /// * The value of `displayName` is displayed in the session list and on the user card in Fullstory playback.
  /// * The value of `email` can be used to email the user directly from within Fullstory, and also to find a user's sessions.
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/identification/set-user-properties/
  static Future<void> setUserVars(Map<String, Object?> userVars) {
    return FullstoryFlutterPlatform.instance.setUserVars(userVars);
  }

  /// Returns the ID of the current Fullstory session.
  ///
  /// See also: [FS.currentSessionURL]
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/get-session-details/
  static Future<String?> get currentSession {
    return FullstoryFlutterPlatform.instance.getCurrentSession();
  }

  /// Returns the URL to view the current Fullstory session.
  ///
  /// If the optional [now] parameter is set to `true`, the URL will begin the session from the current timestamp rather than the start of the session.
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/get-session-details/
  static Future<String?> currentSessionURL({bool now = false}) {
    return FullstoryFlutterPlatform.instance.getCurrentSessionURL(now);
  }

  /// Specify a delegate to be notified of Fullstory session status events.
  ///
  /// Use the FSStatusListener mixin and override the onFSSession method to know when Fullstory is ready for events, logs, etc.
  ///
  /// For more information, see https://developer.fullstory.com/mobile/flutter/fullcapture/callbacks-and-delegates/
  static void setStatusListener(FSStatusListener? listener) {
    FullstoryFlutterPlatform.instance.setStatusListener(listener);
  }

  /// Create a Fullstory Page object
  ///
  /// Pages can be created for each screen or logical section of your app to segment analytics and enable page-specific features such as Heatmaps and Journeys
  ///
  /// Call [FSPage.start()] on the returned [FSPage] object to mark the page as active.
  ///
  /// For more information, see https://help.fullstory.com/hc/en-us/articles/14795945510295-Mobile-App-Pages-in-Fullstory
  static FSPage page(String pageName, {Map<String, Object?>? properties}) {
    return FSPage._(
        FullstoryFlutterPlatform.instance.page(pageName, properties ?? {}));
  }
}

/// Fullstory Page object
///
/// See [FS.page()]
class FSPage {
  // The ID is used to ensure match the Dart page object to it's counterpart in Swift/Kotlin
  final Future<int> _id;

  // This should ensure the matching FSPage from the Android/iOS SDK is released.
  // Dart's documentation stresses that this is unreliable, but it seems to work well enough in practice.
  // (Also, pages typically last the duration of the app.)
  static final Finalizer<int> _finalizer = Finalizer((pageId) {
    FullstoryFlutterPlatform.instance.releasePage(pageId);
  });

  // Private constructor
  // (This is the reason this class is in fs.dart instead of it's own file)
  FSPage._(this._id) {
    _id.then((value) => _finalizer.attach(this, value, detach: this));
  }

  /// Start the current page. May be called multiple times if the page is visited more than once.
  Future<void> start({Map<String, Object?>? propertyUpdates}) async {
    return FullstoryFlutterPlatform.instance
        .startPage(await _id, propertyUpdates ?? {});
  }

  /// End the current page. Optional. Starting a different page implicitly ends the current one.
  Future<void> end() async {
    return FullstoryFlutterPlatform.instance.endPage(await _id);
  }

  /// Merge the given properties into the page's existing properties (if any).
  Future<void> updateProperties(Map<String, Object?> properties) async {
    return FullstoryFlutterPlatform.instance
        .updatePageProperties(await _id, properties);
  }

  /// Free the native Fullstory Android/iOS SDK FSPage object that is linked to this Dart object.
  ///
  /// This should only be called when a page is no longer needed, to allow the native counterpart to be garbage collected.
  /// This call is optional - usually Dart automatically handles this correctly.
  void dispose() async {
    _finalizer.detach(this);
    await FullstoryFlutterPlatform.instance.releasePage(await _id);
  }
}

/// Event type values used for [FullstoryFlutterPlatform.captureEvent].
///
/// Each should correspond to a different method in [FS] which delegates to
/// `captureEvent` with the additional predefined properties.
enum _EventType {
  network(1),
  crash(2);

  final int value;

  const _EventType(this.value);
}
