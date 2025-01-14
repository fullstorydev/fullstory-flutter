import 'package:fullstory_flutter/src/fullstory_flutter_platform_interface.dart';

/// Fullstory Page object
///
/// Do not create instances of the Page class directly!
/// Call `FS.page()` and it will return an instance of this class that's linked to an instance in the native side.

class FSPage {
  // The ID is used to ensure match the Dart page object to it's counterpart in Swift/Kotlin
  final Future<int> _id;

  // This should ensure the matching FSPage from the Android/iOS SDK is released.
  // Dart's documentation stresses that this is unreliable, but it seems to work well enough in practice.
  // (Also, pages typically last the duration of the app.)
  static final Finalizer<int> _finalizer = Finalizer((pageId) {
    FullstoryFlutterPlatform.instance.releasePage(pageId);
  });

  /// Do not create instances of the Page class directly!
  /// Call `FS.page()` and it will return an instance of this class that's linked to an instance in the native side.
  FSPage(this._id) {
    _id.then((value) => _finalizer.attach(this, value, detach: this));
  }

  /// Start the current page. May be called multiple times if the page is visited more than once.
  Future<void> start() async {
    return FullstoryFlutterPlatform.instance.startPage(await _id);
  }

  /// End the current page. Optional. Starting a different page implicitly ends the current one.
  Future<void> end() async {
    return FullstoryFlutterPlatform.instance.endPage(await _id);
  }

  /// Merge the given properties into the page's existing properties (if any).
  Future<void> updateProperties(Map<String, Object?> properties) async {
    return FullstoryFlutterPlatform.instance
        .updatePageProperties(await _id, properties);
  }

  /// Free the native Fullstory Android/iOS SDK FSPage object that is linked to this Dart object.
  ///
  /// This should only be called when a page is no longer needed, to allow the native counterpart to be garbage collected.
  /// This call is optional - usually Dart automatically handles this correctly.
  void dispose() {
    _finalizer.detach(this);
    _id.then((value) => FullstoryFlutterPlatform.instance.releasePage(value));
  }
}
