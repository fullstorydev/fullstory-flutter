import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

// Note: this is a somewhat odd usage of the Fullstory Pages API, but it exercises the full API.
// todo: create a more normal example that has a page for each screen of this example app

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
    _initializePage();
  }

  Future<void> _initializePage() async {
    // Create a new page with initial properties
    // todo: is await allowed inside a setState callback?
    var nextPage = await FS.page('DemoPage$_pageCounter',
        pageVars: {'initialKey': 'initialValue'});
    setState(() {
      _currentPage = nextPage;
      _pageCounter++;
    });
  }

  void _createNewPage() {
    // Dispose of the current page before creating a new one
    _currentPage?.dispose();
    setState(() {
      _initializePage();
    });
  }

  void _startPageSession() {
    _currentPage?.start();
  }

  void _endPageSession() {
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
        title: const Text('FullStory Pages API'),
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
              onPressed: _startPageSession,
              child: Text("Start Page $_pageCounter"),
            ),
            ElevatedButton(
              onPressed: _endPageSession,
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
