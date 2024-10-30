/// Log levels. Controls how logs appear in the Dev tools > Console section of Fullstory
enum FSLogLevel {
  // Note: the order matters; the index is used to match to the appropriate value in the android and ios platform code

  /// Verbose on Android, clamps to Debug on iOS
  log,

  /// Debug log level, currently combined with [Log] in Fullstory's console.
  debug,

  /// Info log level, default
  info,

  /// Warn log level
  warn,

  /// Error log level. Will appear in in both the console and the event list in Fullstory
  error,

  //assert, // treated as error on iOS, not available on Android. Disabled here because it's a reserved keyword in dart.
}
