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
      fsVersion = await FS.fsVersion ?? 'Unknown Fullstory version';
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
