<!-- this file is generated, see ../generate_example_md.sh -->

# fullstory_flutter Examples
From https://github.com/fullstorydev/fullstory-flutter/tree/main/example/lib

* [capture_status.dart](#capture_statusdart)
* [crashes.dart](#crashesdart)
* [events.dart](#eventsdart)
* [fs_version.dart](#fs_versiondart)
* [identity.dart](#identitydart)
* [log.dart](#logdart)
* [main.dart](#maindart)
* [nav_demo.dart](#nav_demodart)
* [network_events.dart](#network_eventsdart)
* [pages.dart](#pagesdart)
* [webview.dart](#webviewdart)

## capture_status.dart
```dart
import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

// This uses FS.getCurrentSessionURL() to check if the session has already started
// and creates a FSStatusListener to be notified when a session starts

class CaptureStatus extends StatefulWidget {
  const CaptureStatus({
    super.key,
  });

  @override
  State<CaptureStatus> createState() => _CaptureStatusState();
}

// Use the FSStatusListener mixin on this class
class _CaptureStatusState extends State<CaptureStatus> with FSStatusListener {
  var status = "Loading...";
  var url = "";
  var id = "";
  var urlNow = "Press button to update";

  @override
  void initState() {
    super.initState();

    // grab the current session URL & ID in case it has already started
    FS.currentSessionURL().then((url) => setState(() {
          if (url != null) {
            // if there is a url, we know the session started
            this.url = url;
            status = "Started";
          }
        }));
    FS.currentSession.then((id) => setState(() {
          this.id = id ?? "";
        }));

    // set the status listener to handle future changes
    FS.setStatusListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    // clear the current status listener (there can be only one!)
    FS.setStatusListener(null);
  }

  // This comes from FSStatusListener - the default implementation is a no-op
  @override
  void onFSSession(String url) {
    setState(() {
      status = "Started";
      this.url = url;
      FS.currentSession.then((id) => setState(() {
            this.id = id ?? "";
          }));
    });
  }
  // Other events (session ended, disabled, error, etc.) are not currently supported, but may be added in a future version of the library

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          children: [
            TextButton(
                onPressed: () {
                  FS.shutdown();
                  // manually do this one since only the iOS SDK has a callback for it
                  setState(() {
                    status = "Shutdown";
                    url = "";
                    id = "";
                  });
                },
                child: const Text("Shutdown")),
            const TextButton(onPressed: FS.restart, child: Text("Restart")),
            TextButton(
                onPressed: () {
                  FS.currentSessionURL(now: true).then((url) => setState(() {
                        urlNow = url ?? "";
                      }));
                },
                child: const Text("Update Timestamped URL"))
          ],
        ),
        SelectableText("Status: $status\nURL: $url\nNow: $urlNow\nID: $id"),
      ],
    );
  }
}
```

## crashes.dart
```dart
import 'package:flutter/material.dart';

/// Demonstrates how crashes are captured by the top level error handler
/// set in main.dart.
class Crashes extends StatelessWidget {
  const Crashes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            throw Exception('Test exception');
          },
          child: const Text('Throw exception'),
        ),
        TextButton(
          onPressed: () async {
            throw Exception('Async test exception');
          },
          child: const Text('Throw async exception'),
        ),
      ],
    );
  }
}
```

## events.dart
```dart
import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

// Send custom events to Fullstory
// These will show up in the event list on the right side of session replays

class Events extends StatelessWidget {
  const Events({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        TextButton(
          onPressed: () => FS.event("Name-only event"),
          child: const Text("Name-only event"),
        ),
        TextButton(
          onPressed: () => FS.event("Many properties event", {
            "string_val": "a string value",
            "int_val": 42,
            "double_val": 0.1,
            "bool_val": true,
            "null_val": null,
            "list_val": [1, 2, 3],

            // in playback, this is displayed as:
            // map_val.nested_map.val_bool: true
            // map_val.nested_string_str: nested string
            "map_val": {
              "nested_string": "nested string",
              "nested_map": {"val": true},
            },
            //"mixed_list_val": [4, "a", false], // not supported, error in playback
          }),
          child: const Text("Many properties event"),
        ),
        TextButton(
          onPressed: () => FS.event('Order Completed', {
            'orderId': '23f3er3d',

            // Not fully supported(as of Fullstory v1.54.0) - The products are silently dropped:"
            // "Note: Order Completed Events are not supported in Native Mobile as objects and arrays within arrays are not supported."
            // https://help.fullstory.com/hc/en-us/articles/360020623274-Sending-custom-event-data-into-Fullstory#Order%20Completed%20Events:~:text=Note%3A%20Order%20Completed%20Events%20are%20not%20supported%20in%20Native%20Mobile%20as%20objects%20and%20arrays%20within%20arrays%20are%20not%20supported.
            'products': [
              {'productId': '9v87h4f8', 'price': 20.00, 'quantity': 0.75},
              {'productId': '4738b43z', 'price': 12.87, 'quantity': 6},
            ],
          }),
          child: const Text('Order Completed event'),
        )
      ],
    );
  }
}
```

## fs_version.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullstory_flutter/fs.dart';

// Get the version of the underlying native Fullstory SDK (e.g. '1.54.0')

class FSVersion extends StatefulWidget {
  const FSVersion({super.key});
  @override
  State<FSVersion> createState() => _FSVersionState();
}

class _FSVersionState extends State<FSVersion> {
  String fsVersion = 'Unknown';
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String fsVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      fsVersion = await FS.fsVersion ?? 'Unknown Fullstory version';
    } on PlatformException {
      fsVersion = 'Failed to get Fullstory version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      this.fsVersion = fsVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('Fullstory version: $fsVersion\n');
  }
}
```

## identity.dart
```dart
import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

class Identity extends StatefulWidget {
  const Identity({super.key});

  @override
  State<Identity> createState() => _IdentityState();
}

class _IdentityState extends State<Identity> {
  var level = FSLogLevel.info;
  var uid = '';
  var displayName = '';
  var email = '';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'displayName',
        ),
        onChanged: (value) => setState(() {
          displayName = value;
        }),
        // allow the keyboard to be hidden - why is this not the default behavior?
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
      TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'email',
        ),
        onChanged: (value) => setState(() {
          email = value;
        }),
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
      TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'uid',
        ),
        onChanged: (value) => setState(() {
          uid = value;
        }),
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
      Wrap(
        children: [
          TextButton(
            child: const Text('Identify'),
            onPressed: () {
              FS.identify(uid);
            },
          ),
          TextButton(
            child: const Text('Identify w/ userVars'),
            onPressed: () {
              FS.identify(uid, {
                // email and displayName are used by Fullstory, everything else is arbitrary
                'source': 'identify',
                'when': DateTime.now().toString(),
                'displayName': displayName,
                'email': email,
                'extraInfo': 'foo'
              });
            },
          ),
          TextButton(
            child: const Text('setUserVars'),
            onPressed: () {
              FS.setUserVars({
                // ditto above: email and displayName are used by Fullstory, everything else is arbitrary
                'source': 'setUserVars',
                'when': DateTime.now().toString(),
                'displayName': displayName,
                'email': email,
                'membershipLevel': 'bar'
              });
            },
          ),
          TextButton(
            child: const Text('Anonymize'),
            onPressed: () {
              FS.anonymize();
            },
          ),
        ],
      ),
    ]);
  }
}
```

## log.dart
```dart
import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

class Log extends StatefulWidget {
  const Log({super.key});

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  var level = FSLogLevel.info;
  var message = "";

  // Write extra messages to the Fullstory log
  // What is captured depends on the logLevel setting in iOS & Android
  // All captured logs appear in

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Log message...',
        ),
        onChanged: (value) => message = value,
        // allow the keyboard to be hidden - why is this not the default behavior?
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
      Row(
        children: [
          const Text("Level:"),
          DropdownMenu(
            dropdownMenuEntries: FSLogLevel.values
                .map<DropdownMenuEntry<FSLogLevel>>((FSLogLevel level) {
              return DropdownMenuEntry<FSLogLevel>(
                  value: level, label: level.name);
            }).toList(),
            initialSelection: level,
            onSelected: (value) => level = value!,
          ),
          TextButton(
              onPressed: () {
                FS.log(message: message, level: level);
              },
              child: const Text('Log'))
        ],
      ),
    ]);
  }
}
```

## main.dart
```dart
import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';
import 'package:fullstory_flutter/navigator_observer.dart';
import 'package:fullstory_flutter_example/crashes.dart';
import 'package:fullstory_flutter_example/nav_demo.dart';

