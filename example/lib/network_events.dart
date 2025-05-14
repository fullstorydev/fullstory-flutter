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
final dio = Dio()
  ..interceptors.add(FullstoryInterceptor(
    // Dart strings are UTF-16 encoded, so code units may be 2-4 bytes in size.
    // This is just an approximation, and probably not accurate if you send 
    // over the wire as UTF-8!
    computeRequestSize: (rq) => 3 * (rq.data?.toString().length ?? 0),
    computeResponseSize: (rs) => 3 * (rs.data?.toString().length ?? 0),
  ));
