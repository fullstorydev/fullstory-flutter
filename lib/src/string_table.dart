

class StringTable {
  final _table = <String, int>{};
  var _entries = <String>[];
  void reset() {
    _table.clear();
    _entries = [];
  }

  List<String> get entries => List.from(_entries);



  int idOf(String string) {
    final interned = _table[string];
    if (interned != null) return interned;
    final newId = _table.length + 1;
    _table[string] = newId;
    _entries.add(string);

    return newId;
  }
}
