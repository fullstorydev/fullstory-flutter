import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

class Identity extends StatefulWidget {
  const Identity({super.key});

  @override
  State<Identity> createState() => _IdentityState();
}

class _IdentityState extends State<Identity> {
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
