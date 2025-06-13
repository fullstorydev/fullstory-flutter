import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fullstory_flutter/network/dio.dart' as fs_dio;
import 'package:fullstory_flutter/network/http.dart' as fs_http;
import 'package:http/http.dart';

// Typically, you'd only have one of these two in your app, but since this is
// an example, we include both to demonstrate the related features.
Dio get dio => Dio()..interceptors.add(fs_dio.FSInterceptor());
Client get httpClient => fs_http.fsHttpClient();

/// Demo widget that sends network requests using package:dio and package:http.
class NetworkEvents extends StatelessWidget {
  const NetworkEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => _makeHttpRequest(context),
          child: const Text('Send package:http request'),
        ),
        TextButton(
          onPressed: () => _makeDioRequest(context),
          child: const Text('Send dio request'),
        ),
      ],
    );
  }

  Future<void> _makeHttpRequest(BuildContext context) async {
    final response = await httpClient.get(Uri.parse('https://fullstory.com'));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('package:http got response: ${response.statusCode}'),
        ),
      );
    }
  }

  Future<void> _makeDioRequest(BuildContext context) async {
    final response = await dio.get('https://fullstory.com');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dio got response: ${response.statusCode}'),
        ),
      );
    }
  }
}
