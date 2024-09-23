enum FSLogLevel {
  // Note: the order matters; the index is used to match to the appropriate value in the android and ios platform code
  log, // verbose on android, clamps to debug on iOS
  debug,
  info, // default
  warn,
  error
  // , assert // error on Android. Disabled because it's a reserved keyword in dart
  ;
}