import 'capture_status.dart';
import 'identity.dart';
import 'log.dart';
import 'events.dart';
import 'fs_version.dart';
import 'network_events.dart';
import 'webview.dart';
import 'pages.dart';

// Example app that demonstrates use of most Fullstory APIs

void main() {
  FS.captureErrors(errorHandler: (exception, __) {
    // At this point, the error is captured and FS has shut down.
    // No other FS methods can be called, but other behavior like
    // graceful shutdown or user notification can be done here.
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static const _screens = <Widget>[
    CaptureStatus(),
    Identity(),
    Log(),
    Events(),
    Crashes(),
    NetworkEvents(),
    Pages(),
    FSVersion(),
    WebView(),
    OpenNavDemo(),
  ];

  // Create a list of FSPage objects to represent the different screens in the app
  // We'll call .start() on each one when it's associated screen is displayed.
  //
  // Manual calls like this can be intermixed with the
  // [FSNavigatorObserver].
  static final List<FSPage> _pages =
      _screens.map((s) => FS.page(s.toString())).toList();

  _MyAppState() {
    _pages[_selectedIndex].start();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pages[_selectedIndex].start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/navDemo': (_) => const NavDemo(),
      },
      navigatorObservers: [
        FSNavigatorObserver(
          initialProperties: (current, previous) => {
            if (current.settings.name == '/navDemo') 'navDemoFirstVisit': true,
          },
          updateProperties: (current, previous) => {
            if (current.settings.name == '/navDemo') 'navDemoFirstVisit': false,
            'navDemoLaterVisit': true,
          },
        )
      ],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fullstory Flutter test app'),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        body: _screens[_selectedIndex],
        drawer: Builder(builder: (context) {
          return Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              //padding: EdgeInsets.zero,
              children: [
                // generate a list of menu entries from the list of pages
                for (var i = 0; i < _screens.length; i++)
                  ListTile(
                    title: Text(_screens[i].toString()),
                    selected: _selectedIndex == i,
                    onTap: () {
                      // Update the state of the app
                      _onItemTapped(i);
                      // Then close the drawer
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
```

## nav_demo.dart
```dart
import 'package:flutter/material.dart';

/// A second page in the app to demo use of [FullstoryNavigatorObserver].
class NavDemo extends StatelessWidget {
  const NavDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigator Observer Demo'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: const Text('Welcome to the Navigator Observer Demo!\n'
            'Hit back to return to the main screen.'),
      ),
    );
  }
}

/// A small widget with a button to open [NavDemo]
class OpenNavDemo extends StatelessWidget {
  const OpenNavDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/navDemo');
        },
        child: const Text('Open Navigator Observer Demo'),
      ),
    );
  }
}
```

## network_events.dart
```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fullstory_flutter/network/dio.dart' as fs_dio;
import 'package:fullstory_flutter/network/http.dart' as fs_http;
import 'package:http/http.dart';

