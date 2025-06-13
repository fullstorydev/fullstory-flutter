## 0.5.0

- Added support for page autocapture using `FSNavigatorObserver` for named routes
- Added support for crash autocapture using `FS.captureErrors({void Function(Object? exception, StackTrace? stack)? errorHandler})`
or manual crash capture with `FS.crashEvent({String name, Object? exception, StackTrace? stackTrace,})`
- Added support for network request autocapture with `package:dio` or `package:http` using `FSInteceptor` and manual
network capture with `FS.networkEvent({String url, String method, int? statusCode, int? durationMs, int? requestSize, int? responseSize})`

## 0.4.0

- Added support for [add-to-app](https://docs.flutter.dev/add-to-app) Flutter modules. Use `-PfsTarget=` to set Fullstory version on Android if you encounter issues.
- Added `example_module` directory with example add-to-app module setup.

## 0.3.0

⚠️ BREAKING ⚠️

- Changed `FS.page(String pageName, {Map<String, Object?>? pageVars})` to `FS.page(String pageName, {Map<String, Object?>? properties})` (pageVars -> properties)
- Changed `FS.getCurrentSessionURL({boolean now})` to `FS.currentSessionURL({boolean now})` (removed 'get')

New:

- Added optional `propertyUpdates` parameter to `FSPage#start()`

## 0.2.0

⚠️ BREAKING ⚠️

- Changed `FS.getCurrentSession()` (method) to `FS.currentSession` (property, dropped "get")
- Changed `FS.fsVersion()` (method) to `FS.fsVersion` (property)
- Changed `FS.getCurrentSessionURL([bool now = false])` (positional parameter) to `FS.getCurrentSessionURL({bool now = false})` (named parameter)
- Removed `FSLogLevel.debug` to align log levels with Fullstory playback

New:

- Added `FS.page()` API and associated `FSPage` object and APIs

## 0.1.3

- Update with links to developer docs.

## 0.1.2

- Second attempt at generating example.md, apparently `flutter pub publish` omits files that are .gitignore'd

## 0.1.1

- Added a new `fullstory_flutter.dart` file so that https://pub.dev/packages/fullstory_flutter/install will only suggest importing a single file. It just re-exports `fs.dart`, so importing either one is functionally equivalent.
- Improved docs and examples, including a script to generate an example.md for https://pub.dev/packages/fullstory_flutter/example

## 0.1.0

- Breaking: removed `getPlatformVersion()` API
- Added `FS.fsVersion()` API to return the version of the underlying native Fullstory framework
- Increased minimum Fullstory version to 1.54 to support `fsVersion()` API

## 0.0.3

- Breaking: changed `FS.event()` to use positional parameters rather than named parameters to better match other Fullstory APIs

## 0.0.2

- Documented public APIs, move non-public parts to lib/src/
- No functional changes

## 0.0.1

- Initial release: most non-visual APIs are supported (logging, identify & anonymize, events, shutdown & restart, etc.)
- No visual replay in the current release
