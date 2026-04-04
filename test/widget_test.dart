import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kaamsathi/app.dart';
import 'package:kaamsathi/core/network/dio_provider.dart';

import 'support/test_dio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  testWidgets('Splash → login', (WidgetTester tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(createTestDio()),
        ],
        child: const KaamSathiApp(),
      ),
    );
    await tester.pump();
    for (int i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.textContaining('Welcome'), findsWidgets);
  });
}
