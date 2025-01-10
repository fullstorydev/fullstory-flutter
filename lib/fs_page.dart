import 'package:fullstory_flutter/src/fullstory_flutter_platform_interface.dart';

/// Fullstory Page object
class FSPage {
  // The ID is used to ensure match the Dart page object to it's counterpart in Swift/Kotlin
  final int _id;

  // This should ensure the matching FSPage from the Android/iOS SDK is released.
  // Dart's documentation stresses that this is unreliable, but it seems to work well enough in practice.
  // (Also, pages typically last the duration of the app.)
  static final Finalizer<int> _finalizer = Finalizer((pageId) {
    FullstoryFlutterPlatform.instance.releasePage(pageId);
  });

  /// Do not create instances of the Page class directly!
  /// Call `FS.page()` and it will return an instance of this class that's linked to an instance in the native side.
  FSPage(this._id) {
    _finalizer.attach(this, _id, detach: this);
  }

  /// Start the current page. May be called multiple times if the page is visited more than once.
  Future<void> start() {
    return FullstoryFlutterPlatform.instance.startPage(_id);
  }

  /// End the current page. Optional. Starting a different page implicitly ends the current one.
  Future<void> end() {
    return FullstoryFlutterPlatform.instance.endPage(_id);
  }

  /// Merge the given properties into the page's existing properties (if any).
  Future<void> updateProperties(Map<String, dynamic> properties) {
    return FullstoryFlutterPlatform.instance
        .updatePageProperties(_id, properties);
  }

  /// Free the native Fullstory Android/iOS SDK FSPage object that is linked to this Dart object.
  ///
  /// This should only be called when a page is no longer needed, to allow the native counterpart to be garbage collected.
  /// This call is optional - usually Dart automatically handles this correctly.
  void dispose() {
    _finalizer.detach(this);
    FullstoryFlutterPlatform.instance.releasePage(_id);
  }
}
