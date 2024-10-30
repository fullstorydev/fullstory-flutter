import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

class Identity extends StatefulWidget {
  const Identity({super.key});

  @override
  State<Identity> createState() => _IdentityState();
}

class _IdentityState extends State<Identity> {
  var level = FSLogLevel.info;
  var uid = "";
  var displayName = "";

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
          hintText: 'uid',
        ),
        onChanged: (value) => setState(() {
          uid = value;
        }),
        // allow the keyboard to be hidden - why is this not the default behavior?
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
                "source": "identify",
                "when": DateTime.now().toString(),
                "displayName": displayName,
                'extraInfo': 'foo'
              });
            },
          ),
          TextButton(
            child: const Text('setUserVars'),
            onPressed: () {
              FS.setUserVars({
                "source": "setUserVars",
                "when": DateTime.now().toString(),
                'displayName': displayName,
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
