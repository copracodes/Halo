import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../library/media_display.dart';
import 'player_screen.dart';

/// Opens an indexed library file in the full-screen player.
///
/// Library files are identified by their SAF `content://` URI, which is both the
/// playback source and the stable resume key — unlike ad-hoc picked files, whose
/// path changes on every pick. Set [autoResume] for continue-watching entry
/// points, where the tap has already answered the resume question.
Future<void> playMediaFile(
  BuildContext context,
  MediaFile file, {
  bool autoResume = false,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PlayerScreen(
        path: file.filePath,
        mediaId: file.filePath,
        title: file.playerTitle,
        autoResume: autoResume,
      ),
    ),
  );
}
