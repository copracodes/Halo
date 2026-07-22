// Scanner diffing logic against an in-memory database and a mocked file source:
// files added, removed, and unchanged across successive scans.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/data/repositories/library_repository.dart';
import 'package:halo/features/library/folder_access/folder_access.dart';
import 'package:halo/features/library/library_scanner.dart';

/// A [FolderAccess] whose file listing is whatever [files] is set to, so a test
/// can change what "disk" returns between scans.
class FakeFolderAccess implements FolderAccess {
  List<ScannedFile> files = [];

  @override
  Stream<ScannedFile> listFiles(String folderUri) => Stream.fromIterable(files);

  @override
  Future<PickedFolder?> pickFolder() async => null;
  @override
  Future<bool> hasAccess(String folderUri) async => true;
  @override
  Future<void> releaseFolder(String folderUri) async {}
}

ScannedFile _file(String name) => ScannedFile(
      uri: 'content://tree/movies/$name',
      name: name,
      size: 1000,
      lastModified: 0,
    );

void main() {
  late AppDatabase db;
  late LibraryRepository library;
  late FakeFolderAccess source;
  late LibraryScanner scanner;
  late LibraryFolder folder;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    library = LibraryRepository(db);
    source = FakeFolderAccess();
    scanner = LibraryScanner(source, library);
    await library.addFolder(path: 'content://tree/movies', displayName: 'Movies');
    folder = (await library.allFolders()).single;
  });

  tearDown(() async => db.close());

  Future<List<String>> mediaNames() async {
    final rows = await library.watchMediaInFolder(folder.id).first;
    return rows.map((r) => r.fileName).toList()..sort();
  }

  test('new files are inserted', () async {
    source.files = [_file('a.mkv'), _file('b.mp4')];
    final result = await scanner.scanFolder(folder);

    expect(result.found, 2);
    expect(result.removed, 0);
    expect(await mediaNames(), ['a.mkv', 'b.mp4']);
  });

  test('adding a file on a later scan inserts only the new one', () async {
    source.files = [_file('a.mkv')];
    await scanner.scanFolder(folder);

    source.files = [_file('a.mkv'), _file('b.mp4')];
    await scanner.scanFolder(folder);

    expect(await mediaNames(), ['a.mkv', 'b.mp4']);
  });

  test('a file gone from disk is removed from the library', () async {
    source.files = [_file('a.mkv'), _file('b.mp4')];
    await scanner.scanFolder(folder);

    source.files = [_file('a.mkv')];
    final result = await scanner.scanFolder(folder);

    expect(result.found, 1);
    expect(result.removed, 1);
    expect(await mediaNames(), ['a.mkv']);
  });

  test('an unchanged file keeps its row (same id)', () async {
    source.files = [_file('a.mkv')];
    await scanner.scanFolder(folder);
    final firstId = (await library.mediaByPath('content://tree/movies/a.mkv'))!.id;

    await scanner.scanFolder(folder); // identical listing
    final secondId =
        (await library.mediaByPath('content://tree/movies/a.mkv'))!.id;

    expect(secondId, firstId);
    expect(await mediaNames(), ['a.mkv']);
  });

  test('non-video files are ignored', () async {
    source.files = [_file('a.mkv'), _file('notes.txt'), _file('poster.jpg')];
    final result = await scanner.scanFolder(folder);

    expect(result.found, 1);
    expect(await mediaNames(), ['a.mkv']);
  });

  test('emptying the folder removes all its files', () async {
    source.files = [_file('a.mkv'), _file('b.mp4')];
    await scanner.scanFolder(folder);

    source.files = [];
    final result = await scanner.scanFolder(folder);

    expect(result.removed, 2);
    expect(await mediaNames(), isEmpty);
  });

  test('stores parsed fields for a scanned episode', () async {
    source.files = [_file('Breaking.Bad.S01E03.1080p.mkv')];
    await scanner.scanFolder(folder);

    final m = await library
        .mediaByPath('content://tree/movies/Breaking.Bad.S01E03.1080p.mkv');
    expect(m!.mediaType, MediaType.episode);
    expect(m.parsedTitle, 'Breaking Bad');
    expect(m.parsedSeason, 1);
    expect(m.parsedEpisode, 3);
  });

  test('uses folder context (parentPath + root) for folder-based episodes',
      () async {
    source.files = [
      const ScannedFile(
        uri: 'content://x/05.mkv',
        name: '05 - Ozymandias.mkv',
        size: 1,
        lastModified: 0,
        parentPath: ['Season 2', 'Breaking Bad'],
      ),
    ];
    await scanner.scanFolder(folder);

    final m = await library.mediaByPath('content://x/05.mkv');
    expect(m!.mediaType, MediaType.episode);
    expect(m.parsedSeason, 2);
    expect(m.parsedEpisode, 5);
    expect(m.parsedTitle, 'Breaking Bad');
  });

  test('reparseAll recomputes parsed fields from filenames', () async {
    source.files = [_file('Inception.2010.1080p.mkv')];
    await scanner.scanFolder(folder);

    final count = await scanner.reparseAll();
    expect(count, 1);

    final m = await library
        .mediaByPath('content://tree/movies/Inception.2010.1080p.mkv');
    expect(m!.mediaType, MediaType.movie);
    expect(m.parsedTitle, 'Inception');
    expect(m.parsedYear, 2010);
  });
}
