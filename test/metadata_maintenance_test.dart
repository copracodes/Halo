// Metadata housekeeping against an in-memory database: pruning the records a
// removed folder orphans, keeping a renamed file's match, and clearing the
// image cache without touching the metadata itself.

import 'dart:io' show Directory, File;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/data/repositories/library_repository.dart';
import 'package:halo/data/repositories/metadata_repository.dart';
import 'package:halo/features/metadata/metadata_image_cache.dart';
import 'package:halo/features/metadata/metadata_keys.dart';
import 'package:halo/features/metadata/metadata_maintenance.dart';

void main() {
  late AppDatabase db;
  late LibraryRepository library;
  late MetadataRepository metadata;
  late Directory imageDir;
  late MetadataImageCache cache;
  late MetadataMaintenance maintenance;
  late int folderId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    library = LibraryRepository(db);
    metadata = MetadataRepository(db);
    imageDir = Directory.systemTemp.createTempSync('halo_cache');
    cache = MetadataImageCache(directory: imageDir);
    maintenance = MetadataMaintenance(
      metadata: metadata,
      library: library,
      cache: cache,
    );
    folderId = await library.addFolder(
      path: 'content://tree/m',
      displayName: 'M',
    );
  });

  tearDown(() async {
    await db.close();
    cache.close();
    if (imageDir.existsSync()) imageDir.deleteSync(recursive: true);
  });

  /// Indexes a movie file and gives it a matched metadata record.
  Future<String> addMatchedMovie(
    String fileName, {
    required String title,
    required int year,
    required int tmdbId,
    MatchStatus status = MatchStatus.auto,
  }) async {
    await library.upsertMediaFile(
      folderId: folderId,
      filePath: 'content://tree/m/$fileName',
      fileName: fileName,
      mediaType: MediaType.movie,
      parsedTitle: title,
      parsedYear: year,
    );
    final key = movieKeyFor(title, year);
    await metadata.ensureMoviePending(key);
    await metadata.saveMovieMatch(
      key,
      MovieMetadataCompanion(
        tmdbId: Value(tmdbId),
        title: Value(title),
        posterPath: const Value('/p.jpg'),
        localPosterPath: const Value('/local/p.jpg'),
        matchStatus: Value(status),
      ),
    );
    return key;
  }

  group('pruneOrphans', () {
    test('drops metadata for a removed title, keeps the ones still present',
        () async {
      final duneKey = await addMatchedMovie(
        'Dune.2021.mkv',
        title: 'Dune',
        year: 2021,
        tmdbId: 438631,
      );
      final arrivalKey = await addMatchedMovie(
        'Arrival.2016.mkv',
        title: 'Arrival',
        year: 2016,
        tmdbId: 329865,
      );

      // Simulate removing the folder that held Arrival: its file rows go away,
      // but its title-keyed metadata record is left orphaned.
      await library.removeMissingMediaFiles(folderId, {
        'content://tree/m/Dune.2021.mkv',
      });

      final pruned = await maintenance.pruneOrphans();

      expect(pruned, 1);
      expect(await metadata.movieByKey(arrivalKey), isNull,
          reason: 'the removed title is cleaned up');
      expect((await metadata.movieByKey(duneKey))?.tmdbId, 438631,
          reason: 'the title still on disk is untouched');
    });

    test('a renamed file keeps its metadata link', () async {
      final key = await addMatchedMovie(
        'Dune.2021.1080p.mkv',
        title: 'Dune',
        year: 2021,
        tmdbId: 438631,
        status: MatchStatus.manual,
      );

      // A rename is a new path with the same parsed title/year: index the new
      // name, then prune the old one, exactly as a rescan would.
      await library.upsertMediaFile(
        folderId: folderId,
        filePath: 'content://tree/m/Dune.2021.2160p.mkv',
        fileName: 'Dune.2021.2160p.mkv',
        mediaType: MediaType.movie,
        parsedTitle: 'Dune',
        parsedYear: 2021,
      );
      await library.removeMissingMediaFiles(folderId, {
        'content://tree/m/Dune.2021.2160p.mkv',
      });

      final pruned = await maintenance.pruneOrphans();

      expect(pruned, 0, reason: 'the key is still live under the new file name');
      final record = await metadata.movieByKey(key);
      expect(record?.tmdbId, 438631);
      expect(record?.matchStatus, MatchStatus.manual,
          reason: 'the manual choice rides through a rename');
    });

    test('hidden files still count as live — hiding is not removing', () async {
      final key = await addMatchedMovie(
        'sample.mkv',
        title: 'Dune',
        year: 2021,
        tmdbId: 438631,
      );
      final file = await library.mediaByPath('content://tree/m/sample.mkv');
      await library.setHidden(file!.id, true);

      expect(await maintenance.pruneOrphans(), 0);
      expect(await metadata.movieByKey(key), isNotNull);
    });
  });

  group('clearImageCache', () {
    test('empties the cache and forgets local paths, but keeps the metadata',
        () async {
      final key = await addMatchedMovie(
        'Dune.2021.mkv',
        title: 'Dune',
        year: 2021,
        tmdbId: 438631,
      );
      File('${imageDir.path}/poster.jpg').writeAsBytesSync(List.filled(2048, 0));

      expect(await cache.currentSizeBytes(), greaterThan(0));

      await maintenance.clearImageCache();

      expect(imageDir.existsSync(), isFalse, reason: 'the files are gone');
      final record = await metadata.movieByKey(key);
      expect(record?.tmdbId, 438631, reason: 'the match itself is kept');
      expect(record?.localPosterPath, isNull,
          reason: 'the stale local path is forgotten');
      expect(await metadata.moviesNeedingImages(), hasLength(1),
          reason: 'so the next sync re-downloads the artwork');
    });
  });
}
