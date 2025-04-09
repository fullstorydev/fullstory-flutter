import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fullstory_flutter/navigator_observer.dart';
import 'package:fullstory_flutter/src/fullstory_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  late FakeFullstoryFlutterPlatform fakePlatform;

  setUp(() {
    fakePlatform = FakeFullstoryFlutterPlatform();
    FullstoryFlutterPlatform.instance = fakePlatform;
  });

  group(FSNavigatorObserver, () {
    test('page created with initial properties', () {
      fakeAsync((async) {
        final observer = FSNavigatorObserver(
          namePage: (route) => 'test_page',
          initialProperties: (_, __) => {'key': 'value'},
        );

        observer.didChangeTop(FakeRoute(), null);
        async.flushMicrotasks();

        expect(fakePlatform.startedPages, ['test_page']);
        expect(fakePlatform.pageProperties.length, 1);
        expect(fakePlatform.pageProperties, {
          'test_page': {'key': 'value'}
        });
      });
    });

    test('page updated with new properties', () {
      fakeAsync((async) {
        final observer = FSNavigatorObserver(
          // Use route.settings.name for pages names since we're using
          // the default namePage
          initialProperties: (_, __) => {'key': 'value'},
          updateProperties: (_, __) => {'new_key': 'new_value'},
        );

        observer.didChangeTop(FakeRoute(name: 'one'), null);
        async.flushMicrotasks();
        observer.didChangeTop(FakeRoute(name: 'one'), FakeRoute(name: 'two'));
        async.flushMicrotasks();

        expect(fakePlatform.startedPages, ['one', 'one']);
        expect(fakePlatform.pageProperties['one'], {'new_key': 'new_value'});
      });
    });
  });

  group('namePageDefault', () {
    test('namePageDefault returns route name', () {
      final observer = FSNavigatorObserver();
      final route = FakeRoute(name: 'test_page');
      final name = observer.namePage(route);
      expect(name, 'test_page');
    });

    test('namePageDefault returns unknown if route name is null', () {
      final observer = FSNavigatorObserver();
      final route = FakeRoute();
      final name = observer.namePage(route);
      expect(name, 'unknown');
    });
  });
}

class FakeFullstoryFlutterPlatform
    with MockPlatformInterfaceMixin, Fake
    implements FullstoryFlutterPlatform {
  final pageProperties = <String, Map<String, Object?>>{};
  final pageIds = <int, String>{};
  var _nextPageId = 0;
  final startedPages = <String>[];
  final releasedPages = <String>[];

  @override
  Future<int> page(String pageName, Map<String, Object?> properties) async {
    final pageId = _nextPageId++;
    pageProperties[pageName] = properties;
    pageIds[pageId] = pageName;
    return pageId;
  }

  @override
  Future<void> startPage(
      int pageId, Map<String, Object?> propertyUpdates) async {
    final name = _nameFor(pageId);
    if (propertyUpdates.isNotEmpty) {
      pageProperties[name] = propertyUpdates;
    }

    startedPages.add(name);
  }

  @override
  Future<void> updatePageProperties(
      int pageId, Map<String, Object?> properties) async {
    final name = _nameFor(pageId);
    pageProperties[name] = properties;
  }

  String _nameFor(int pageId) {
    final name = pageIds[pageId];
    if (name == null) {
      throw Exception('No page with id $pageId');
    }
    return name;
  }

  // Does nothing, but needs to be here since this will be called by
  // FSPage.dispose()
  @override
  Future<void> releasePage(int pageId) async {}
}

class FakeRoute extends Route<dynamic> {
  final String? name;

  FakeRoute({this.name});

  @override
  RouteSettings get settings => RouteSettings(name: name);

  @override
  bool get isCurrent => true;

  @override
  bool get isFirst => false;

  @override
  bool get isActive => true;
}
