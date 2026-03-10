import 'package:flutter/foundation.dart';
enum LogLevel {
  error('  ERROR', 0),
  warning('WARNING', 1),
  note('   Note', 2),
  debug('  debug', 3),
  verbose('  noisy', 4);
  final String indicator;

  final int verbosity;

  const LogLevel(this.indicator, this.verbosity);

  void log(String message) => Logger.log(this, message);

  void logLess(String message) => Logger.logLess(this, message);
}


class Logger {


  static LogLevel minLogged = LogLevel.note;

  static void log(LogLevel level, String message) {
    if (level.verbosity > minLogged.verbosity) return;
    debugPrint("Fullstory: ${level.indicator}: $message");
  }

  static final _loggedMessages = <String>{};





  static void logLess(LogLevel level, String message) {
    if (level.verbosity <= minLogged.verbosity) {
      if (_loggedMessages.length >= 1024) {
        _loggedMessages.clear();
        log(
          LogLevel.warning,
          'Log cache cleared, limited logs will be reprinted',
        );
      }
      if (_loggedMessages.add(message)) {
        log(level, message);
      }
    }
  }
}
