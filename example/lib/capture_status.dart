import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

// This uses FS.getCurrentSessionURL() to check if the session has already started
// and creates a FSStatusListener to be notified when a session starts

class CaptureStatus extends StatefulWidget {
  const CaptureStatus({
    super.key,
  });

  @override
  State<CaptureStatus> createState() => _CaptureStatusState();
}

// Use the FSStatusListener mixin on this class
class _CaptureStatusState extends State<CaptureStatus> with FSStatusListener {
  var status = "Loading...";
  var url = "";
  var id = "";
  var urlNow = "Press button to update";

  @override
  void initState() {
    super.initState();

    // grab the current session URL & ID in case it has already started
    FS.currentSessionURL().then((url) => setState(() {
          if (url != null) {
            // if there is a url, we know the session started
            this.url = url;
            status = "Started";
          }
        }));
    FS.currentSession.then((id) => setState(() {
          this.id = id ?? "";
        }));

    // set the status listener to handle future changes
    FS.setStatusListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    // clear the current status listener (there can be only one!)
    FS.setStatusListener(null);
  }

  // This comes from FSStatusListener - the default implementation is a no-op
  @override
  void onFSSession(String url) {
    setState(() {
      status = "Started";
      this.url = url;
      FS.currentSession.then((id) => setState(() {
            this.id = id ?? "";
          }));
    });
  }
  // Other events (session ended, disabled, error, etc.) are not currently supported, but may be added in a future version of the library

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          children: [
            TextButton(
                onPressed: () {
                  FS.shutdown();
                  // manually do this one since only the iOS SDK has a callback for it
                  setState(() {
                    status = "Shutdown";
                    url = "";
                    id = "";
                  });
                },
                child: const Text("Shutdown")),
            const TextButton(onPressed: FS.restart, child: Text("Restart")),
            TextButton(
                onPressed: () {
                  FS.currentSessionURL(now: true).then((url) => setState(() {
                        urlNow = url ?? "";
                      }));
                },
                child: const Text("Update Timestamped URL"))
          ],
        ),
        SelectableText("Status: $status\nURL: $url\nNow: $urlNow\nID: $id"),
      ],
    );
  }
}
