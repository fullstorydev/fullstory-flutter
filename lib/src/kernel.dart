import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fullstory_flutter/fullstory_flutter.dart';
import 'package:fullstory_flutter/src/attributes.dart';
import 'package:fullstory_flutter/src/blocking/block.dart';
import 'package:fullstory_flutter/src/blocking/fetch.dart';
import 'package:fullstory_flutter/src/platform/fullstory_flutter_platform_interface.dart';

import 'logging.dart';
import 'native.dart';
import 'pointers.dart';
import 'view_scanner.dart';

class Kernel implements HostCallbacks, FSStatusListener {
  final native = NativeInterface();
  final _ruleFetcher = BlockRulesFetcher(FullstoryFlutterPlatform.instance);
  late final Scanner scanner;
  late final attributeTracker = AttributeTracker(native);
  final viewBlocker = ViewBlocker();
  late final pointerReceiver = PointerReceiver(
    scanner,
    attributeTracker,
    native,
    viewBlocker,
  );

  bool _initialized = false;
  bool _registered = false;

  bool _firstFlutterFrame = true;
  bool _scanning = false;

  bool get hideElements => _hideElements;
  set hideElements(bool value) {
    _hideElements = value;
    scanner.hideElements = value;
  }

  bool _hideElements = true;
  bool get logScanMetrics => scanner.logMetrics;
  set logScanMetrics(bool value) {
    scanner.logMetrics = value;
  }

  static Kernel? _singletonInstance;
  static Kernel singleton() {
    _singletonInstance ??= Kernel._();
    return _singletonInstance!;
  }

  Kernel._() {
    FullstoryBinding.ensureInitialized();
    scanner = Scanner(
      this,
      FullstoryBinding.instance,
      attributeTracker,
      viewBlocker,
    );
  }

  @override
  Future<FlutterScanResult> scanUi(ScanMode mode, bool consent) async {
    try {
      if (mode == ScanMode.idle) {
        return FlutterScanResult.empty;
      }

      if (_scanning) {
        Logger.log(LogLevel.error, 'scan already in progress, skipping scan');
        return FlutterScanResult.withError('Scan already in progress');
      }
      _scanning = true;

      if (!await _ruleFetcher.ensureReady(scanner)) {
        return FlutterScanResult.withError('Blocking not configured');
      }

      bool isKeyframe = true;
      if (_firstFlutterFrame) {
        _firstFlutterFrame = false;
      } else {
        isKeyframe = mode == ScanMode.first || mode == ScanMode.keyframe;
        if (isKeyframe) native.stringTable.reset();
      }

      scanner.consentStatus = consent;

      Logger.log(LogLevel.debug, 'scanUi $mode, consent: $consent');

      final output = await scanner.scan(!isKeyframe);

      return FlutterScanResult(
        views: output.views ?? Uint8List(0),
        canvases: output.drawings ?? Uint8List(0),
        blockedRegions: output.blockedRegions ?? [],
        strings: native.stringTable.entries,
      );
    } catch (e, stack) {
      Logger.log(LogLevel.error, 'scan ui failed');
      Logger.log(LogLevel.error, e.toString());
      Logger.log(LogLevel.error, stack.toString());
      return FlutterScanResult.withError('Scan failed: $e');
    } finally {
      _scanning = false;
    }
  }

  @override
  void onFSSession(String url) {
    Logger.log(LogLevel.note, 'FS Session started with URL: $url');
    if (url.isNotEmpty) {
      _register();
    }
  }

  void init() {
    if (_initialized) return;
    _initialized = true;
    FullstoryFlutterPlatform.instance.setUpCallbacks(this);
    FS.addStatusListener(this);
    _registerIfReady();
  }

  Future<void> _registerIfReady() async {
    final url = await FS.currentSessionURL();
    if (url != null && url.isNotEmpty) {
      _register();
    }
  }

  Future<void> _register() async {
    if (_registered) return;
    _registered = true;
    pointerReceiver.register();

    Logger.log(LogLevel.debug, 'Registering Flutter plugin with host SDK');
    await native.register();
    _ruleFetcher.startFetch(scanner);
    FS.removeStatusListener(this);
  }
}
