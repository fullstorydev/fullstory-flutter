import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fullstory_flutter/fullstory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _fs =
      FullstoryFlutter(); // todo: make this static instead of an instance

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _fs.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fullstory Flutter test app'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            CaptureStatus(fs: _fs),
            const Divider(),
            Log(),
            const Divider(),
            Text('Running on: $_platformVersion\n'),
          ],
        ),
      ),
    );
  }
}

class Log extends StatefulWidget {
  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  var level = FSLogLevel.info;
  var message = "";
  final _fs =
      FullstoryFlutter(); // todo: make this static instead of an instance

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Log message...',
        ),
        onChanged: (value) => message = value,
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
                _fs.log(message: message, level: level);
              },
              child: const Text('Log'))
        ],
      ),
    ]);
  }
}

class CaptureStatus extends StatelessWidget {
  const CaptureStatus({
    super.key,
    required FullstoryFlutter fs,
  }) : _fs = fs;

  final FullstoryFlutter _fs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(onPressed: _fs.shutdown, child: const Text("shutdown")),
        TextButton(onPressed: _fs.restart, child: const Text("restart")),
      ],
    );
  }
}
