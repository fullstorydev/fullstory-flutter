## 0.2.0

⚠️ BREAKING ⚠️

- Changed `FS.currentSession()` (method) to `FS.currentSession` (property)
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
