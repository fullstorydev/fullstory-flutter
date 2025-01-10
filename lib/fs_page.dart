import 'package:fullstory_flutter/src/fullstory_flutter_platform_interface.dart';

/// Fullstory Page object
class FSPage {
  // The ID is used to ensure match the Dart page object to it's counterpart in Swift/Kotlin
  final int _id;

  //
  static final Finalizer<int> _finalizer = Finalizer((pageId) {
    FullstoryFlutterPlatform.instance.releasePage(pageId);
  });

  /// Do not create instances of the Page class directly!
  /// Call `FS.page()` and it will return an instance of this class that's linked to an instance in the native side.
  FSPage(this._id) {
    _finalizer.attach(this, _id, detach: this);
  }

  /// Start the current page. Must be called to use the Pages API
  Future<void> start() {
    return FullstoryFlutterPlatform.instance.startPage(_id);
  }

  /// End the current page. Optional. Starting a different page implicitly ends the current one.
  Future<void> end() {
    return FullstoryFlutterPlatform.instance.endPage(_id);
  }

  /// Merge the given properties into the page's existing properties (if any)
  Future<void> updateProperties(Map<String, dynamic> properties) {
    return FullstoryFlutterPlatform.instance
        .updatePageProperties(_id, properties);
  }

  /// This should only be called when a page is no longer needed, to allow the swift/kotlin counterpart to be garbage collected
  void dispose() {
    _finalizer.detach(this);
    FullstoryFlutterPlatform.instance.releasePage(_id);
  }
}
