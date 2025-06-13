# Fullstory Flutter Package

[![.github/workflows/ci.yml](https://github.com/fullstorydev/fullstory-flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/fullstorydev/fullstory-flutter/actions/workflows/ci.yml)

Fullstory's Flutter package exposes access to the Fullstory Native Mobile SDK from within a Flutter app. This plug-in is intended to be used in conjunction with [Fullstory for Mobile Apps](https://www.fullstory.com/mobile-apps/).

⚠️ This is a preview release, some breaking changes are possible before the 1.0.0 release.

## Quick Links

- [Getting Started guide](https://help.fullstory.com/hc/en-us/articles/27461129353239)
- [Usage examples](https://github.com/fullstorydev/fullstory-flutter/tree/main/example/lib)
- [Fullstory API](https://developer.fullstory.com/mobile/flutter/)
- [Email us](mailto:mobile-support@fullstory.com)

## What's supported

Most non-visual Fullstory APIs are supported:

- `FS.event(String name, [Map<String, Object?> properties = const {}])`
- `FS.page(String pageName, {Map<String, Object?>? properties})` → `FSPage`
- `FS.log({FSLogLevel level = FSLogLevel.info, required String message})`
- `FS.identify(String uid, [Map<String, Object?>? userVars])`
- `FS.setUserVars(Map<String, Object?> userVars)`
- `FS.anonymize()`
- `FS.shutdown()`
- `FS.restart()`
- `FS.setStatusListener(FSStatusListener? listener)`
- `FS.currentSession` → `Future<String?>`
- `FS.currentSessionURL({bool now = false})` → `Future<String?>`
- `FS.fsVersion` → `Future<String?>`
- `FS.resetIdleTimer()`
- `FS.networkEvent({String url, String method, int? statusCode, int? durationMs, int? requestSize, int? responseSize})`
- `FS.crashEvent({String name, Object? exception, StackTrace? stackTrace,})`
- `FS.captureErrors({void Function(Object? exception, StackTrace? stack)? errorHandler})`

Additionally, interceptors are available to autocapture network requests with
popular libraries using `FSInterceptor`, and page navigation can be captured
with `FSNavigatorObserver`.

Visual session replay is not currently supported, but is planned for a future release.

## Getting Started

See [Getting started with Fullstory for Flutter Mobile Apps](https://help.fullstory.com/hc/en-us/articles/27461129353239)

Also see our [example app](https://github.com/fullstorydev/fullstory-flutter/tree/main/example) for working API usage examples.
