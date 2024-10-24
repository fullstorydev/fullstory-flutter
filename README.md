# Fullstory Flutter Package

[![Test](https://github.com/fullstorydev/fullstory-flutter/actions/workflows/test.yml/badge.svg)](https://github.com/fullstorydev/fullstory-flutter/actions/workflows/test.yml)

Fullstory's Flutter package exposes access to the Fullstory Native Mobile SDK from within a Flutter app. This plug-in is intended to be used in conjunction with [Fullstory for Mobile Apps](https://www.fullstory.com/mobile-apps/).

⚠️ This is a preview release, some breaking changes are likely before the 1.0.0 release.

## Quick Links

- [Fullstory API](https://developer.fullstory.com)
- [Email us](mailto:mobile-support@fullstory.com)

## What's supported

Most non-visual Fullstory APIs are supported:

- `FS.event({required String name, Map<String, Object?> properties = const {}})`
- `FS.log({FSLogLevel level = FSLogLevel.info, required String message})`
- `FS.identify(String uid, [Map<String, Object?>? userVars])`
- `FS.setUserVars(Map<String, Object?> userVars)`
- `FS.anonymize()`
- `FS.shutdown()`
- `FS.restart()`
- `FS.setStatusListener(FSStatusListener? listener)`
- `FS.getCurrentSession()` → `Future<String?>`
- `FS.getCurrentSessionURL([bool now = false])` → `Future<String?>`
- `FS.resetIdleTimer()`

Visual session replay is not currently supported, but is planned for a future release.
