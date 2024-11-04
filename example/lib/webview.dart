import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Basic webview example.
// No Fullstory APIs are used here, and the webview's contents are not currently visible in playback.

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://www.fullstory.com/'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
