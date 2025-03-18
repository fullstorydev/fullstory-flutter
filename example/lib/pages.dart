import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

// Note: this is a somewhat odd usage of the Fullstory Pages API, but it exercises the full API.
// See _pages in main.dart for a more typical usage.

class Pages extends StatefulWidget {
  const Pages({
    super.key,
  });

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  FSPage? _currentPage;
  int _pageCounter = 0;

  @override
  void initState() {
    super.initState();
    _createNewPage();
  }

  void _createNewPage() {
    // Create a new page with initial properties
    setState(() {
      // Dispose of the current page before creating a new one
      _currentPage?.dispose();
      _currentPage = FS.page('DemoPage$_pageCounter',
          properties: {'initialKey': 'initialValue'});
      _pageCounter++;
    });
  }

  void _startPage() {
    _currentPage?.start();
  }

  void _startPageWithProperties() {
    _currentPage?.start(propertyUpdates: {'initialKey': 'newValue'});
  }

  void _endPage() {
    _currentPage?.end();
  }

  void _updatePageProperties() async {
    if (_currentPage != null) {
      await _currentPage!.updateProperties({'updatedKey': 'updatedValue'});
    }
  }

  @override
  void dispose() {
    // Dispose of the current page to release the associated Swift/Kotlin page.
    // (This should happen automatically, but Dart's Finalizer doesn't guarantee it. Manually disposing guarantees that creating many short-lived pages won't cause a memory leak.)
    _currentPage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fullstory Pages API'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _createNewPage,
              child: const Text('Create New Page'),
            ),
            ElevatedButton(
              onPressed: _startPage,
              child: Text("Start Page $_pageCounter"),
            ),
            ElevatedButton(
              onPressed: _startPageWithProperties,
              child: Text("Start Page $_pageCounter with properties"),
            ),
            ElevatedButton(
              onPressed: _endPage,
              child: Text("End Page $_pageCounter"),
            ),
            ElevatedButton(
              onPressed: _updatePageProperties,
              child: const Text('Update Page Properties'),
            ),
          ],
        ),
      ),
    );
  }
}
