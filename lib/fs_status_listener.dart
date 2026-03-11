// Note: all methods here are no-ops.
// API users can override the ones they care about and leave the default no-op implementation for the others

/// Fullstory session status listener mixin
mixin FSStatusListener {
  /// Override this to be notified when the Fullstory session has begun
  /// Note: If FS.getCurrentSessionURL() is currently returning a URL, then the session has already begun and onFSSession will not be called unless a new session is started.
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
