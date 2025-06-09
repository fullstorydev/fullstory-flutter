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
