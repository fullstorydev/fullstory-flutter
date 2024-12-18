<!-- this file is generated, see ../generate_example_md.sh -->

# fullstory_flutter Examples
From https://github.com/fullstorydev/fullstory-flutter/tree/main/example/lib

* [capture_status.dart](#capture_statusdart)
* [events.dart](#eventsdart)
* [fs_version.dart](#fs_versiondart)
* [identity.dart](#identitydart)
* [log.dart](#logdart)
* [main.dart](#maindart)
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
    FS.getCurrentSessionURL().then((url) => setState(() {
          if (url != null) {
            // if there is a url, we know the session started
            this.url = url;
            status = "Started";
          }
        }));
    FS.getCurrentSession().then((id) => setState(() {
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
      FS.getCurrentSession().then((id) => setState(() {
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
                  FS.getCurrentSessionURL(true).then((url) => setState(() {
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
      fsVersion = await FS.fsVersion() ?? 'Unknown Fullstory version';
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
import 'package:fullstory_flutter_example/webview.dart';

import 'capture_status.dart';
import 'identity.dart';
import 'log.dart';
import 'events.dart';
import 'fs_version.dart';

// Example app that demonstrates use of most Fullstory APIs

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    CaptureStatus(),
    Identity(),
    Log(),
    Events(),
    FSVersion(),
    WebView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        body: _pages[_selectedIndex],
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
                for (var i = 0; i < _pages.length; i++)
                  ListTile(
                    title: Text(_pages[i].toString()),
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

## webview.dart
```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Basic webview example.
// No Fullstory APIs are used here, and the webview's contents are not currently visible in playback.

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
      ..loadRequest(
        Uri.parse('https://www.fullstory.com/'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
```

