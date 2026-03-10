import 'dart:async';
import 'dart:io';

import 'package:fullstory_flutter/src/logging.dart';
import 'package:fullstory_flutter/src/platform/fullstory_flutter_platform_interface.dart';
import 'package:fullstory_flutter/src/view_scanner.dart';



class BlockRulesFetcher {
  Completer<bool> _blockingConfigured = Completer();
  bool _retriedBlockingInit = false;

  final FullstoryFlutterPlatform _platform;

  BlockRulesFetcher(this._platform);

  void startFetch(Scanner scanner) async {
    try {
      if (Platform.isAndroid) {
        final privacyRules = await _platform.fetchPrivacyRules();

        if (privacyRules == null) {
          Logger.log(
            LogLevel.warning,
            "No privacy rules available, skipping configuration.",
          );
          _blockingConfigured.complete(false);
          return;
        }
        _blockingConfigured.complete(scanner.initBlocking(privacyRules));
        return;
      } else {
        final sessionData = await _platform.fetchSessionData();

        if (sessionData == null) {
          Logger.log(
            LogLevel.warning,
            "No session data available, skipping configuration.",
          );
          _blockingConfigured.complete(false);
          return;
        }

        _blockingConfigured.complete(
          scanner.initBlockingFromSession(sessionData),
        );
      }
    } catch (e) {
      Logger.log(LogLevel.error, "Error fetching block rules: $e");
      _blockingConfigured.complete(false);
    }
  }









  Future<bool> ensureReady(Scanner scanner) async {
    try {
      final ready = await _blockingConfigured.future.timeout(
        Duration(milliseconds: Scanner.maxScanMs),
      );
      if (ready) {
        return true;
      }
    } on TimeoutException {
      Logger.log(
        LogLevel.warning,
        "Blocking configuration timed out, skipping scan.",
      );
      return false;
    }

    if (!_retriedBlockingInit) {
      Logger.log(LogLevel.warning, "Block rule fetch failed, retrying.");
      _retriedBlockingInit = true;
      _blockingConfigured = Completer();
      startFetch(scanner);
      return false;
    }
    Logger.log(
      LogLevel.error,
      "Block rule fetch failed again, removing Flutter from all future scans.",
    );
    _platform.setUpCallbacks(null);
    return false;
  }
}
