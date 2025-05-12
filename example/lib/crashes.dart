import 'package:flutter/material.dart';

/// Demonstrates how crashes are captured by the top level error handler
/// set in main.dart.
class Crashes extends StatelessWidget{
  const Crashes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            throw Exception('Test exception');
          },
          child: const Text('Throw exception'),
        ),
        TextButton(
          onPressed: () async {
            throw Exception('Async test exception');
          },
          child: const Text('Throw async exception'),
        ),
      ],
    );
  }
}
