import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../library/media_display.dart';
import 'player_screen.dart';
import 'resume_behavior.dart';

/// Opens an indexed library file in the full-screen player.
///
/// Library files are identified by their SAF `content://` URI, which is both the
/// playback source and the stable resume key — unlike ad-hoc picked files, whose
/// path changes on every pick. [behavior] says what to do with a saved
/// position: ask, continue silently, or start from the beginning.
Future<void> playMediaFile(
  BuildContext context,
  MediaFile file, {
  ResumeBehavior behavior = ResumeBehavior.ask,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PlayerScreen(
        path: file.filePath,
        mediaId: file.filePath,
        title: file.playerTitle,
        behavior: behavior,
      ),
    ),
  );
}
