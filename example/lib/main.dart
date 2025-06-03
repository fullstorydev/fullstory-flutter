import 'dart:async';

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
  final errorStream = StreamController<Object?>.broadcast();
  FS.captureErrors(errorHandler: (exception, __) {
    FS.log(message: 'Error handler called');
    errorStream.add(exception);
  });
  runApp(MyApp(errorStream: errorStream.stream));
}

class MyApp extends StatefulWidget {
  final Stream<Object?> errorStream;

  const MyApp({super.key, this.errorStream = const Stream.empty()});

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
              return _CrashNotifier(
                errorStream: widget.errorStream,
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
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

/// Shows a snackbar message when a crash is captured in main() above.
class _CrashNotifier extends StatelessWidget {
  final Widget child;
  final Stream<Object?> errorStream;

  const _CrashNotifier({required this.child, required this.errorStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: errorStream,
        builder: (context, asyncSnapshot) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (asyncSnapshot.hasData) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Crashed successfully, Fullstory capture stopped.'),
                ),
              );
            }
          });
          return child;
        });
  }
}
