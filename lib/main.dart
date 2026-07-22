import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/repositories/legacy_resume_migration.dart';
import 'data/repositories/progress_repository.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {
  // Required before any media_kit Player is constructed.
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // Open the database once and reuse the same instance for the one-time
  // migration and the provider, so both talk to the same connection.
  final database = AppDatabase();
  await migrateLegacyResume(ProgressRepository(database));

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const HaloApp(),
    ),
  );
}

class HaloApp extends StatelessWidget {
  const HaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      // Dark is the default and primary theme (see CLAUDE.md conventions).
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
