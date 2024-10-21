// Note: all methods here are no-ops.
// API users can override the ones they care about and leave the default no-op implementation for the others
mixin FSStatusListener {
  void onFSSession(String url) {
    // session started
  }

  // Omitting these for now since shutdown is iOS only and error has some differences between Android and iOS
  // void onFSShutdown() {
  //   // session ended cleanly
  // }

  // // todo: reason code
  // void onFSError() {
  //   // an error occurred, likely ending the session
  // }
  // // todo: disabled (or just reuse error?)
}
