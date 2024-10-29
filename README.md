# Fullstory Flutter Package

[![.github/workflows/ci.yml](https://github.com/fullstorydev/fullstory-flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/fullstorydev/fullstory-flutter/actions/workflows/ci.yml)

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

## Getting Started

After installing this flutter library you will need to configure the native Fullstory Android and iOS frameworks.

For Android, you will need to start at the beginning of our [Getting Started with Android Data Capture](https://help.fullstory.com/hc/en-us/articles/360040596093-Getting-Started-with-Android-Data-Capture) guide.

For iOS, the CocoaPods Pod is automatically installed as a dependency, so you can skip to step 2 of our Getting Started with iOS Data Capture guide: [Add the Plugin Properties](https://help.fullstory.com/hc/en-us/articles/360042772333-Getting-Started-with-iOS-Data-Capture#01FX61TBJ8FAD9CWBMY31DWSTH)
