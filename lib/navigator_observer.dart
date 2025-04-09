import 'package:flutter/widgets.dart';
import 'package:fullstory_flutter/fs.dart';

/// Function used to generate or update properties for a page
/// when transitioning from [previous] to [current].
///
/// [previous] will be null for the first page in the app.
typedef PagePropertiesFactory = Map<String, Object?>? Function(
    Route<dynamic> current, Route<dynamic>? previous);

/// A [NavigatorObserver] that tracks [Navigator] page transitions
/// and captures them in Fullstory.
///
/// Pages are automatically created, started and cached for reuse
/// as the user navigates through the app.
class FSNavigatorObserver extends NavigatorObserver {
  final _namedPages = <String, FSPage>{};

  /// Generates page names to be sent to Fullstory from [Route]s.
  ///
  /// The name should be consistent for each logical page or section in your
  /// app.
  /// See [FS.page] for more details, and [namePageDefault] for an example
  /// implementation.
  final String Function(Route<dynamic>) namePage;

  /// Generates page properties to set when a page is created with [FS.page]
  ///
  /// Only called when the page is visited for the first time.
  final PagePropertiesFactory initialProperties;

  /// Generates page properties to pass to [FSPage.updateProperties] with on a
  /// subsequent visit.
  ///
  /// Returned properties will be merged with the existing properties.
  final PagePropertiesFactory updateProperties;

  /// Creates a [FSNavigatorObserver].
  ///
  /// [namePageDefault] is the default value for [namePage].
  /// [propertiesDefault] is the default value for [initialProperties] and
  /// [updateProperties].
  FSNavigatorObserver({
    this.namePage = namePageDefault,
    this.initialProperties = propertiesDefault,
    this.updateProperties = propertiesDefault,
  });

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    final cached = _namedPages[topRoute.settings.name];
    if (cached != null) {
      final properties = updateProperties(topRoute, previousTopRoute);
      cached.start(propertyUpdates: properties);
      return;
    }

    final name = namePage(topRoute);
    final properties = initialProperties(topRoute, previousTopRoute);
    final page = FS.page(name, properties: properties);
    _namedPages[name] = page;
    page.start();
  }
}

/// Default page name generator. Uses the name set in [RouteSettings],
/// such as with [Navigator.pushNamed].
///
/// If names are not set (such as using [Navigator.push]),
/// the page will show as 'unknown' in Fullstory.
String namePageDefault(Route<dynamic> route) {
  return route.settings.name ?? 'unknown';
}

/// Default null [PagePropertiesFactory].
Map<String, Object?>? propertiesDefault(Route<dynamic> current, Route<dynamic>? previous) {
  return null;
}
