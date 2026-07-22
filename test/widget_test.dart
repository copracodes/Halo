// Smoke test for the Halo app shell: with no library folders added, the home
// screen shows the friendly empty state.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/data/tmdb/tmdb_client.dart';
import 'package:halo/data/tmdb/tmdb_providers.dart';
import 'package:halo/features/home/home_screen.dart';
import 'package:halo/features/library/library_providers.dart';

void main() {
  testWidgets('Home shows the empty state when no folders are added',
      (WidgetTester tester) async {
    // Back the auto-scan's DB reads with an in-memory database, and feed the
    // folders stream a fixed empty value so the empty state renders promptly.
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            libraryFoldersProvider
                .overrideWith((ref) => Stream.value(const <LibraryFolder>[])),
            // The auto-scan now kicks off a metadata sync, and a real token is
            // configured on a developer machine — without this the test would
            // make live TMDB requests, which is both slow and flaky. Nothing
            // here should ever touch the network.
            tmdbClientProvider.overrideWith(
              (ref) => TmdbClient(
                token: 'test-token',
                delay: (_) async {},
                httpClient: MockClient(
                  (request) async => http.Response('{}', 200),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      // Let the auto-scan future and the (empty) stream settle.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });

    expect(find.text('Halo'), findsOneWidget);
    expect(find.text('Add your movies folder'), findsOneWidget);
  });
}
