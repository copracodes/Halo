import '../../core/constants/app_constants.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../../data/repositories/subtitle_repository.dart';
import 'folder_access/folder_access.dart';
import 'parser/filename_parser.dart';
import 'subtitle_matching.dart';

/// Outcome of scanning a single folder.
class FolderScanResult {
  const FolderScanResult({required this.found, required this.removed});

  /// Number of video files present in the folder after the scan.
  final int found;

  /// Number of previously-indexed files that were removed (gone from disk).
  final int removed;
}

/// Indexes local video files in place: walks a library folder via
/// [FolderAccess], upserts discovered videos into the database, and prunes rows
/// for files that no longer exist. Never moves or copies media.
///
/// The heavy work is I/O — folder enumeration crosses a platform channel (native
/// thread) and database writes run on drift's background isolate — so scanning
/// stays off the UI thread without an explicit isolate, which the Storage Access
/// Framework couldn't be called from anyway.
class LibraryScanner {
  const LibraryScanner(this._folderAccess, this._library, this._subtitles,
      [this._parser = const FilenameParser()]);

  final FolderAccess _folderAccess;
  final LibraryRepository _library;
  final SubtitleRepository _subtitles;
  final FilenameParser _parser;

  /// Scans [folder], upserting each video file found and removing rows for
  /// files that have disappeared. [onFileFound] reports incremental progress
  /// (the running count of video files seen) so the UI can show live feedback.
  Future<FolderScanResult> scanFolder(
    LibraryFolder folder, {
    void Function(int found)? onFileFound,
  }) async {
    final seen = <String>{};
    final videos = <ScannedFile>[];
    final subtitles = <ScannedFile>[];
    final videoIdByUri = <String, int>{};
    var found = 0;

    await for (final file in _folderAccess.listFiles(folder.path)) {
      if (_isVideo(file.name)) {
        seen.add(file.uri);
        videos.add(file);
        // The library root is the outermost context for folder-based parsing.
        final parsed = _parser.parse(
          file.name,
          parentFolders: [...file.parentPath, folder.displayName],
        );
        videoIdByUri[file.uri] = await _library.upsertMediaFile(
          folderId: folder.id,
          filePath: file.uri,
          fileName: file.name,
          fileSize: file.size,
          dateModified: file.lastModified > 0
              ? DateTime.fromMillisecondsSinceEpoch(file.lastModified)
              : null,
          mediaType: parsed.mediaType,
          parsedTitle: parsed.title,
          parsedYear: parsed.year,
          parsedSeason: parsed.season,
          parsedEpisode: parsed.episode,
          parsedEpisodeEnd: parsed.episodeEnd,
        );
        found++;
        onFileFound?.call(found);
      } else if (isSubtitleFile(file.name)) {
        subtitles.add(file);
      }
    }

    final removed = await _library.removeMissingMediaFiles(folder.id, seen);
    await _linkSidecars(videos, subtitles, videoIdByUri);
    return FolderScanResult(found: found, removed: removed);
  }

  /// Refreshes each video's sidecar subtitle associations from what the scan
  /// found. Every scanned video is refreshed — including those with no
  /// sidecars — so a subtitle that was renamed or removed drops its stale link.
  Future<void> _linkSidecars(
    List<ScannedFile> videos,
    List<ScannedFile> subtitles,
    Map<String, int> videoIdByUri,
  ) async {
    final byVideo = <String, List<({String uri, String? lang})>>{};
    for (final link in linkSubtitles(videos: videos, subtitles: subtitles)) {
      byVideo
          .putIfAbsent(link.videoUri, () => [])
          .add((uri: link.subtitleUri, lang: link.lang));
    }
    for (final entry in videoIdByUri.entries) {
      await _subtitles.replaceSidecars(
        entry.value,
        byVideo[entry.key] ?? const [],
      );
    }
  }

  /// Re-runs the filename parser over every already-indexed row, updating the
  /// parsed* fields in place. No disk access — cheap enough to run on demand
  /// after tuning the parser. Returns the number of rows reparsed.
  Future<int> reparseAll({void Function(int done)? onProgress}) async {
    final all = await _library.allMedia();
    var done = 0;
    for (final media in all) {
      final parsed = _parser.parse(media.fileName);
      await _library.updateParsed(
        media.id,
        mediaType: parsed.mediaType,
        parsedTitle: parsed.title,
        parsedYear: parsed.year,
        parsedSeason: parsed.season,
        parsedEpisode: parsed.episode,
        parsedEpisodeEnd: parsed.episodeEnd,
      );
      done++;
      onProgress?.call(done);
    }
    return all.length;
  }

  static bool _isVideo(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return false;
    final ext = fileName.substring(dot + 1).toLowerCase();
    return AppConstants.supportedVideoExtensions.contains(ext);
  }
}
