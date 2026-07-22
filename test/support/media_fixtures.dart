// Builders for in-memory [MediaFile] rows, so tests of the pure grouping,
// sorting, and rendering logic don't need a database.

import 'package:halo/data/database/app_database.dart';

/// A media row as the scanner would have written it. Ids are derived from the
/// file name so callers don't have to hand out unique numbers.
MediaFile mediaFile(
  String fileName, {
  MediaType mediaType = MediaType.movie,
  String? parsedTitle,
  int? parsedYear,
  int? parsedSeason,
  int? parsedEpisode,
  int? parsedEpisodeEnd,
  DateTime? dateScanned,
  int fileSize = 0,
}) {
  return MediaFile(
    id: fileName.hashCode,
    folderId: 1,
    filePath: 'content://tree/library/$fileName',
    fileName: fileName,
    fileSize: fileSize,
    dateScanned: dateScanned ?? DateTime(2026, 1, 1),
    mediaType: mediaType,
    parsedTitle: parsedTitle,
    parsedYear: parsedYear,
    parsedSeason: parsedSeason,
    parsedEpisode: parsedEpisode,
    parsedEpisodeEnd: parsedEpisodeEnd,
  );
}

/// An episode row, with the episode-specific fields required up front.
MediaFile episode(
  String show, {
  required int? season,
  required int number,
  String? fileName,
}) {
  return mediaFile(
    fileName ?? '$show.S${season ?? 0}E$number.mkv',
    mediaType: MediaType.episode,
    parsedTitle: show,
    parsedSeason: season,
    parsedEpisode: number,
  );
}
