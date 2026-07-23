// Repository CRUD against an in-memory drift database. Exercises the library
// and progress repositories end-to-end, including the foreign-key cascade that
// keeps orphaned media/progress rows from lingering.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/data/repositories/library_repository.dart';
import 'package:halo/data/repositories/progress_repository.dart';

void main() {
  late AppDatabase db;
  late LibraryRepository library;
  late ProgressRepository progress;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    library = LibraryRepository(db);
    progress = ProgressRepository(db);
  });

  tearDown(() async => db.close());

  group('LibraryRepository', () {
    test('adds and reads back a folder', () async {
      final id = await library.addFolder(
        path: 'content://tree/movies',
        displayName: 'Movies',
      );

      final folders = await library.allFolders();
      expect(folders, hasLength(1));
      expect(folders.single.id, id);
      expect(folders.single.displayName, 'Movies');
    });

    test('re-adding the same path updates rather than duplicates', () async {
      final first = await library.addFolder(
        path: 'content://tree/movies',
        displayName: 'Movies',
      );
      final second = await library.addFolder(
        path: 'content://tree/movies',
        displayName: 'My Movies',
      );

      expect(second, first);
      final folders = await library.allFolders();
      expect(folders, hasLength(1));
      expect(folders.single.displayName, 'My Movies');
    });

    test('upserts a media file and finds it by path', () async {
      final folderId = await library.addFolder(
        path: 'content://tree/movies',
        displayName: 'Movies',
      );
      await library.upsertMediaFile(
        folderId: folderId,
        filePath: '/movies/dune.mkv',
        fileName: 'dune.mkv',
        mediaType: MediaType.movie,
        parsedTitle: 'Dune',
        parsedYear: 2021,
      );

      final media = await library.mediaByPath('/movies/dune.mkv');
      expect(media, isNotNull);
      expect(media!.mediaType, MediaType.movie);
      expect(media.parsedTitle, 'Dune');
      expect(media.parsedYear, 2021);
      expect(media.folderId, folderId);
    });

    test('hidden files drop out of the grids but stay restorable', () async {
      final folderId = await library.addFolder(
        path: 'content://tree/movies',
        displayName: 'Movies',
      );
      await library.upsertMediaFile(
        folderId: folderId,
        filePath: '/movies/dune.mkv',
        fileName: 'dune.mkv',
        mediaType: MediaType.movie,
      );
      await library.upsertMediaFile(
        folderId: folderId,
        filePath: '/movies/sample.mkv',
        fileName: 'sample.mkv',
        mediaType: MediaType.movie,
      );

      final sample = await library.mediaByPath('/movies/sample.mkv');
      await library.setHidden(sample!.id, true);

      final visible = await library.watchMediaOfType(MediaType.movie).first;
      expect(visible.map((f) => f.fileName), ['dune.mkv'],
          reason: 'the hidden sample is gone from the grid');

      final hidden = await library.watchHiddenMedia().first;
      expect(hidden.map((f) => f.fileName), ['sample.mkv'],
          reason: 'but it is listed for restoring');

      await library.setHidden(sample.id, false);
      final restored = await library.watchMediaOfType(MediaType.movie).first;
      expect(restored.map((f) => f.fileName).toSet(),
          {'dune.mkv', 'sample.mkv'});
      expect(await library.watchHiddenMedia().first, isEmpty);
    });

    test('a hidden file is excluded from continue-watching', () async {
      final folderId = await library.addFolder(
        path: 'content://tree/movies',
        displayName: 'Movies',
      );
      await library.upsertMediaFile(
        folderId: folderId,
        filePath: '/movies/trailer.mkv',
        fileName: 'trailer.mkv',
        mediaType: MediaType.movie,
      );
      await progress.savePosition(
        '/movies/trailer.mkv',
        position: const Duration(minutes: 1),
        duration: const Duration(minutes: 3),
      );

      expect(await progress.watchInProgress().first, hasLength(1));

      final file = await library.mediaByPath('/movies/trailer.mkv');
      await library.setHidden(file!.id, true);

      expect(await progress.watchInProgress().first, isEmpty,
          reason: 'hiding a file removes it from continue-watching too');
    });

    test('removing a folder cascades to its media and progress', () async {
      final folderId = await library.addFolder(
        path: 'content://tree/movies',
        displayName: 'Movies',
      );
      await library.upsertMediaFile(
        folderId: folderId,
        filePath: '/movies/dune.mkv',
        fileName: 'dune.mkv',
      );
      await progress.savePosition(
        '/movies/dune.mkv',
        position: const Duration(minutes: 10),
        duration: const Duration(hours: 2),
      );

      await library.removeFolder(folderId);

      expect(await library.mediaByPath('/movies/dune.mkv'), isNull);
      expect(await progress.resumePositionFor('/movies/dune.mkv'), isNull);
    });
  });

  group('ProgressRepository', () {
    const path = '/downloads/adhoc.mp4';

    test('saves and reads a resume position for an ad-hoc file', () async {
      await progress.savePosition(
        path,
        position: const Duration(minutes: 5),
        duration: const Duration(hours: 1),
      );

      expect(
        await progress.resumePositionFor(path),
        const Duration(minutes: 5),
      );
      // The ad-hoc file was auto-registered with no owning folder.
      final media = await library.mediaByPath(path);
      expect(media, isNotNull);
      expect(media!.folderId, isNull);
    });

    test('saving again overwrites the previous position (one row per file)',
        () async {
      await progress.savePosition(
        path,
        position: const Duration(minutes: 5),
        duration: const Duration(hours: 1),
      );
      await progress.savePosition(
        path,
        position: const Duration(minutes: 20),
        duration: const Duration(hours: 1),
      );

      expect(
        await progress.resumePositionFor(path),
        const Duration(minutes: 20),
      );
    });

    test('a finished file is no longer offered for resume', () async {
      await progress.savePosition(
        path,
        position: const Duration(minutes: 50),
        duration: const Duration(hours: 1),
      );
      await progress.markFinished(path);

      expect(await progress.resumePositionFor(path), isNull);
    });

    test('resuming after finishing clears the finished flag', () async {
      await progress.markFinished(path);
      await progress.savePosition(
        path,
        position: const Duration(minutes: 8),
        duration: const Duration(hours: 1),
      );

      expect(
        await progress.resumePositionFor(path),
        const Duration(minutes: 8),
      );
    });

    test('clearing progress removes the saved position', () async {
      await progress.savePosition(
        path,
        position: const Duration(minutes: 5),
        duration: const Duration(hours: 1),
      );
      await progress.clearProgress(path);

      expect(await progress.resumePositionFor(path), isNull);
    });

    test('resume position is null for an unknown file', () async {
      expect(await progress.resumePositionFor('/nope.mkv'), isNull);
    });

    test('resume state carries the duration recorded with the position',
        () async {
      // The player needs the stored duration to judge, before opening a file,
      // whether the saved position is worth starting from.
      await progress.savePosition(
        path,
        position: const Duration(minutes: 15),
        duration: const Duration(hours: 2),
      );

      final state = await progress.resumeStateFor(path);
      expect(state, isNotNull);
      expect(state!.position, const Duration(minutes: 15));
      expect(state.duration, const Duration(hours: 2));
    });

    test('resume state is null once the file is finished', () async {
      await progress.savePosition(
        path,
        position: const Duration(minutes: 15),
        duration: const Duration(hours: 2),
      );
      await progress.markFinished(path);

      expect(await progress.resumeStateFor(path), isNull);
    });
  });
}
