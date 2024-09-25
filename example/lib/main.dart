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
          await FS.getPlatformVersion() ?? 'Unknown platform version';
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
            const CaptureStatus(),
            const Divider(),
            const Log(),
            const Divider(),
            const Events(),
            const Divider(),
            Text('Running on: $_platformVersion\n'),
          ],
        ),
      ),
    );
  }
}

class Events extends StatelessWidget {
  const Events({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        TextButton(
          onPressed: () => FS.event(name: "Name-only event"),
          child: const Text("Name-only event"),
        ),
        TextButton(
          onPressed: () => FS.event(name: "Many properties event", properties: {
            "string_val": "a string value",
            "int_val": 42,
            "double_val": 0.1,
            "bool_val": true,
            "null_val": null,
            "list_val": [1, 2, 3],
            "map_val": {
              "nested_string": "nested string",
              "nested_map": {"val": true},
            },
            //"mixed_list_val": [4, "a", false], // not supported, error in playback
          }),
          child: const Text("Many properties event"),
        ),
        TextButton(
          onPressed: () => FS.event(name: 'Order Completed', properties: {
            'orderId': '23f3er3d',

            // The products are silently dropped:
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

class Log extends StatefulWidget {
  const Log({super.key});

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  var level = FSLogLevel.info;
  var message = "";

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

class CaptureStatus extends StatelessWidget {
  const CaptureStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        TextButton(onPressed: FS.shutdown, child: Text("Shutdown")),
        TextButton(onPressed: FS.restart, child: Text("Restart")),
      ],
    );
  }
}
