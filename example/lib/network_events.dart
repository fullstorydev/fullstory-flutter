import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
Dio get dio => Dio()
  ..interceptors.add(FullstoryInterceptor(
    computeRequestSize: (rq) => _utf8BytesOf(rq.data),
    computeResponseSize: (rs) => _utf8BytesOf(rs?.data),
  ));

int _utf8BytesOf(dynamic data) {
  print('data type: ${data.runtimeType}');
  if(data == null) return 0;
  if(data is Uint8List) data.length;

  final str = data.toString();
  if (str.isEmpty) return 0;

  return _utf8.encode(str).length;
}

const _utf8 = Utf8Codec();
