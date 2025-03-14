// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_module/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MiniView smoke test', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    expect(find.text('Fullstory SDK version: null'), findsOneWidget);
  });
}
