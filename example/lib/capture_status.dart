import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

class CaptureStatus extends StatefulWidget {
  const CaptureStatus({
    super.key,
  });

  @override
  State<CaptureStatus> createState() => _CaptureStatusState();
}

class _CaptureStatusState extends State<CaptureStatus> with FSStatusListener {
  var status = "Loading...";
  var url = "";
  var id = "";
  var urlNow = "Press button to update";

  @override
  void initState() {
    super.initState();

    // grab the current session URL & ID in case it has already started
    FS.getCurrentSessionURL().then((url) => setState(() {
          if (url != null) {
            this.url = url;
            status =
                "Started"; // if there is a url, we know the session started
          }
        }));
    FS.getCurrentSession().then((id) => setState(() {
          this.id = id ?? "";
        }));

    // set the status listener to handle future changes
    FS.setStatusListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    FS.setStatusListener(
        null); // clear the current status listener (there can be only one!)
  }

  @override
  void onFSSession(String url) {
    setState(() {
      status = "Started";
      this.url = url;
      FS.getCurrentSession().then((id) => setState(() {
            this.id = id ?? "";
          }));
    });
  }

  // @override
  // void onFSShutdown() {
  //   setState(() {
  //     status = "Shutdown";
  //     url = "";
  //     id = "";
  //   });
  // }

  // @override
  // void onFSError() {
  //   setState(() {
  //     status = "Error";
  //     url = "";
  //     id = "";
  //   });
  // }

  // todo onFSDisabled

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
                  FS.getCurrentSessionURL(true).then((url) => setState(() {
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
