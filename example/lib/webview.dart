import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Basic webview example.
// Native Fullstory handles webviews, as long as Flutter allows JS there.

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
      // To allow Fullstory in your Flutter webview, ensure JS is unrestricted
      // so that Fullstory can inject its JS. Otherwise, you will only see
      // a message about disabled JS in replay.
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://www.fullstory.com/'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
