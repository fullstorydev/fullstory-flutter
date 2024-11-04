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
