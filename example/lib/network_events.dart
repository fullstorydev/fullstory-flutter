import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fullstory_dio/fullstory_dio.dart';

/// Demo widget that sends network requests using package:dio and package:http.
class NetworkEvents extends StatelessWidget {
  const NetworkEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => _makeDioRequest(context),
          child: const Text('Send dio request'),
        ),
      ],
    );
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

// This is declared at the top-level to allow [NetworkEvents] to be const.
Dio get dio => Dio()..interceptors.add(FullstoryInterceptor());