// Typically, you'd only have one of these two in your app, but since this is
// an example, we include both to demonstrate the related features.
Dio get dio => Dio()..interceptors.add(fs_dio.FSInterceptor());
Client get httpClient => fs_http.fsHttpClient();

/// Demo widget that sends network requests using package:dio and package:http.
class NetworkEvents extends StatelessWidget {
  const NetworkEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => _makeHttpRequest(context),
          child: const Text('Send package:http request'),
        ),
        TextButton(
          onPressed: () => _makeDioRequest(context),
          child: const Text('Send dio request'),
        ),
      ],
    );
  }

  Future<void> _makeHttpRequest(BuildContext context) async {
    final response = await httpClient.get(Uri.parse('https://fullstory.com'));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('package:http got response: ${response.statusCode}'),
        ),
      );
    }
  }

  Future<void> _makeDioRequest(BuildContext context) async {
    final response = await dio.get('https://fullstory.com');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dio got response: ${response.statusCode}'),
        ),
      );
    }
  }
}
```

## pages.dart
```dart
import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

// Note: this is a somewhat odd usage of the Fullstory Pages API, but it exercises the full API.
// See _pages in main.dart for a more typical usage.

class Pages extends StatefulWidget {
  const Pages({
    super.key,
  });

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  FSPage? _currentPage;
  int _pageCounter = 0;

  @override
  void initState() {
    super.initState();
    _createNewPage();
  }

  void _createNewPage() {
    // Create a new page with initial properties
    setState(() {
      // Dispose of the current page before creating a new one
      _currentPage?.dispose();
      _currentPage = FS.page('DemoPage$_pageCounter',
          properties: {'initialKey': 'initialValue'});
      _pageCounter++;
    });
  }

  void _startPage() {
    _currentPage?.start();
  }

  void _startPageWithProperties() {
    _currentPage?.start(propertyUpdates: {'initialKey': 'newValue'});
  }

  void _endPage() {
    _currentPage?.end();
  }

  void _updatePageProperties() async {
    if (_currentPage != null) {
      await _currentPage!.updateProperties({'updatedKey': 'updatedValue'});
    }
  }

  @override
  void dispose() {
    // Dispose of the current page to release the associated Swift/Kotlin page.
    // (This should happen automatically, but Dart's Finalizer doesn't guarantee it. Manually disposing guarantees that creating many short-lived pages won't cause a memory leak.)
    _currentPage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fullstory Pages API'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _createNewPage,
              child: const Text('Create New Page'),
            ),
            ElevatedButton(
              onPressed: _startPage,
              child: Text("Start Page $_pageCounter"),
            ),
            ElevatedButton(
              onPressed: _startPageWithProperties,
              child: Text("Start Page $_pageCounter with properties"),
            ),
            ElevatedButton(
              onPressed: _endPage,
              child: Text("End Page $_pageCounter"),
            ),
            ElevatedButton(
              onPressed: _updatePageProperties,
              child: const Text('Update Page Properties'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## webview.dart
```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Basic webview example.
// Native Fullstory handles webviews, as long as Flutter allows JS there.

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      // To allow Fullstory in your Flutter webview, ensure JS is unrestricted
      // so that Fullstory can inject its JS. Otherwise, you will only see
      // a message about disabled JS in replay.
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}

const html = '''
<html>
  <head>
    <title>WebView Example</title>
    <style>
      body {
        font-family: sans-serif;
        text-align: center;
        padding: 20px;
      }

      h1 {
        font-size: 5rem;
      }

      p {
        font-size: 2rem;
      }
    </style>
  </head>
  <body>
    <h1>WebView Example</h1>
    <p>This is a simple webview example.</p>
    <p>Fullstory should work here.</p>
  </body>
</html>
''';
```

