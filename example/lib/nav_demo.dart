import 'package:flutter/material.dart';

/// A second page in the app to demo use of [FullstoryNavigatorObserver].
class NavDemo extends StatelessWidget {
  const NavDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigator Observer Demo'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: const Text('Welcome to the Navigator Observer Demo!\n'
            'Hit back to return to the main screen.'),
      ),
    );
  }
}

/// A small widget with a button to open [NavDemo]
class OpenNavDemo extends StatelessWidget {
  const OpenNavDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/navDemo');
        },
        child: const Text('Open Navigator Observer Demo'),
      ),
    );
  }
}
