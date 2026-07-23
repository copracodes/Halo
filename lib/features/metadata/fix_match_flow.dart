import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'fix_match_sheet.dart';
import 'manual_match.dart';

/// Opens the live search, and — if the user picks an entry — applies it as a
/// manual match, showing progress and reporting the outcome. Shared by the
/// detail screens' "Fix match" and the Needs review list so the flow (and its
/// offline handling) is written once.
Future<void> runFixMatch(
  BuildContext context,
  WidgetRef ref, {
  required String matchKey,
  required String parsedTitle,
  required bool isMovie,
}) async {
  final result = await showFixMatchSheet(
    context,
    initialQuery: parsedTitle,
    isMovie: isMovie,
  );
  if (result == null || !context.mounted) return;

  await _applyWithProgress(
    context,
    ref,
    () {
      final service = ref.read(manualMatchServiceProvider);
      return isMovie
          ? service.applyMovieMatch(matchKey, result.id)
          : service.applyShowMatch(matchKey, result.id);
    },
  );
}

/// Re-fetches the current match from TMDB, keeping a manual choice intact.
Future<void> runRefreshMetadata(
  BuildContext context,
  WidgetRef ref, {
  required String matchKey,
  required bool isMovie,
}) {
  return _applyWithProgress(
    context,
    ref,
    () {
      final service = ref.read(manualMatchServiceProvider);
      return isMovie ? service.refreshMovie(matchKey) : service.refreshShow(matchKey);
    },
  );
}

/// Runs [action] behind a modal spinner, then reports its outcome in a snackbar.
Future<void> _applyWithProgress(
  BuildContext context,
  WidgetRef ref,
  Future<ManualMatchStatus> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    ),
  );

  ManualMatchStatus status;
  try {
    status = await action();
  } on Object {
    status = ManualMatchStatus.failed;
  }

  navigator.pop(); // dismiss the spinner
  messenger.showSnackBar(
    SnackBar(
      content: Text(status.message),
      duration: const Duration(seconds: 3),
    ),
  );
}
