import 'package:flutter/material.dart';
import 'package:fullstory_flutter_example/webview.dart';

import 'capture_status.dart';
import 'identity.dart';
import 'log.dart';
import 'events.dart';
import 'fs_version.dart';

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
