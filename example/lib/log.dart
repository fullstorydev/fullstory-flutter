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
