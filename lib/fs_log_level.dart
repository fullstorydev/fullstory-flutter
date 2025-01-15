/// Log levels. Controls how logs appear in the Dev tools > Console section of a Fullstory session replay
///
/// These correspond to the levels shown in session replay,
/// not the the levels used in Android/iOS logging.
enum FSLogLevel {
  // Note: the order matters; the index is used to match to the appropriate value in the android and ios platform code

  /// Lower than default level logging.
  ///
  /// Equivalent to debug level on Android and iOS.
  log,

  /// Info log level, default
  info,

  /// Warn log level
  warn,

  /// Error log level.
  ///
  /// Will appear in in both the console and the event list in Fullstory
  error,

  // exception, Not currently supported by underlying platforms.
}
