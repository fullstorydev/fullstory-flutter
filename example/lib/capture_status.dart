import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

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
