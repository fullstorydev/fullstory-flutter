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
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}

const html = '''
<html>
  <head>
    <title>WebView Example</title>
    <style>
      body {
        font-family: sans-serif;
        text-align: center;
        padding: 20px;
      }

      h1 {
        font-size: 5rem;
      }

      p {
        font-size: 2rem;
      }
    </style>
  </head>
  <body>
    <h1>WebView Example</h1>
    <p>This is a simple webview example.</p>
    <p>Fullstory should work here.</p>
  </body>
</html>
''';
