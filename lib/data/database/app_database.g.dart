// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LibraryFoldersTable extends LibraryFolders
    with TableInfo<$LibraryFoldersTable, LibraryFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, path, displayName, dateAdded];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryFolder(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      path:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}path'],
          )!,
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}display_name'],
          )!,
      dateAdded:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date_added'],
          )!,
    );
  }

  @override
  $LibraryFoldersTable createAlias(String alias) {
    return $LibraryFoldersTable(attachedDatabase, alias);
  }
}

class LibraryFolder extends DataClass implements Insertable<LibraryFolder> {
  final int id;
  final String path;
  final String displayName;
  final DateTime dateAdded;
  const LibraryFolder({
    required this.id,
    required this.path,
    required this.displayName,
    required this.dateAdded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path'] = Variable<String>(path);
    map['display_name'] = Variable<String>(displayName);
    map['date_added'] = Variable<DateTime>(dateAdded);
    return map;
  }

  LibraryFoldersCompanion toCompanion(bool nullToAbsent) {
    return LibraryFoldersCompanion(
      id: Value(id),
      path: Value(path),
      displayName: Value(displayName),
      dateAdded: Value(dateAdded),
    );
  }

  factory LibraryFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryFolder(
      id: serializer.fromJson<int>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      displayName: serializer.fromJson<String>(json['displayName']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'path': serializer.toJson<String>(path),
      'displayName': serializer.toJson<String>(displayName),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
    };
  }

  LibraryFolder copyWith({
    int? id,
    String? path,
    String? displayName,
    DateTime? dateAdded,
  }) => LibraryFolder(
    id: id ?? this.id,
    path: path ?? this.path,
    displayName: displayName ?? this.displayName,
    dateAdded: dateAdded ?? this.dateAdded,
  );
  LibraryFolder copyWithCompanion(LibraryFoldersCompanion data) {
    return LibraryFolder(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryFolder(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('displayName: $displayName, ')
          ..write('dateAdded: $dateAdded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, path, displayName, dateAdded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryFolder &&
          other.id == this.id &&
          other.path == this.path &&
          other.displayName == this.displayName &&
          other.dateAdded == this.dateAdded);
}

class LibraryFoldersCompanion extends UpdateCompanion<LibraryFolder> {
  final Value<int> id;
  final Value<String> path;
  final Value<String> displayName;
  final Value<DateTime> dateAdded;
  const LibraryFoldersCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.displayName = const Value.absent(),
    this.dateAdded = const Value.absent(),
  });
  LibraryFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String path,
    required String displayName,
    required DateTime dateAdded,
  }) : path = Value(path),
       displayName = Value(displayName),
       dateAdded = Value(dateAdded);
  static Insertable<LibraryFolder> custom({
    Expression<int>? id,
    Expression<String>? path,
    Expression<String>? displayName,
    Expression<DateTime>? dateAdded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (displayName != null) 'display_name': displayName,
      if (dateAdded != null) 'date_added': dateAdded,
    });
  }

  LibraryFoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? path,
    Value<String>? displayName,
    Value<DateTime>? dateAdded,
  }) {
    return LibraryFoldersCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      displayName: displayName ?? this.displayName,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryFoldersCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('displayName: $displayName, ')
          ..write('dateAdded: $dateAdded')
          ..write(')'))
        .toString();
  }
}

class $MediaFilesTable extends MediaFiles
    with TableInfo<$MediaFilesTable, MediaFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_folders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateModifiedMeta = const VerificationMeta(
    'dateModified',
  );
  @override
  late final GeneratedColumn<DateTime> dateModified = GeneratedColumn<DateTime>(
    'date_modified',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateScannedMeta = const VerificationMeta(
    'dateScanned',
  );
  @override
  late final GeneratedColumn<DateTime> dateScanned = GeneratedColumn<DateTime>(
    'date_scanned',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MediaType, int> mediaType =
      GeneratedColumn<int>(
        'media_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(MediaType.unknown.index),
      ).withConverter<MediaType>($MediaFilesTable.$convertermediaType);
  static const VerificationMeta _parsedTitleMeta = const VerificationMeta(
    'parsedTitle',
  );
  @override
  late final GeneratedColumn<String> parsedTitle = GeneratedColumn<String>(
    'parsed_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parsedYearMeta = const VerificationMeta(
    'parsedYear',
  );
  @override
  late final GeneratedColumn<int> parsedYear = GeneratedColumn<int>(
    'parsed_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parsedSeasonMeta = const VerificationMeta(
    'parsedSeason',
  );
  @override
  late final GeneratedColumn<int> parsedSeason = GeneratedColumn<int>(
    'parsed_season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parsedEpisodeMeta = const VerificationMeta(
    'parsedEpisode',
  );
  @override
  late final GeneratedColumn<int> parsedEpisode = GeneratedColumn<int>(
    'parsed_episode',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parsedEpisodeEndMeta = const VerificationMeta(
    'parsedEpisodeEnd',
  );
  @override
  late final GeneratedColumn<int> parsedEpisodeEnd = GeneratedColumn<int>(
    'parsed_episode_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folderId,
    filePath,
    fileName,
    fileSize,
    dateModified,
    dateScanned,
    mediaType,
    parsedTitle,
    parsedYear,
    parsedSeason,
    parsedEpisode,
    parsedEpisodeEnd,
    durationMs,
    hidden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('date_modified')) {
      context.handle(
        _dateModifiedMeta,
        dateModified.isAcceptableOrUnknown(
          data['date_modified']!,
          _dateModifiedMeta,
        ),
      );
    }
    if (data.containsKey('date_scanned')) {
      context.handle(
        _dateScannedMeta,
        dateScanned.isAcceptableOrUnknown(
          data['date_scanned']!,
          _dateScannedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateScannedMeta);
    }
    if (data.containsKey('parsed_title')) {
      context.handle(
        _parsedTitleMeta,
        parsedTitle.isAcceptableOrUnknown(
          data['parsed_title']!,
          _parsedTitleMeta,
        ),
      );
    }
    if (data.containsKey('parsed_year')) {
      context.handle(
        _parsedYearMeta,
        parsedYear.isAcceptableOrUnknown(data['parsed_year']!, _parsedYearMeta),
      );
    }
    if (data.containsKey('parsed_season')) {
      context.handle(
        _parsedSeasonMeta,
        parsedSeason.isAcceptableOrUnknown(
          data['parsed_season']!,
          _parsedSeasonMeta,
        ),
      );
    }
    if (data.containsKey('parsed_episode')) {
      context.handle(
        _parsedEpisodeMeta,
        parsedEpisode.isAcceptableOrUnknown(
          data['parsed_episode']!,
          _parsedEpisodeMeta,
        ),
      );
    }
    if (data.containsKey('parsed_episode_end')) {
      context.handle(
        _parsedEpisodeEndMeta,
        parsedEpisodeEnd.isAcceptableOrUnknown(
          data['parsed_episode_end']!,
          _parsedEpisodeEndMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaFile(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      ),
      filePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_path'],
          )!,
      fileName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_name'],
          )!,
      fileSize:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}file_size'],
          )!,
      dateModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_modified'],
      ),
      dateScanned:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date_scanned'],
          )!,
      mediaType: $MediaFilesTable.$convertermediaType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}media_type'],
        )!,
      ),
      parsedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parsed_title'],
      ),
      parsedYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parsed_year'],
      ),
      parsedSeason: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parsed_season'],
      ),
      parsedEpisode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parsed_episode'],
      ),
      parsedEpisodeEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parsed_episode_end'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      hidden:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}hidden'],
          )!,
    );
  }

  @override
  $MediaFilesTable createAlias(String alias) {
    return $MediaFilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MediaType, int, int> $convertermediaType =
      const EnumIndexConverter<MediaType>(MediaType.values);
}

class MediaFile extends DataClass implements Insertable<MediaFile> {
  final int id;
  final int? folderId;
  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime? dateModified;
  final DateTime dateScanned;
  final MediaType mediaType;
  final String? parsedTitle;
  final int? parsedYear;
  final int? parsedSeason;
  final int? parsedEpisode;

  /// Last episode for multi-episode files (e.g. S01E01E02); null for single
  /// episodes.
  final int? parsedEpisodeEnd;
  final int? durationMs;

  /// Hidden from the library UI without leaving the database. Set when the user
  /// marks a file "not a movie" (a sample clip, a trailer) so it stops cluttering
  /// the grids, matching, and continue-watching — but stays restorable from the
  /// Hidden files list in settings. Excluded everywhere the UI reads media.
  final bool hidden;
  const MediaFile({
    required this.id,
    this.folderId,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    this.dateModified,
    required this.dateScanned,
    required this.mediaType,
    this.parsedTitle,
    this.parsedYear,
    this.parsedSeason,
    this.parsedEpisode,
    this.parsedEpisodeEnd,
    this.durationMs,
    required this.hidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<int>(folderId);
    }
    map['file_path'] = Variable<String>(filePath);
    map['file_name'] = Variable<String>(fileName);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || dateModified != null) {
      map['date_modified'] = Variable<DateTime>(dateModified);
    }
    map['date_scanned'] = Variable<DateTime>(dateScanned);
    {
      map['media_type'] = Variable<int>(
        $MediaFilesTable.$convertermediaType.toSql(mediaType),
      );
    }
    if (!nullToAbsent || parsedTitle != null) {
      map['parsed_title'] = Variable<String>(parsedTitle);
    }
    if (!nullToAbsent || parsedYear != null) {
      map['parsed_year'] = Variable<int>(parsedYear);
    }
    if (!nullToAbsent || parsedSeason != null) {
      map['parsed_season'] = Variable<int>(parsedSeason);
    }
    if (!nullToAbsent || parsedEpisode != null) {
      map['parsed_episode'] = Variable<int>(parsedEpisode);
    }
    if (!nullToAbsent || parsedEpisodeEnd != null) {
      map['parsed_episode_end'] = Variable<int>(parsedEpisodeEnd);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['hidden'] = Variable<bool>(hidden);
    return map;
  }

  MediaFilesCompanion toCompanion(bool nullToAbsent) {
    return MediaFilesCompanion(
      id: Value(id),
      folderId:
          folderId == null && nullToAbsent
              ? const Value.absent()
              : Value(folderId),
      filePath: Value(filePath),
      fileName: Value(fileName),
      fileSize: Value(fileSize),
      dateModified:
          dateModified == null && nullToAbsent
              ? const Value.absent()
              : Value(dateModified),
      dateScanned: Value(dateScanned),
      mediaType: Value(mediaType),
      parsedTitle:
          parsedTitle == null && nullToAbsent
              ? const Value.absent()
              : Value(parsedTitle),
      parsedYear:
          parsedYear == null && nullToAbsent
              ? const Value.absent()
              : Value(parsedYear),
      parsedSeason:
          parsedSeason == null && nullToAbsent
              ? const Value.absent()
              : Value(parsedSeason),
      parsedEpisode:
          parsedEpisode == null && nullToAbsent
              ? const Value.absent()
              : Value(parsedEpisode),
      parsedEpisodeEnd:
          parsedEpisodeEnd == null && nullToAbsent
              ? const Value.absent()
              : Value(parsedEpisodeEnd),
      durationMs:
          durationMs == null && nullToAbsent
              ? const Value.absent()
              : Value(durationMs),
      hidden: Value(hidden),
    );
  }

  factory MediaFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaFile(
      id: serializer.fromJson<int>(json['id']),
      folderId: serializer.fromJson<int?>(json['folderId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      dateModified: serializer.fromJson<DateTime?>(json['dateModified']),
      dateScanned: serializer.fromJson<DateTime>(json['dateScanned']),
      mediaType: $MediaFilesTable.$convertermediaType.fromJson(
        serializer.fromJson<int>(json['mediaType']),
      ),
      parsedTitle: serializer.fromJson<String?>(json['parsedTitle']),
      parsedYear: serializer.fromJson<int?>(json['parsedYear']),
      parsedSeason: serializer.fromJson<int?>(json['parsedSeason']),
      parsedEpisode: serializer.fromJson<int?>(json['parsedEpisode']),
      parsedEpisodeEnd: serializer.fromJson<int?>(json['parsedEpisodeEnd']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      hidden: serializer.fromJson<bool>(json['hidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'folderId': serializer.toJson<int?>(folderId),
      'filePath': serializer.toJson<String>(filePath),
      'fileName': serializer.toJson<String>(fileName),
      'fileSize': serializer.toJson<int>(fileSize),
      'dateModified': serializer.toJson<DateTime?>(dateModified),
      'dateScanned': serializer.toJson<DateTime>(dateScanned),
      'mediaType': serializer.toJson<int>(
        $MediaFilesTable.$convertermediaType.toJson(mediaType),
      ),
      'parsedTitle': serializer.toJson<String?>(parsedTitle),
      'parsedYear': serializer.toJson<int?>(parsedYear),
      'parsedSeason': serializer.toJson<int?>(parsedSeason),
      'parsedEpisode': serializer.toJson<int?>(parsedEpisode),
      'parsedEpisodeEnd': serializer.toJson<int?>(parsedEpisodeEnd),
      'durationMs': serializer.toJson<int?>(durationMs),
      'hidden': serializer.toJson<bool>(hidden),
    };
  }

  MediaFile copyWith({
    int? id,
    Value<int?> folderId = const Value.absent(),
    String? filePath,
    String? fileName,
    int? fileSize,
    Value<DateTime?> dateModified = const Value.absent(),
    DateTime? dateScanned,
    MediaType? mediaType,
    Value<String?> parsedTitle = const Value.absent(),
    Value<int?> parsedYear = const Value.absent(),
    Value<int?> parsedSeason = const Value.absent(),
    Value<int?> parsedEpisode = const Value.absent(),
    Value<int?> parsedEpisodeEnd = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    bool? hidden,
  }) => MediaFile(
    id: id ?? this.id,
    folderId: folderId.present ? folderId.value : this.folderId,
    filePath: filePath ?? this.filePath,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize ?? this.fileSize,
    dateModified: dateModified.present ? dateModified.value : this.dateModified,
    dateScanned: dateScanned ?? this.dateScanned,
    mediaType: mediaType ?? this.mediaType,
    parsedTitle: parsedTitle.present ? parsedTitle.value : this.parsedTitle,
    parsedYear: parsedYear.present ? parsedYear.value : this.parsedYear,
    parsedSeason: parsedSeason.present ? parsedSeason.value : this.parsedSeason,
    parsedEpisode:
        parsedEpisode.present ? parsedEpisode.value : this.parsedEpisode,
    parsedEpisodeEnd:
        parsedEpisodeEnd.present
            ? parsedEpisodeEnd.value
            : this.parsedEpisodeEnd,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    hidden: hidden ?? this.hidden,
  );
  MediaFile copyWithCompanion(MediaFilesCompanion data) {
    return MediaFile(
      id: data.id.present ? data.id.value : this.id,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      dateModified:
          data.dateModified.present
              ? data.dateModified.value
              : this.dateModified,
      dateScanned:
          data.dateScanned.present ? data.dateScanned.value : this.dateScanned,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      parsedTitle:
          data.parsedTitle.present ? data.parsedTitle.value : this.parsedTitle,
      parsedYear:
          data.parsedYear.present ? data.parsedYear.value : this.parsedYear,
      parsedSeason:
          data.parsedSeason.present
              ? data.parsedSeason.value
              : this.parsedSeason,
      parsedEpisode:
          data.parsedEpisode.present
              ? data.parsedEpisode.value
              : this.parsedEpisode,
      parsedEpisodeEnd:
          data.parsedEpisodeEnd.present
              ? data.parsedEpisodeEnd.value
              : this.parsedEpisodeEnd,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaFile(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('dateModified: $dateModified, ')
          ..write('dateScanned: $dateScanned, ')
          ..write('mediaType: $mediaType, ')
          ..write('parsedTitle: $parsedTitle, ')
          ..write('parsedYear: $parsedYear, ')
          ..write('parsedSeason: $parsedSeason, ')
          ..write('parsedEpisode: $parsedEpisode, ')
          ..write('parsedEpisodeEnd: $parsedEpisodeEnd, ')
          ..write('durationMs: $durationMs, ')
          ..write('hidden: $hidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    folderId,
    filePath,
    fileName,
    fileSize,
    dateModified,
    dateScanned,
    mediaType,
    parsedTitle,
    parsedYear,
    parsedSeason,
    parsedEpisode,
    parsedEpisodeEnd,
    durationMs,
    hidden,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaFile &&
          other.id == this.id &&
          other.folderId == this.folderId &&
          other.filePath == this.filePath &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.dateModified == this.dateModified &&
          other.dateScanned == this.dateScanned &&
          other.mediaType == this.mediaType &&
          other.parsedTitle == this.parsedTitle &&
          other.parsedYear == this.parsedYear &&
          other.parsedSeason == this.parsedSeason &&
          other.parsedEpisode == this.parsedEpisode &&
          other.parsedEpisodeEnd == this.parsedEpisodeEnd &&
          other.durationMs == this.durationMs &&
          other.hidden == this.hidden);
}

class MediaFilesCompanion extends UpdateCompanion<MediaFile> {
  final Value<int> id;
  final Value<int?> folderId;
  final Value<String> filePath;
  final Value<String> fileName;
  final Value<int> fileSize;
  final Value<DateTime?> dateModified;
  final Value<DateTime> dateScanned;
  final Value<MediaType> mediaType;
  final Value<String?> parsedTitle;
  final Value<int?> parsedYear;
  final Value<int?> parsedSeason;
  final Value<int?> parsedEpisode;
  final Value<int?> parsedEpisodeEnd;
  final Value<int?> durationMs;
  final Value<bool> hidden;
  const MediaFilesCompanion({
    this.id = const Value.absent(),
    this.folderId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.dateModified = const Value.absent(),
    this.dateScanned = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.parsedTitle = const Value.absent(),
    this.parsedYear = const Value.absent(),
    this.parsedSeason = const Value.absent(),
    this.parsedEpisode = const Value.absent(),
    this.parsedEpisodeEnd = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.hidden = const Value.absent(),
  });
  MediaFilesCompanion.insert({
    this.id = const Value.absent(),
    this.folderId = const Value.absent(),
    required String filePath,
    required String fileName,
    this.fileSize = const Value.absent(),
    this.dateModified = const Value.absent(),
    required DateTime dateScanned,
    this.mediaType = const Value.absent(),
    this.parsedTitle = const Value.absent(),
    this.parsedYear = const Value.absent(),
    this.parsedSeason = const Value.absent(),
    this.parsedEpisode = const Value.absent(),
    this.parsedEpisodeEnd = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.hidden = const Value.absent(),
  }) : filePath = Value(filePath),
       fileName = Value(fileName),
       dateScanned = Value(dateScanned);
  static Insertable<MediaFile> custom({
    Expression<int>? id,
    Expression<int>? folderId,
    Expression<String>? filePath,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<DateTime>? dateModified,
    Expression<DateTime>? dateScanned,
    Expression<int>? mediaType,
    Expression<String>? parsedTitle,
    Expression<int>? parsedYear,
    Expression<int>? parsedSeason,
    Expression<int>? parsedEpisode,
    Expression<int>? parsedEpisodeEnd,
    Expression<int>? durationMs,
    Expression<bool>? hidden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folderId != null) 'folder_id': folderId,
      if (filePath != null) 'file_path': filePath,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (dateModified != null) 'date_modified': dateModified,
      if (dateScanned != null) 'date_scanned': dateScanned,
      if (mediaType != null) 'media_type': mediaType,
      if (parsedTitle != null) 'parsed_title': parsedTitle,
      if (parsedYear != null) 'parsed_year': parsedYear,
      if (parsedSeason != null) 'parsed_season': parsedSeason,
      if (parsedEpisode != null) 'parsed_episode': parsedEpisode,
      if (parsedEpisodeEnd != null) 'parsed_episode_end': parsedEpisodeEnd,
      if (durationMs != null) 'duration_ms': durationMs,
      if (hidden != null) 'hidden': hidden,
    });
  }

  MediaFilesCompanion copyWith({
    Value<int>? id,
    Value<int?>? folderId,
    Value<String>? filePath,
    Value<String>? fileName,
    Value<int>? fileSize,
    Value<DateTime?>? dateModified,
    Value<DateTime>? dateScanned,
    Value<MediaType>? mediaType,
    Value<String?>? parsedTitle,
    Value<int?>? parsedYear,
    Value<int?>? parsedSeason,
    Value<int?>? parsedEpisode,
    Value<int?>? parsedEpisodeEnd,
    Value<int?>? durationMs,
    Value<bool>? hidden,
  }) {
    return MediaFilesCompanion(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      dateModified: dateModified ?? this.dateModified,
      dateScanned: dateScanned ?? this.dateScanned,
      mediaType: mediaType ?? this.mediaType,
      parsedTitle: parsedTitle ?? this.parsedTitle,
      parsedYear: parsedYear ?? this.parsedYear,
      parsedSeason: parsedSeason ?? this.parsedSeason,
      parsedEpisode: parsedEpisode ?? this.parsedEpisode,
      parsedEpisodeEnd: parsedEpisodeEnd ?? this.parsedEpisodeEnd,
      durationMs: durationMs ?? this.durationMs,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (dateModified.present) {
      map['date_modified'] = Variable<DateTime>(dateModified.value);
    }
    if (dateScanned.present) {
      map['date_scanned'] = Variable<DateTime>(dateScanned.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<int>(
        $MediaFilesTable.$convertermediaType.toSql(mediaType.value),
      );
    }
    if (parsedTitle.present) {
      map['parsed_title'] = Variable<String>(parsedTitle.value);
    }
    if (parsedYear.present) {
      map['parsed_year'] = Variable<int>(parsedYear.value);
    }
    if (parsedSeason.present) {
      map['parsed_season'] = Variable<int>(parsedSeason.value);
    }
    if (parsedEpisode.present) {
      map['parsed_episode'] = Variable<int>(parsedEpisode.value);
    }
    if (parsedEpisodeEnd.present) {
      map['parsed_episode_end'] = Variable<int>(parsedEpisodeEnd.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaFilesCompanion(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('dateModified: $dateModified, ')
          ..write('dateScanned: $dateScanned, ')
          ..write('mediaType: $mediaType, ')
          ..write('parsedTitle: $parsedTitle, ')
          ..write('parsedYear: $parsedYear, ')
          ..write('parsedSeason: $parsedSeason, ')
          ..write('parsedEpisode: $parsedEpisode, ')
          ..write('parsedEpisodeEnd: $parsedEpisodeEnd, ')
          ..write('durationMs: $durationMs, ')
          ..write('hidden: $hidden')
          ..write(')'))
        .toString();
  }
}

class $WatchProgressTable extends WatchProgress
    with TableInfo<$WatchProgressTable, WatchProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mediaFileIdMeta = const VerificationMeta(
    'mediaFileId',
  );
  @override
  late final GeneratedColumn<int> mediaFileId = GeneratedColumn<int>(
    'media_file_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES media_files (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastWatchedAtMeta = const VerificationMeta(
    'lastWatchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastWatchedAt =
      GeneratedColumn<DateTime>(
        'last_watched_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isFinishedMeta = const VerificationMeta(
    'isFinished',
  );
  @override
  late final GeneratedColumn<bool> isFinished = GeneratedColumn<bool>(
    'is_finished',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_finished" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaFileId,
    positionMs,
    durationMs,
    lastWatchedAt,
    isFinished,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('media_file_id')) {
      context.handle(
        _mediaFileIdMeta,
        mediaFileId.isAcceptableOrUnknown(
          data['media_file_id']!,
          _mediaFileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaFileIdMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('last_watched_at')) {
      context.handle(
        _lastWatchedAtMeta,
        lastWatchedAt.isAcceptableOrUnknown(
          data['last_watched_at']!,
          _lastWatchedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastWatchedAtMeta);
    }
    if (data.containsKey('is_finished')) {
      context.handle(
        _isFinishedMeta,
        isFinished.isAcceptableOrUnknown(data['is_finished']!, _isFinishedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchProgressData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      mediaFileId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}media_file_id'],
          )!,
      positionMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}position_ms'],
          )!,
      durationMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}duration_ms'],
          )!,
      lastWatchedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_watched_at'],
          )!,
      isFinished:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_finished'],
          )!,
    );
  }

  @override
  $WatchProgressTable createAlias(String alias) {
    return $WatchProgressTable(attachedDatabase, alias);
  }
}

class WatchProgressData extends DataClass
    implements Insertable<WatchProgressData> {
  final int id;
  final int mediaFileId;
  final int positionMs;
  final int durationMs;
  final DateTime lastWatchedAt;
  final bool isFinished;
  const WatchProgressData({
    required this.id,
    required this.mediaFileId,
    required this.positionMs,
    required this.durationMs,
    required this.lastWatchedAt,
    required this.isFinished,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['media_file_id'] = Variable<int>(mediaFileId);
    map['position_ms'] = Variable<int>(positionMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['last_watched_at'] = Variable<DateTime>(lastWatchedAt);
    map['is_finished'] = Variable<bool>(isFinished);
    return map;
  }

  WatchProgressCompanion toCompanion(bool nullToAbsent) {
    return WatchProgressCompanion(
      id: Value(id),
      mediaFileId: Value(mediaFileId),
      positionMs: Value(positionMs),
      durationMs: Value(durationMs),
      lastWatchedAt: Value(lastWatchedAt),
      isFinished: Value(isFinished),
    );
  }

  factory WatchProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchProgressData(
      id: serializer.fromJson<int>(json['id']),
      mediaFileId: serializer.fromJson<int>(json['mediaFileId']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      lastWatchedAt: serializer.fromJson<DateTime>(json['lastWatchedAt']),
      isFinished: serializer.fromJson<bool>(json['isFinished']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mediaFileId': serializer.toJson<int>(mediaFileId),
      'positionMs': serializer.toJson<int>(positionMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'lastWatchedAt': serializer.toJson<DateTime>(lastWatchedAt),
      'isFinished': serializer.toJson<bool>(isFinished),
    };
  }

  WatchProgressData copyWith({
    int? id,
    int? mediaFileId,
    int? positionMs,
    int? durationMs,
    DateTime? lastWatchedAt,
    bool? isFinished,
  }) => WatchProgressData(
    id: id ?? this.id,
    mediaFileId: mediaFileId ?? this.mediaFileId,
    positionMs: positionMs ?? this.positionMs,
    durationMs: durationMs ?? this.durationMs,
    lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
    isFinished: isFinished ?? this.isFinished,
  );
  WatchProgressData copyWithCompanion(WatchProgressCompanion data) {
    return WatchProgressData(
      id: data.id.present ? data.id.value : this.id,
      mediaFileId:
          data.mediaFileId.present ? data.mediaFileId.value : this.mediaFileId,
      positionMs:
          data.positionMs.present ? data.positionMs.value : this.positionMs,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      lastWatchedAt:
          data.lastWatchedAt.present
              ? data.lastWatchedAt.value
              : this.lastWatchedAt,
      isFinished:
          data.isFinished.present ? data.isFinished.value : this.isFinished,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchProgressData(')
          ..write('id: $id, ')
          ..write('mediaFileId: $mediaFileId, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('lastWatchedAt: $lastWatchedAt, ')
          ..write('isFinished: $isFinished')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaFileId,
    positionMs,
    durationMs,
    lastWatchedAt,
    isFinished,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchProgressData &&
          other.id == this.id &&
          other.mediaFileId == this.mediaFileId &&
          other.positionMs == this.positionMs &&
          other.durationMs == this.durationMs &&
          other.lastWatchedAt == this.lastWatchedAt &&
          other.isFinished == this.isFinished);
}

class WatchProgressCompanion extends UpdateCompanion<WatchProgressData> {
  final Value<int> id;
  final Value<int> mediaFileId;
  final Value<int> positionMs;
  final Value<int> durationMs;
  final Value<DateTime> lastWatchedAt;
  final Value<bool> isFinished;
  const WatchProgressCompanion({
    this.id = const Value.absent(),
    this.mediaFileId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.lastWatchedAt = const Value.absent(),
    this.isFinished = const Value.absent(),
  });
  WatchProgressCompanion.insert({
    this.id = const Value.absent(),
    required int mediaFileId,
    required int positionMs,
    required int durationMs,
    required DateTime lastWatchedAt,
    this.isFinished = const Value.absent(),
  }) : mediaFileId = Value(mediaFileId),
       positionMs = Value(positionMs),
       durationMs = Value(durationMs),
       lastWatchedAt = Value(lastWatchedAt);
  static Insertable<WatchProgressData> custom({
    Expression<int>? id,
    Expression<int>? mediaFileId,
    Expression<int>? positionMs,
    Expression<int>? durationMs,
    Expression<DateTime>? lastWatchedAt,
    Expression<bool>? isFinished,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaFileId != null) 'media_file_id': mediaFileId,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (lastWatchedAt != null) 'last_watched_at': lastWatchedAt,
      if (isFinished != null) 'is_finished': isFinished,
    });
  }

  WatchProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? mediaFileId,
    Value<int>? positionMs,
    Value<int>? durationMs,
    Value<DateTime>? lastWatchedAt,
    Value<bool>? isFinished,
  }) {
    return WatchProgressCompanion(
      id: id ?? this.id,
      mediaFileId: mediaFileId ?? this.mediaFileId,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mediaFileId.present) {
      map['media_file_id'] = Variable<int>(mediaFileId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (lastWatchedAt.present) {
      map['last_watched_at'] = Variable<DateTime>(lastWatchedAt.value);
    }
    if (isFinished.present) {
      map['is_finished'] = Variable<bool>(isFinished.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchProgressCompanion(')
          ..write('id: $id, ')
          ..write('mediaFileId: $mediaFileId, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('lastWatchedAt: $lastWatchedAt, ')
          ..write('isFinished: $isFinished')
          ..write(')'))
        .toString();
  }
}

class $MovieMetadataTable extends MovieMetadata
    with TableInfo<$MovieMetadataTable, MovieMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovieMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _movieKeyMeta = const VerificationMeta(
    'movieKey',
  );
  @override
  late final GeneratedColumn<String> movieKey = GeneratedColumn<String>(
    'movie_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
    'tmdb_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overviewMeta = const VerificationMeta(
    'overview',
  );
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
    'overview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runtimeMsMeta = const VerificationMeta(
    'runtimeMs',
  );
  @override
  late final GeneratedColumn<int> runtimeMs = GeneratedColumn<int>(
    'runtime_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voteAverageMeta = const VerificationMeta(
    'voteAverage',
  );
  @override
  late final GeneratedColumn<double> voteAverage = GeneratedColumn<double>(
    'vote_average',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posterPathMeta = const VerificationMeta(
    'posterPath',
  );
  @override
  late final GeneratedColumn<String> posterPath = GeneratedColumn<String>(
    'poster_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backdropPathMeta = const VerificationMeta(
    'backdropPath',
  );
  @override
  late final GeneratedColumn<String> backdropPath = GeneratedColumn<String>(
    'backdrop_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPosterPathMeta = const VerificationMeta(
    'localPosterPath',
  );
  @override
  late final GeneratedColumn<String> localPosterPath = GeneratedColumn<String>(
    'local_poster_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localBackdropPathMeta = const VerificationMeta(
    'localBackdropPath',
  );
  @override
  late final GeneratedColumn<String> localBackdropPath =
      GeneratedColumn<String>(
        'local_backdrop_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _matchConfidenceMeta = const VerificationMeta(
    'matchConfidence',
  );
  @override
  late final GeneratedColumn<double> matchConfidence = GeneratedColumn<double>(
    'match_confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MatchStatus, int> matchStatus =
      GeneratedColumn<int>(
        'match_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(MatchStatus.pending.index),
      ).withConverter<MatchStatus>($MovieMetadataTable.$convertermatchStatus);
  static const VerificationMeta _lastRefreshedMeta = const VerificationMeta(
    'lastRefreshed',
  );
  @override
  late final GeneratedColumn<DateTime> lastRefreshed =
      GeneratedColumn<DateTime>(
        'last_refreshed',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    movieKey,
    tmdbId,
    title,
    year,
    overview,
    runtimeMs,
    voteAverage,
    genres,
    posterPath,
    backdropPath,
    localPosterPath,
    localBackdropPath,
    matchConfidence,
    matchStatus,
    lastRefreshed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movie_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovieMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('movie_key')) {
      context.handle(
        _movieKeyMeta,
        movieKey.isAcceptableOrUnknown(data['movie_key']!, _movieKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_movieKeyMeta);
    }
    if (data.containsKey('tmdb_id')) {
      context.handle(
        _tmdbIdMeta,
        tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('overview')) {
      context.handle(
        _overviewMeta,
        overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta),
      );
    }
    if (data.containsKey('runtime_ms')) {
      context.handle(
        _runtimeMsMeta,
        runtimeMs.isAcceptableOrUnknown(data['runtime_ms']!, _runtimeMsMeta),
      );
    }
    if (data.containsKey('vote_average')) {
      context.handle(
        _voteAverageMeta,
        voteAverage.isAcceptableOrUnknown(
          data['vote_average']!,
          _voteAverageMeta,
        ),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('poster_path')) {
      context.handle(
        _posterPathMeta,
        posterPath.isAcceptableOrUnknown(data['poster_path']!, _posterPathMeta),
      );
    }
    if (data.containsKey('backdrop_path')) {
      context.handle(
        _backdropPathMeta,
        backdropPath.isAcceptableOrUnknown(
          data['backdrop_path']!,
          _backdropPathMeta,
        ),
      );
    }
    if (data.containsKey('local_poster_path')) {
      context.handle(
        _localPosterPathMeta,
        localPosterPath.isAcceptableOrUnknown(
          data['local_poster_path']!,
          _localPosterPathMeta,
        ),
      );
    }
    if (data.containsKey('local_backdrop_path')) {
      context.handle(
        _localBackdropPathMeta,
        localBackdropPath.isAcceptableOrUnknown(
          data['local_backdrop_path']!,
          _localBackdropPathMeta,
        ),
      );
    }
    if (data.containsKey('match_confidence')) {
      context.handle(
        _matchConfidenceMeta,
        matchConfidence.isAcceptableOrUnknown(
          data['match_confidence']!,
          _matchConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('last_refreshed')) {
      context.handle(
        _lastRefreshedMeta,
        lastRefreshed.isAcceptableOrUnknown(
          data['last_refreshed']!,
          _lastRefreshedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovieMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovieMetadataData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      movieKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}movie_key'],
          )!,
      tmdbId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tmdb_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      overview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overview'],
      ),
      runtimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runtime_ms'],
      ),
      voteAverage:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}vote_average'],
          )!,
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      posterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_path'],
      ),
      backdropPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backdrop_path'],
      ),
      localPosterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_poster_path'],
      ),
      localBackdropPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_backdrop_path'],
      ),
      matchConfidence:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}match_confidence'],
          )!,
      matchStatus: $MovieMetadataTable.$convertermatchStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}match_status'],
        )!,
      ),
      lastRefreshed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_refreshed'],
      ),
    );
  }

  @override
  $MovieMetadataTable createAlias(String alias) {
    return $MovieMetadataTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MatchStatus, int, int> $convertermatchStatus =
      const EnumIndexConverter<MatchStatus>(MatchStatus.values);
}

class MovieMetadataData extends DataClass
    implements Insertable<MovieMetadataData> {
  final int id;

  /// Normalised `title|year` (see `metadata_keys.dart`). Unique.
  final String movieKey;
  final int? tmdbId;
  final String? title;
  final int? year;
  final String? overview;

  /// Runtime in milliseconds, matching how durations are stored elsewhere.
  final int? runtimeMs;
  final double voteAverage;

  /// JSON array of genre names.
  final String? genres;

  /// TMDB-relative artwork paths (`/abc.jpg`), kept so a different size can be
  /// re-derived later without searching again.
  final String? posterPath;
  final String? backdropPath;

  /// Absolute on-device paths. The UI reads only these — never the network.
  final String? localPosterPath;
  final String? localBackdropPath;

  /// 0–1 score from the matcher; 0 when nothing was accepted.
  final double matchConfidence;
  final MatchStatus matchStatus;
  final DateTime? lastRefreshed;
  const MovieMetadataData({
    required this.id,
    required this.movieKey,
    this.tmdbId,
    this.title,
    this.year,
    this.overview,
    this.runtimeMs,
    required this.voteAverage,
    this.genres,
    this.posterPath,
    this.backdropPath,
    this.localPosterPath,
    this.localBackdropPath,
    required this.matchConfidence,
    required this.matchStatus,
    this.lastRefreshed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['movie_key'] = Variable<String>(movieKey);
    if (!nullToAbsent || tmdbId != null) {
      map['tmdb_id'] = Variable<int>(tmdbId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    if (!nullToAbsent || runtimeMs != null) {
      map['runtime_ms'] = Variable<int>(runtimeMs);
    }
    map['vote_average'] = Variable<double>(voteAverage);
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    if (!nullToAbsent || posterPath != null) {
      map['poster_path'] = Variable<String>(posterPath);
    }
    if (!nullToAbsent || backdropPath != null) {
      map['backdrop_path'] = Variable<String>(backdropPath);
    }
    if (!nullToAbsent || localPosterPath != null) {
      map['local_poster_path'] = Variable<String>(localPosterPath);
    }
    if (!nullToAbsent || localBackdropPath != null) {
      map['local_backdrop_path'] = Variable<String>(localBackdropPath);
    }
    map['match_confidence'] = Variable<double>(matchConfidence);
    {
      map['match_status'] = Variable<int>(
        $MovieMetadataTable.$convertermatchStatus.toSql(matchStatus),
      );
    }
    if (!nullToAbsent || lastRefreshed != null) {
      map['last_refreshed'] = Variable<DateTime>(lastRefreshed);
    }
    return map;
  }

  MovieMetadataCompanion toCompanion(bool nullToAbsent) {
    return MovieMetadataCompanion(
      id: Value(id),
      movieKey: Value(movieKey),
      tmdbId:
          tmdbId == null && nullToAbsent ? const Value.absent() : Value(tmdbId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      overview:
          overview == null && nullToAbsent
              ? const Value.absent()
              : Value(overview),
      runtimeMs:
          runtimeMs == null && nullToAbsent
              ? const Value.absent()
              : Value(runtimeMs),
      voteAverage: Value(voteAverage),
      genres:
          genres == null && nullToAbsent ? const Value.absent() : Value(genres),
      posterPath:
          posterPath == null && nullToAbsent
              ? const Value.absent()
              : Value(posterPath),
      backdropPath:
          backdropPath == null && nullToAbsent
              ? const Value.absent()
              : Value(backdropPath),
      localPosterPath:
          localPosterPath == null && nullToAbsent
              ? const Value.absent()
              : Value(localPosterPath),
      localBackdropPath:
          localBackdropPath == null && nullToAbsent
              ? const Value.absent()
              : Value(localBackdropPath),
      matchConfidence: Value(matchConfidence),
      matchStatus: Value(matchStatus),
      lastRefreshed:
          lastRefreshed == null && nullToAbsent
              ? const Value.absent()
              : Value(lastRefreshed),
    );
  }

  factory MovieMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovieMetadataData(
      id: serializer.fromJson<int>(json['id']),
      movieKey: serializer.fromJson<String>(json['movieKey']),
      tmdbId: serializer.fromJson<int?>(json['tmdbId']),
      title: serializer.fromJson<String?>(json['title']),
      year: serializer.fromJson<int?>(json['year']),
      overview: serializer.fromJson<String?>(json['overview']),
      runtimeMs: serializer.fromJson<int?>(json['runtimeMs']),
      voteAverage: serializer.fromJson<double>(json['voteAverage']),
      genres: serializer.fromJson<String?>(json['genres']),
      posterPath: serializer.fromJson<String?>(json['posterPath']),
      backdropPath: serializer.fromJson<String?>(json['backdropPath']),
      localPosterPath: serializer.fromJson<String?>(json['localPosterPath']),
      localBackdropPath: serializer.fromJson<String?>(
        json['localBackdropPath'],
      ),
      matchConfidence: serializer.fromJson<double>(json['matchConfidence']),
      matchStatus: $MovieMetadataTable.$convertermatchStatus.fromJson(
        serializer.fromJson<int>(json['matchStatus']),
      ),
      lastRefreshed: serializer.fromJson<DateTime?>(json['lastRefreshed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'movieKey': serializer.toJson<String>(movieKey),
      'tmdbId': serializer.toJson<int?>(tmdbId),
      'title': serializer.toJson<String?>(title),
      'year': serializer.toJson<int?>(year),
      'overview': serializer.toJson<String?>(overview),
      'runtimeMs': serializer.toJson<int?>(runtimeMs),
      'voteAverage': serializer.toJson<double>(voteAverage),
      'genres': serializer.toJson<String?>(genres),
      'posterPath': serializer.toJson<String?>(posterPath),
      'backdropPath': serializer.toJson<String?>(backdropPath),
      'localPosterPath': serializer.toJson<String?>(localPosterPath),
      'localBackdropPath': serializer.toJson<String?>(localBackdropPath),
      'matchConfidence': serializer.toJson<double>(matchConfidence),
      'matchStatus': serializer.toJson<int>(
        $MovieMetadataTable.$convertermatchStatus.toJson(matchStatus),
      ),
      'lastRefreshed': serializer.toJson<DateTime?>(lastRefreshed),
    };
  }

  MovieMetadataData copyWith({
    int? id,
    String? movieKey,
    Value<int?> tmdbId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> overview = const Value.absent(),
    Value<int?> runtimeMs = const Value.absent(),
    double? voteAverage,
    Value<String?> genres = const Value.absent(),
    Value<String?> posterPath = const Value.absent(),
    Value<String?> backdropPath = const Value.absent(),
    Value<String?> localPosterPath = const Value.absent(),
    Value<String?> localBackdropPath = const Value.absent(),
    double? matchConfidence,
    MatchStatus? matchStatus,
    Value<DateTime?> lastRefreshed = const Value.absent(),
  }) => MovieMetadataData(
    id: id ?? this.id,
    movieKey: movieKey ?? this.movieKey,
    tmdbId: tmdbId.present ? tmdbId.value : this.tmdbId,
    title: title.present ? title.value : this.title,
    year: year.present ? year.value : this.year,
    overview: overview.present ? overview.value : this.overview,
    runtimeMs: runtimeMs.present ? runtimeMs.value : this.runtimeMs,
    voteAverage: voteAverage ?? this.voteAverage,
    genres: genres.present ? genres.value : this.genres,
    posterPath: posterPath.present ? posterPath.value : this.posterPath,
    backdropPath: backdropPath.present ? backdropPath.value : this.backdropPath,
    localPosterPath:
        localPosterPath.present ? localPosterPath.value : this.localPosterPath,
    localBackdropPath:
        localBackdropPath.present
            ? localBackdropPath.value
            : this.localBackdropPath,
    matchConfidence: matchConfidence ?? this.matchConfidence,
    matchStatus: matchStatus ?? this.matchStatus,
    lastRefreshed:
        lastRefreshed.present ? lastRefreshed.value : this.lastRefreshed,
  );
  MovieMetadataData copyWithCompanion(MovieMetadataCompanion data) {
    return MovieMetadataData(
      id: data.id.present ? data.id.value : this.id,
      movieKey: data.movieKey.present ? data.movieKey.value : this.movieKey,
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      title: data.title.present ? data.title.value : this.title,
      year: data.year.present ? data.year.value : this.year,
      overview: data.overview.present ? data.overview.value : this.overview,
      runtimeMs: data.runtimeMs.present ? data.runtimeMs.value : this.runtimeMs,
      voteAverage:
          data.voteAverage.present ? data.voteAverage.value : this.voteAverage,
      genres: data.genres.present ? data.genres.value : this.genres,
      posterPath:
          data.posterPath.present ? data.posterPath.value : this.posterPath,
      backdropPath:
          data.backdropPath.present
              ? data.backdropPath.value
              : this.backdropPath,
      localPosterPath:
          data.localPosterPath.present
              ? data.localPosterPath.value
              : this.localPosterPath,
      localBackdropPath:
          data.localBackdropPath.present
              ? data.localBackdropPath.value
              : this.localBackdropPath,
      matchConfidence:
          data.matchConfidence.present
              ? data.matchConfidence.value
              : this.matchConfidence,
      matchStatus:
          data.matchStatus.present ? data.matchStatus.value : this.matchStatus,
      lastRefreshed:
          data.lastRefreshed.present
              ? data.lastRefreshed.value
              : this.lastRefreshed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovieMetadataData(')
          ..write('id: $id, ')
          ..write('movieKey: $movieKey, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('title: $title, ')
          ..write('year: $year, ')
          ..write('overview: $overview, ')
          ..write('runtimeMs: $runtimeMs, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('genres: $genres, ')
          ..write('posterPath: $posterPath, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('localPosterPath: $localPosterPath, ')
          ..write('localBackdropPath: $localBackdropPath, ')
          ..write('matchConfidence: $matchConfidence, ')
          ..write('matchStatus: $matchStatus, ')
          ..write('lastRefreshed: $lastRefreshed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    movieKey,
    tmdbId,
    title,
    year,
    overview,
    runtimeMs,
    voteAverage,
    genres,
    posterPath,
    backdropPath,
    localPosterPath,
    localBackdropPath,
    matchConfidence,
    matchStatus,
    lastRefreshed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovieMetadataData &&
          other.id == this.id &&
          other.movieKey == this.movieKey &&
          other.tmdbId == this.tmdbId &&
          other.title == this.title &&
          other.year == this.year &&
          other.overview == this.overview &&
          other.runtimeMs == this.runtimeMs &&
          other.voteAverage == this.voteAverage &&
          other.genres == this.genres &&
          other.posterPath == this.posterPath &&
          other.backdropPath == this.backdropPath &&
          other.localPosterPath == this.localPosterPath &&
          other.localBackdropPath == this.localBackdropPath &&
          other.matchConfidence == this.matchConfidence &&
          other.matchStatus == this.matchStatus &&
          other.lastRefreshed == this.lastRefreshed);
}

class MovieMetadataCompanion extends UpdateCompanion<MovieMetadataData> {
  final Value<int> id;
  final Value<String> movieKey;
  final Value<int?> tmdbId;
  final Value<String?> title;
  final Value<int?> year;
  final Value<String?> overview;
  final Value<int?> runtimeMs;
  final Value<double> voteAverage;
  final Value<String?> genres;
  final Value<String?> posterPath;
  final Value<String?> backdropPath;
  final Value<String?> localPosterPath;
  final Value<String?> localBackdropPath;
  final Value<double> matchConfidence;
  final Value<MatchStatus> matchStatus;
  final Value<DateTime?> lastRefreshed;
  const MovieMetadataCompanion({
    this.id = const Value.absent(),
    this.movieKey = const Value.absent(),
    this.tmdbId = const Value.absent(),
    this.title = const Value.absent(),
    this.year = const Value.absent(),
    this.overview = const Value.absent(),
    this.runtimeMs = const Value.absent(),
    this.voteAverage = const Value.absent(),
    this.genres = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.localPosterPath = const Value.absent(),
    this.localBackdropPath = const Value.absent(),
    this.matchConfidence = const Value.absent(),
    this.matchStatus = const Value.absent(),
    this.lastRefreshed = const Value.absent(),
  });
  MovieMetadataCompanion.insert({
    this.id = const Value.absent(),
    required String movieKey,
    this.tmdbId = const Value.absent(),
    this.title = const Value.absent(),
    this.year = const Value.absent(),
    this.overview = const Value.absent(),
    this.runtimeMs = const Value.absent(),
    this.voteAverage = const Value.absent(),
    this.genres = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.localPosterPath = const Value.absent(),
    this.localBackdropPath = const Value.absent(),
    this.matchConfidence = const Value.absent(),
    this.matchStatus = const Value.absent(),
    this.lastRefreshed = const Value.absent(),
  }) : movieKey = Value(movieKey);
  static Insertable<MovieMetadataData> custom({
    Expression<int>? id,
    Expression<String>? movieKey,
    Expression<int>? tmdbId,
    Expression<String>? title,
    Expression<int>? year,
    Expression<String>? overview,
    Expression<int>? runtimeMs,
    Expression<double>? voteAverage,
    Expression<String>? genres,
    Expression<String>? posterPath,
    Expression<String>? backdropPath,
    Expression<String>? localPosterPath,
    Expression<String>? localBackdropPath,
    Expression<double>? matchConfidence,
    Expression<int>? matchStatus,
    Expression<DateTime>? lastRefreshed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (movieKey != null) 'movie_key': movieKey,
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (title != null) 'title': title,
      if (year != null) 'year': year,
      if (overview != null) 'overview': overview,
      if (runtimeMs != null) 'runtime_ms': runtimeMs,
      if (voteAverage != null) 'vote_average': voteAverage,
      if (genres != null) 'genres': genres,
      if (posterPath != null) 'poster_path': posterPath,
      if (backdropPath != null) 'backdrop_path': backdropPath,
      if (localPosterPath != null) 'local_poster_path': localPosterPath,
      if (localBackdropPath != null) 'local_backdrop_path': localBackdropPath,
      if (matchConfidence != null) 'match_confidence': matchConfidence,
      if (matchStatus != null) 'match_status': matchStatus,
      if (lastRefreshed != null) 'last_refreshed': lastRefreshed,
    });
  }

  MovieMetadataCompanion copyWith({
    Value<int>? id,
    Value<String>? movieKey,
    Value<int?>? tmdbId,
    Value<String?>? title,
    Value<int?>? year,
    Value<String?>? overview,
    Value<int?>? runtimeMs,
    Value<double>? voteAverage,
    Value<String?>? genres,
    Value<String?>? posterPath,
    Value<String?>? backdropPath,
    Value<String?>? localPosterPath,
    Value<String?>? localBackdropPath,
    Value<double>? matchConfidence,
    Value<MatchStatus>? matchStatus,
    Value<DateTime?>? lastRefreshed,
  }) {
    return MovieMetadataCompanion(
      id: id ?? this.id,
      movieKey: movieKey ?? this.movieKey,
      tmdbId: tmdbId ?? this.tmdbId,
      title: title ?? this.title,
      year: year ?? this.year,
      overview: overview ?? this.overview,
      runtimeMs: runtimeMs ?? this.runtimeMs,
      voteAverage: voteAverage ?? this.voteAverage,
      genres: genres ?? this.genres,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      localPosterPath: localPosterPath ?? this.localPosterPath,
      localBackdropPath: localBackdropPath ?? this.localBackdropPath,
      matchConfidence: matchConfidence ?? this.matchConfidence,
      matchStatus: matchStatus ?? this.matchStatus,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (movieKey.present) {
      map['movie_key'] = Variable<String>(movieKey.value);
    }
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (runtimeMs.present) {
      map['runtime_ms'] = Variable<int>(runtimeMs.value);
    }
    if (voteAverage.present) {
      map['vote_average'] = Variable<double>(voteAverage.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (posterPath.present) {
      map['poster_path'] = Variable<String>(posterPath.value);
    }
    if (backdropPath.present) {
      map['backdrop_path'] = Variable<String>(backdropPath.value);
    }
    if (localPosterPath.present) {
      map['local_poster_path'] = Variable<String>(localPosterPath.value);
    }
    if (localBackdropPath.present) {
      map['local_backdrop_path'] = Variable<String>(localBackdropPath.value);
    }
    if (matchConfidence.present) {
      map['match_confidence'] = Variable<double>(matchConfidence.value);
    }
    if (matchStatus.present) {
      map['match_status'] = Variable<int>(
        $MovieMetadataTable.$convertermatchStatus.toSql(matchStatus.value),
      );
    }
    if (lastRefreshed.present) {
      map['last_refreshed'] = Variable<DateTime>(lastRefreshed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovieMetadataCompanion(')
          ..write('id: $id, ')
          ..write('movieKey: $movieKey, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('title: $title, ')
          ..write('year: $year, ')
          ..write('overview: $overview, ')
          ..write('runtimeMs: $runtimeMs, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('genres: $genres, ')
          ..write('posterPath: $posterPath, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('localPosterPath: $localPosterPath, ')
          ..write('localBackdropPath: $localBackdropPath, ')
          ..write('matchConfidence: $matchConfidence, ')
          ..write('matchStatus: $matchStatus, ')
          ..write('lastRefreshed: $lastRefreshed')
          ..write(')'))
        .toString();
  }
}

class $ShowMetadataTable extends ShowMetadata
    with TableInfo<$ShowMetadataTable, ShowMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShowMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _showKeyMeta = const VerificationMeta(
    'showKey',
  );
  @override
  late final GeneratedColumn<String> showKey = GeneratedColumn<String>(
    'show_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
    'tmdb_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstAirYearMeta = const VerificationMeta(
    'firstAirYear',
  );
  @override
  late final GeneratedColumn<int> firstAirYear = GeneratedColumn<int>(
    'first_air_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overviewMeta = const VerificationMeta(
    'overview',
  );
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
    'overview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posterPathMeta = const VerificationMeta(
    'posterPath',
  );
  @override
  late final GeneratedColumn<String> posterPath = GeneratedColumn<String>(
    'poster_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backdropPathMeta = const VerificationMeta(
    'backdropPath',
  );
  @override
  late final GeneratedColumn<String> backdropPath = GeneratedColumn<String>(
    'backdrop_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPosterPathMeta = const VerificationMeta(
    'localPosterPath',
  );
  @override
  late final GeneratedColumn<String> localPosterPath = GeneratedColumn<String>(
    'local_poster_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localBackdropPathMeta = const VerificationMeta(
    'localBackdropPath',
  );
  @override
  late final GeneratedColumn<String> localBackdropPath =
      GeneratedColumn<String>(
        'local_backdrop_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _matchConfidenceMeta = const VerificationMeta(
    'matchConfidence',
  );
  @override
  late final GeneratedColumn<double> matchConfidence = GeneratedColumn<double>(
    'match_confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MatchStatus, int> matchStatus =
      GeneratedColumn<int>(
        'match_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(MatchStatus.pending.index),
      ).withConverter<MatchStatus>($ShowMetadataTable.$convertermatchStatus);
  static const VerificationMeta _lastRefreshedMeta = const VerificationMeta(
    'lastRefreshed',
  );
  @override
  late final GeneratedColumn<DateTime> lastRefreshed =
      GeneratedColumn<DateTime>(
        'last_refreshed',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    showKey,
    tmdbId,
    name,
    firstAirYear,
    overview,
    genres,
    posterPath,
    backdropPath,
    localPosterPath,
    localBackdropPath,
    matchConfidence,
    matchStatus,
    lastRefreshed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'show_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShowMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('show_key')) {
      context.handle(
        _showKeyMeta,
        showKey.isAcceptableOrUnknown(data['show_key']!, _showKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_showKeyMeta);
    }
    if (data.containsKey('tmdb_id')) {
      context.handle(
        _tmdbIdMeta,
        tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('first_air_year')) {
      context.handle(
        _firstAirYearMeta,
        firstAirYear.isAcceptableOrUnknown(
          data['first_air_year']!,
          _firstAirYearMeta,
        ),
      );
    }
    if (data.containsKey('overview')) {
      context.handle(
        _overviewMeta,
        overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('poster_path')) {
      context.handle(
        _posterPathMeta,
        posterPath.isAcceptableOrUnknown(data['poster_path']!, _posterPathMeta),
      );
    }
    if (data.containsKey('backdrop_path')) {
      context.handle(
        _backdropPathMeta,
        backdropPath.isAcceptableOrUnknown(
          data['backdrop_path']!,
          _backdropPathMeta,
        ),
      );
    }
    if (data.containsKey('local_poster_path')) {
      context.handle(
        _localPosterPathMeta,
        localPosterPath.isAcceptableOrUnknown(
          data['local_poster_path']!,
          _localPosterPathMeta,
        ),
      );
    }
    if (data.containsKey('local_backdrop_path')) {
      context.handle(
        _localBackdropPathMeta,
        localBackdropPath.isAcceptableOrUnknown(
          data['local_backdrop_path']!,
          _localBackdropPathMeta,
        ),
      );
    }
    if (data.containsKey('match_confidence')) {
      context.handle(
        _matchConfidenceMeta,
        matchConfidence.isAcceptableOrUnknown(
          data['match_confidence']!,
          _matchConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('last_refreshed')) {
      context.handle(
        _lastRefreshedMeta,
        lastRefreshed.isAcceptableOrUnknown(
          data['last_refreshed']!,
          _lastRefreshedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShowMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShowMetadataData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      showKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}show_key'],
          )!,
      tmdbId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tmdb_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      firstAirYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_air_year'],
      ),
      overview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overview'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      posterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_path'],
      ),
      backdropPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backdrop_path'],
      ),
      localPosterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_poster_path'],
      ),
      localBackdropPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_backdrop_path'],
      ),
      matchConfidence:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}match_confidence'],
          )!,
      matchStatus: $ShowMetadataTable.$convertermatchStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}match_status'],
        )!,
      ),
      lastRefreshed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_refreshed'],
      ),
    );
  }

  @override
  $ShowMetadataTable createAlias(String alias) {
    return $ShowMetadataTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MatchStatus, int, int> $convertermatchStatus =
      const EnumIndexConverter<MatchStatus>(MatchStatus.values);
}

class ShowMetadataData extends DataClass
    implements Insertable<ShowMetadataData> {
  final int id;

  /// Normalised show title — the same key `groupIntoShows` groups files by.
  final String showKey;
  final int? tmdbId;
  final String? name;
  final int? firstAirYear;
  final String? overview;
  final String? genres;
  final String? posterPath;
  final String? backdropPath;
  final String? localPosterPath;
  final String? localBackdropPath;
  final double matchConfidence;
  final MatchStatus matchStatus;
  final DateTime? lastRefreshed;
  const ShowMetadataData({
    required this.id,
    required this.showKey,
    this.tmdbId,
    this.name,
    this.firstAirYear,
    this.overview,
    this.genres,
    this.posterPath,
    this.backdropPath,
    this.localPosterPath,
    this.localBackdropPath,
    required this.matchConfidence,
    required this.matchStatus,
    this.lastRefreshed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['show_key'] = Variable<String>(showKey);
    if (!nullToAbsent || tmdbId != null) {
      map['tmdb_id'] = Variable<int>(tmdbId);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || firstAirYear != null) {
      map['first_air_year'] = Variable<int>(firstAirYear);
    }
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    if (!nullToAbsent || posterPath != null) {
      map['poster_path'] = Variable<String>(posterPath);
    }
    if (!nullToAbsent || backdropPath != null) {
      map['backdrop_path'] = Variable<String>(backdropPath);
    }
    if (!nullToAbsent || localPosterPath != null) {
      map['local_poster_path'] = Variable<String>(localPosterPath);
    }
    if (!nullToAbsent || localBackdropPath != null) {
      map['local_backdrop_path'] = Variable<String>(localBackdropPath);
    }
    map['match_confidence'] = Variable<double>(matchConfidence);
    {
      map['match_status'] = Variable<int>(
        $ShowMetadataTable.$convertermatchStatus.toSql(matchStatus),
      );
    }
    if (!nullToAbsent || lastRefreshed != null) {
      map['last_refreshed'] = Variable<DateTime>(lastRefreshed);
    }
    return map;
  }

  ShowMetadataCompanion toCompanion(bool nullToAbsent) {
    return ShowMetadataCompanion(
      id: Value(id),
      showKey: Value(showKey),
      tmdbId:
          tmdbId == null && nullToAbsent ? const Value.absent() : Value(tmdbId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      firstAirYear:
          firstAirYear == null && nullToAbsent
              ? const Value.absent()
              : Value(firstAirYear),
      overview:
          overview == null && nullToAbsent
              ? const Value.absent()
              : Value(overview),
      genres:
          genres == null && nullToAbsent ? const Value.absent() : Value(genres),
      posterPath:
          posterPath == null && nullToAbsent
              ? const Value.absent()
              : Value(posterPath),
      backdropPath:
          backdropPath == null && nullToAbsent
              ? const Value.absent()
              : Value(backdropPath),
      localPosterPath:
          localPosterPath == null && nullToAbsent
              ? const Value.absent()
              : Value(localPosterPath),
      localBackdropPath:
          localBackdropPath == null && nullToAbsent
              ? const Value.absent()
              : Value(localBackdropPath),
      matchConfidence: Value(matchConfidence),
      matchStatus: Value(matchStatus),
      lastRefreshed:
          lastRefreshed == null && nullToAbsent
              ? const Value.absent()
              : Value(lastRefreshed),
    );
  }

  factory ShowMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShowMetadataData(
      id: serializer.fromJson<int>(json['id']),
      showKey: serializer.fromJson<String>(json['showKey']),
      tmdbId: serializer.fromJson<int?>(json['tmdbId']),
      name: serializer.fromJson<String?>(json['name']),
      firstAirYear: serializer.fromJson<int?>(json['firstAirYear']),
      overview: serializer.fromJson<String?>(json['overview']),
      genres: serializer.fromJson<String?>(json['genres']),
      posterPath: serializer.fromJson<String?>(json['posterPath']),
      backdropPath: serializer.fromJson<String?>(json['backdropPath']),
      localPosterPath: serializer.fromJson<String?>(json['localPosterPath']),
      localBackdropPath: serializer.fromJson<String?>(
        json['localBackdropPath'],
      ),
      matchConfidence: serializer.fromJson<double>(json['matchConfidence']),
      matchStatus: $ShowMetadataTable.$convertermatchStatus.fromJson(
        serializer.fromJson<int>(json['matchStatus']),
      ),
      lastRefreshed: serializer.fromJson<DateTime?>(json['lastRefreshed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'showKey': serializer.toJson<String>(showKey),
      'tmdbId': serializer.toJson<int?>(tmdbId),
      'name': serializer.toJson<String?>(name),
      'firstAirYear': serializer.toJson<int?>(firstAirYear),
      'overview': serializer.toJson<String?>(overview),
      'genres': serializer.toJson<String?>(genres),
      'posterPath': serializer.toJson<String?>(posterPath),
      'backdropPath': serializer.toJson<String?>(backdropPath),
      'localPosterPath': serializer.toJson<String?>(localPosterPath),
      'localBackdropPath': serializer.toJson<String?>(localBackdropPath),
      'matchConfidence': serializer.toJson<double>(matchConfidence),
      'matchStatus': serializer.toJson<int>(
        $ShowMetadataTable.$convertermatchStatus.toJson(matchStatus),
      ),
      'lastRefreshed': serializer.toJson<DateTime?>(lastRefreshed),
    };
  }

  ShowMetadataData copyWith({
    int? id,
    String? showKey,
    Value<int?> tmdbId = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<int?> firstAirYear = const Value.absent(),
    Value<String?> overview = const Value.absent(),
    Value<String?> genres = const Value.absent(),
    Value<String?> posterPath = const Value.absent(),
    Value<String?> backdropPath = const Value.absent(),
    Value<String?> localPosterPath = const Value.absent(),
    Value<String?> localBackdropPath = const Value.absent(),
    double? matchConfidence,
    MatchStatus? matchStatus,
    Value<DateTime?> lastRefreshed = const Value.absent(),
  }) => ShowMetadataData(
    id: id ?? this.id,
    showKey: showKey ?? this.showKey,
    tmdbId: tmdbId.present ? tmdbId.value : this.tmdbId,
    name: name.present ? name.value : this.name,
    firstAirYear: firstAirYear.present ? firstAirYear.value : this.firstAirYear,
    overview: overview.present ? overview.value : this.overview,
    genres: genres.present ? genres.value : this.genres,
    posterPath: posterPath.present ? posterPath.value : this.posterPath,
    backdropPath: backdropPath.present ? backdropPath.value : this.backdropPath,
    localPosterPath:
        localPosterPath.present ? localPosterPath.value : this.localPosterPath,
    localBackdropPath:
        localBackdropPath.present
            ? localBackdropPath.value
            : this.localBackdropPath,
    matchConfidence: matchConfidence ?? this.matchConfidence,
    matchStatus: matchStatus ?? this.matchStatus,
    lastRefreshed:
        lastRefreshed.present ? lastRefreshed.value : this.lastRefreshed,
  );
  ShowMetadataData copyWithCompanion(ShowMetadataCompanion data) {
    return ShowMetadataData(
      id: data.id.present ? data.id.value : this.id,
      showKey: data.showKey.present ? data.showKey.value : this.showKey,
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      name: data.name.present ? data.name.value : this.name,
      firstAirYear:
          data.firstAirYear.present
              ? data.firstAirYear.value
              : this.firstAirYear,
      overview: data.overview.present ? data.overview.value : this.overview,
      genres: data.genres.present ? data.genres.value : this.genres,
      posterPath:
          data.posterPath.present ? data.posterPath.value : this.posterPath,
      backdropPath:
          data.backdropPath.present
              ? data.backdropPath.value
              : this.backdropPath,
      localPosterPath:
          data.localPosterPath.present
              ? data.localPosterPath.value
              : this.localPosterPath,
      localBackdropPath:
          data.localBackdropPath.present
              ? data.localBackdropPath.value
              : this.localBackdropPath,
      matchConfidence:
          data.matchConfidence.present
              ? data.matchConfidence.value
              : this.matchConfidence,
      matchStatus:
          data.matchStatus.present ? data.matchStatus.value : this.matchStatus,
      lastRefreshed:
          data.lastRefreshed.present
              ? data.lastRefreshed.value
              : this.lastRefreshed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShowMetadataData(')
          ..write('id: $id, ')
          ..write('showKey: $showKey, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('name: $name, ')
          ..write('firstAirYear: $firstAirYear, ')
          ..write('overview: $overview, ')
          ..write('genres: $genres, ')
          ..write('posterPath: $posterPath, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('localPosterPath: $localPosterPath, ')
          ..write('localBackdropPath: $localBackdropPath, ')
          ..write('matchConfidence: $matchConfidence, ')
          ..write('matchStatus: $matchStatus, ')
          ..write('lastRefreshed: $lastRefreshed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    showKey,
    tmdbId,
    name,
    firstAirYear,
    overview,
    genres,
    posterPath,
    backdropPath,
    localPosterPath,
    localBackdropPath,
    matchConfidence,
    matchStatus,
    lastRefreshed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShowMetadataData &&
          other.id == this.id &&
          other.showKey == this.showKey &&
          other.tmdbId == this.tmdbId &&
          other.name == this.name &&
          other.firstAirYear == this.firstAirYear &&
          other.overview == this.overview &&
          other.genres == this.genres &&
          other.posterPath == this.posterPath &&
          other.backdropPath == this.backdropPath &&
          other.localPosterPath == this.localPosterPath &&
          other.localBackdropPath == this.localBackdropPath &&
          other.matchConfidence == this.matchConfidence &&
          other.matchStatus == this.matchStatus &&
          other.lastRefreshed == this.lastRefreshed);
}

class ShowMetadataCompanion extends UpdateCompanion<ShowMetadataData> {
  final Value<int> id;
  final Value<String> showKey;
  final Value<int?> tmdbId;
  final Value<String?> name;
  final Value<int?> firstAirYear;
  final Value<String?> overview;
  final Value<String?> genres;
  final Value<String?> posterPath;
  final Value<String?> backdropPath;
  final Value<String?> localPosterPath;
  final Value<String?> localBackdropPath;
  final Value<double> matchConfidence;
  final Value<MatchStatus> matchStatus;
  final Value<DateTime?> lastRefreshed;
  const ShowMetadataCompanion({
    this.id = const Value.absent(),
    this.showKey = const Value.absent(),
    this.tmdbId = const Value.absent(),
    this.name = const Value.absent(),
    this.firstAirYear = const Value.absent(),
    this.overview = const Value.absent(),
    this.genres = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.localPosterPath = const Value.absent(),
    this.localBackdropPath = const Value.absent(),
    this.matchConfidence = const Value.absent(),
    this.matchStatus = const Value.absent(),
    this.lastRefreshed = const Value.absent(),
  });
  ShowMetadataCompanion.insert({
    this.id = const Value.absent(),
    required String showKey,
    this.tmdbId = const Value.absent(),
    this.name = const Value.absent(),
    this.firstAirYear = const Value.absent(),
    this.overview = const Value.absent(),
    this.genres = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.localPosterPath = const Value.absent(),
    this.localBackdropPath = const Value.absent(),
    this.matchConfidence = const Value.absent(),
    this.matchStatus = const Value.absent(),
    this.lastRefreshed = const Value.absent(),
  }) : showKey = Value(showKey);
  static Insertable<ShowMetadataData> custom({
    Expression<int>? id,
    Expression<String>? showKey,
    Expression<int>? tmdbId,
    Expression<String>? name,
    Expression<int>? firstAirYear,
    Expression<String>? overview,
    Expression<String>? genres,
    Expression<String>? posterPath,
    Expression<String>? backdropPath,
    Expression<String>? localPosterPath,
    Expression<String>? localBackdropPath,
    Expression<double>? matchConfidence,
    Expression<int>? matchStatus,
    Expression<DateTime>? lastRefreshed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (showKey != null) 'show_key': showKey,
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (name != null) 'name': name,
      if (firstAirYear != null) 'first_air_year': firstAirYear,
      if (overview != null) 'overview': overview,
      if (genres != null) 'genres': genres,
      if (posterPath != null) 'poster_path': posterPath,
      if (backdropPath != null) 'backdrop_path': backdropPath,
      if (localPosterPath != null) 'local_poster_path': localPosterPath,
      if (localBackdropPath != null) 'local_backdrop_path': localBackdropPath,
      if (matchConfidence != null) 'match_confidence': matchConfidence,
      if (matchStatus != null) 'match_status': matchStatus,
      if (lastRefreshed != null) 'last_refreshed': lastRefreshed,
    });
  }

  ShowMetadataCompanion copyWith({
    Value<int>? id,
    Value<String>? showKey,
    Value<int?>? tmdbId,
    Value<String?>? name,
    Value<int?>? firstAirYear,
    Value<String?>? overview,
    Value<String?>? genres,
    Value<String?>? posterPath,
    Value<String?>? backdropPath,
    Value<String?>? localPosterPath,
    Value<String?>? localBackdropPath,
    Value<double>? matchConfidence,
    Value<MatchStatus>? matchStatus,
    Value<DateTime?>? lastRefreshed,
  }) {
    return ShowMetadataCompanion(
      id: id ?? this.id,
      showKey: showKey ?? this.showKey,
      tmdbId: tmdbId ?? this.tmdbId,
      name: name ?? this.name,
      firstAirYear: firstAirYear ?? this.firstAirYear,
      overview: overview ?? this.overview,
      genres: genres ?? this.genres,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      localPosterPath: localPosterPath ?? this.localPosterPath,
      localBackdropPath: localBackdropPath ?? this.localBackdropPath,
      matchConfidence: matchConfidence ?? this.matchConfidence,
      matchStatus: matchStatus ?? this.matchStatus,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (showKey.present) {
      map['show_key'] = Variable<String>(showKey.value);
    }
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (firstAirYear.present) {
      map['first_air_year'] = Variable<int>(firstAirYear.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (posterPath.present) {
      map['poster_path'] = Variable<String>(posterPath.value);
    }
    if (backdropPath.present) {
      map['backdrop_path'] = Variable<String>(backdropPath.value);
    }
    if (localPosterPath.present) {
      map['local_poster_path'] = Variable<String>(localPosterPath.value);
    }
    if (localBackdropPath.present) {
      map['local_backdrop_path'] = Variable<String>(localBackdropPath.value);
    }
    if (matchConfidence.present) {
      map['match_confidence'] = Variable<double>(matchConfidence.value);
    }
    if (matchStatus.present) {
      map['match_status'] = Variable<int>(
        $ShowMetadataTable.$convertermatchStatus.toSql(matchStatus.value),
      );
    }
    if (lastRefreshed.present) {
      map['last_refreshed'] = Variable<DateTime>(lastRefreshed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShowMetadataCompanion(')
          ..write('id: $id, ')
          ..write('showKey: $showKey, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('name: $name, ')
          ..write('firstAirYear: $firstAirYear, ')
          ..write('overview: $overview, ')
          ..write('genres: $genres, ')
          ..write('posterPath: $posterPath, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('localPosterPath: $localPosterPath, ')
          ..write('localBackdropPath: $localBackdropPath, ')
          ..write('matchConfidence: $matchConfidence, ')
          ..write('matchStatus: $matchStatus, ')
          ..write('lastRefreshed: $lastRefreshed')
          ..write(')'))
        .toString();
  }
}

class $EpisodeMetadataTable extends EpisodeMetadata
    with TableInfo<$EpisodeMetadataTable, EpisodeMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodeMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _showTmdbIdMeta = const VerificationMeta(
    'showTmdbId',
  );
  @override
  late final GeneratedColumn<int> showTmdbId = GeneratedColumn<int>(
    'show_tmdb_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeMeta = const VerificationMeta(
    'episode',
  );
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
    'episode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overviewMeta = const VerificationMeta(
    'overview',
  );
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
    'overview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _airDateMeta = const VerificationMeta(
    'airDate',
  );
  @override
  late final GeneratedColumn<DateTime> airDate = GeneratedColumn<DateTime>(
    'air_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stillPathMeta = const VerificationMeta(
    'stillPath',
  );
  @override
  late final GeneratedColumn<String> stillPath = GeneratedColumn<String>(
    'still_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localStillPathMeta = const VerificationMeta(
    'localStillPath',
  );
  @override
  late final GeneratedColumn<String> localStillPath = GeneratedColumn<String>(
    'local_still_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runtimeMsMeta = const VerificationMeta(
    'runtimeMs',
  );
  @override
  late final GeneratedColumn<int> runtimeMs = GeneratedColumn<int>(
    'runtime_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastRefreshedMeta = const VerificationMeta(
    'lastRefreshed',
  );
  @override
  late final GeneratedColumn<DateTime> lastRefreshed =
      GeneratedColumn<DateTime>(
        'last_refreshed',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    showTmdbId,
    season,
    episode,
    name,
    overview,
    airDate,
    stillPath,
    localStillPath,
    runtimeMs,
    lastRefreshed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episode_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpisodeMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('show_tmdb_id')) {
      context.handle(
        _showTmdbIdMeta,
        showTmdbId.isAcceptableOrUnknown(
          data['show_tmdb_id']!,
          _showTmdbIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_showTmdbIdMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('episode')) {
      context.handle(
        _episodeMeta,
        episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('overview')) {
      context.handle(
        _overviewMeta,
        overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta),
      );
    }
    if (data.containsKey('air_date')) {
      context.handle(
        _airDateMeta,
        airDate.isAcceptableOrUnknown(data['air_date']!, _airDateMeta),
      );
    }
    if (data.containsKey('still_path')) {
      context.handle(
        _stillPathMeta,
        stillPath.isAcceptableOrUnknown(data['still_path']!, _stillPathMeta),
      );
    }
    if (data.containsKey('local_still_path')) {
      context.handle(
        _localStillPathMeta,
        localStillPath.isAcceptableOrUnknown(
          data['local_still_path']!,
          _localStillPathMeta,
        ),
      );
    }
    if (data.containsKey('runtime_ms')) {
      context.handle(
        _runtimeMsMeta,
        runtimeMs.isAcceptableOrUnknown(data['runtime_ms']!, _runtimeMsMeta),
      );
    }
    if (data.containsKey('last_refreshed')) {
      context.handle(
        _lastRefreshedMeta,
        lastRefreshed.isAcceptableOrUnknown(
          data['last_refreshed']!,
          _lastRefreshedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {showTmdbId, season, episode},
  ];
  @override
  EpisodeMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpisodeMetadataData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      showTmdbId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}show_tmdb_id'],
          )!,
      season:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}season'],
          )!,
      episode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}episode'],
          )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      overview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overview'],
      ),
      airDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}air_date'],
      ),
      stillPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}still_path'],
      ),
      localStillPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_still_path'],
      ),
      runtimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runtime_ms'],
      ),
      lastRefreshed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_refreshed'],
      ),
    );
  }

  @override
  $EpisodeMetadataTable createAlias(String alias) {
    return $EpisodeMetadataTable(attachedDatabase, alias);
  }
}

class EpisodeMetadataData extends DataClass
    implements Insertable<EpisodeMetadataData> {
  final int id;
  final int showTmdbId;
  final int season;
  final int episode;
  final String? name;
  final String? overview;
  final DateTime? airDate;
  final String? stillPath;
  final String? localStillPath;
  final int? runtimeMs;
  final DateTime? lastRefreshed;
  const EpisodeMetadataData({
    required this.id,
    required this.showTmdbId,
    required this.season,
    required this.episode,
    this.name,
    this.overview,
    this.airDate,
    this.stillPath,
    this.localStillPath,
    this.runtimeMs,
    this.lastRefreshed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['show_tmdb_id'] = Variable<int>(showTmdbId);
    map['season'] = Variable<int>(season);
    map['episode'] = Variable<int>(episode);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    if (!nullToAbsent || airDate != null) {
      map['air_date'] = Variable<DateTime>(airDate);
    }
    if (!nullToAbsent || stillPath != null) {
      map['still_path'] = Variable<String>(stillPath);
    }
    if (!nullToAbsent || localStillPath != null) {
      map['local_still_path'] = Variable<String>(localStillPath);
    }
    if (!nullToAbsent || runtimeMs != null) {
      map['runtime_ms'] = Variable<int>(runtimeMs);
    }
    if (!nullToAbsent || lastRefreshed != null) {
      map['last_refreshed'] = Variable<DateTime>(lastRefreshed);
    }
    return map;
  }

  EpisodeMetadataCompanion toCompanion(bool nullToAbsent) {
    return EpisodeMetadataCompanion(
      id: Value(id),
      showTmdbId: Value(showTmdbId),
      season: Value(season),
      episode: Value(episode),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      overview:
          overview == null && nullToAbsent
              ? const Value.absent()
              : Value(overview),
      airDate:
          airDate == null && nullToAbsent
              ? const Value.absent()
              : Value(airDate),
      stillPath:
          stillPath == null && nullToAbsent
              ? const Value.absent()
              : Value(stillPath),
      localStillPath:
          localStillPath == null && nullToAbsent
              ? const Value.absent()
              : Value(localStillPath),
      runtimeMs:
          runtimeMs == null && nullToAbsent
              ? const Value.absent()
              : Value(runtimeMs),
      lastRefreshed:
          lastRefreshed == null && nullToAbsent
              ? const Value.absent()
              : Value(lastRefreshed),
    );
  }

  factory EpisodeMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpisodeMetadataData(
      id: serializer.fromJson<int>(json['id']),
      showTmdbId: serializer.fromJson<int>(json['showTmdbId']),
      season: serializer.fromJson<int>(json['season']),
      episode: serializer.fromJson<int>(json['episode']),
      name: serializer.fromJson<String?>(json['name']),
      overview: serializer.fromJson<String?>(json['overview']),
      airDate: serializer.fromJson<DateTime?>(json['airDate']),
      stillPath: serializer.fromJson<String?>(json['stillPath']),
      localStillPath: serializer.fromJson<String?>(json['localStillPath']),
      runtimeMs: serializer.fromJson<int?>(json['runtimeMs']),
      lastRefreshed: serializer.fromJson<DateTime?>(json['lastRefreshed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'showTmdbId': serializer.toJson<int>(showTmdbId),
      'season': serializer.toJson<int>(season),
      'episode': serializer.toJson<int>(episode),
      'name': serializer.toJson<String?>(name),
      'overview': serializer.toJson<String?>(overview),
      'airDate': serializer.toJson<DateTime?>(airDate),
      'stillPath': serializer.toJson<String?>(stillPath),
      'localStillPath': serializer.toJson<String?>(localStillPath),
      'runtimeMs': serializer.toJson<int?>(runtimeMs),
      'lastRefreshed': serializer.toJson<DateTime?>(lastRefreshed),
    };
  }

  EpisodeMetadataData copyWith({
    int? id,
    int? showTmdbId,
    int? season,
    int? episode,
    Value<String?> name = const Value.absent(),
    Value<String?> overview = const Value.absent(),
    Value<DateTime?> airDate = const Value.absent(),
    Value<String?> stillPath = const Value.absent(),
    Value<String?> localStillPath = const Value.absent(),
    Value<int?> runtimeMs = const Value.absent(),
    Value<DateTime?> lastRefreshed = const Value.absent(),
  }) => EpisodeMetadataData(
    id: id ?? this.id,
    showTmdbId: showTmdbId ?? this.showTmdbId,
    season: season ?? this.season,
    episode: episode ?? this.episode,
    name: name.present ? name.value : this.name,
    overview: overview.present ? overview.value : this.overview,
    airDate: airDate.present ? airDate.value : this.airDate,
    stillPath: stillPath.present ? stillPath.value : this.stillPath,
    localStillPath:
        localStillPath.present ? localStillPath.value : this.localStillPath,
    runtimeMs: runtimeMs.present ? runtimeMs.value : this.runtimeMs,
    lastRefreshed:
        lastRefreshed.present ? lastRefreshed.value : this.lastRefreshed,
  );
  EpisodeMetadataData copyWithCompanion(EpisodeMetadataCompanion data) {
    return EpisodeMetadataData(
      id: data.id.present ? data.id.value : this.id,
      showTmdbId:
          data.showTmdbId.present ? data.showTmdbId.value : this.showTmdbId,
      season: data.season.present ? data.season.value : this.season,
      episode: data.episode.present ? data.episode.value : this.episode,
      name: data.name.present ? data.name.value : this.name,
      overview: data.overview.present ? data.overview.value : this.overview,
      airDate: data.airDate.present ? data.airDate.value : this.airDate,
      stillPath: data.stillPath.present ? data.stillPath.value : this.stillPath,
      localStillPath:
          data.localStillPath.present
              ? data.localStillPath.value
              : this.localStillPath,
      runtimeMs: data.runtimeMs.present ? data.runtimeMs.value : this.runtimeMs,
      lastRefreshed:
          data.lastRefreshed.present
              ? data.lastRefreshed.value
              : this.lastRefreshed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeMetadataData(')
          ..write('id: $id, ')
          ..write('showTmdbId: $showTmdbId, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('name: $name, ')
          ..write('overview: $overview, ')
          ..write('airDate: $airDate, ')
          ..write('stillPath: $stillPath, ')
          ..write('localStillPath: $localStillPath, ')
          ..write('runtimeMs: $runtimeMs, ')
          ..write('lastRefreshed: $lastRefreshed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    showTmdbId,
    season,
    episode,
    name,
    overview,
    airDate,
    stillPath,
    localStillPath,
    runtimeMs,
    lastRefreshed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpisodeMetadataData &&
          other.id == this.id &&
          other.showTmdbId == this.showTmdbId &&
          other.season == this.season &&
          other.episode == this.episode &&
          other.name == this.name &&
          other.overview == this.overview &&
          other.airDate == this.airDate &&
          other.stillPath == this.stillPath &&
          other.localStillPath == this.localStillPath &&
          other.runtimeMs == this.runtimeMs &&
          other.lastRefreshed == this.lastRefreshed);
}

class EpisodeMetadataCompanion extends UpdateCompanion<EpisodeMetadataData> {
  final Value<int> id;
  final Value<int> showTmdbId;
  final Value<int> season;
  final Value<int> episode;
  final Value<String?> name;
  final Value<String?> overview;
  final Value<DateTime?> airDate;
  final Value<String?> stillPath;
  final Value<String?> localStillPath;
  final Value<int?> runtimeMs;
  final Value<DateTime?> lastRefreshed;
  const EpisodeMetadataCompanion({
    this.id = const Value.absent(),
    this.showTmdbId = const Value.absent(),
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.name = const Value.absent(),
    this.overview = const Value.absent(),
    this.airDate = const Value.absent(),
    this.stillPath = const Value.absent(),
    this.localStillPath = const Value.absent(),
    this.runtimeMs = const Value.absent(),
    this.lastRefreshed = const Value.absent(),
  });
  EpisodeMetadataCompanion.insert({
    this.id = const Value.absent(),
    required int showTmdbId,
    required int season,
    required int episode,
    this.name = const Value.absent(),
    this.overview = const Value.absent(),
    this.airDate = const Value.absent(),
    this.stillPath = const Value.absent(),
    this.localStillPath = const Value.absent(),
    this.runtimeMs = const Value.absent(),
    this.lastRefreshed = const Value.absent(),
  }) : showTmdbId = Value(showTmdbId),
       season = Value(season),
       episode = Value(episode);
  static Insertable<EpisodeMetadataData> custom({
    Expression<int>? id,
    Expression<int>? showTmdbId,
    Expression<int>? season,
    Expression<int>? episode,
    Expression<String>? name,
    Expression<String>? overview,
    Expression<DateTime>? airDate,
    Expression<String>? stillPath,
    Expression<String>? localStillPath,
    Expression<int>? runtimeMs,
    Expression<DateTime>? lastRefreshed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (showTmdbId != null) 'show_tmdb_id': showTmdbId,
      if (season != null) 'season': season,
      if (episode != null) 'episode': episode,
      if (name != null) 'name': name,
      if (overview != null) 'overview': overview,
      if (airDate != null) 'air_date': airDate,
      if (stillPath != null) 'still_path': stillPath,
      if (localStillPath != null) 'local_still_path': localStillPath,
      if (runtimeMs != null) 'runtime_ms': runtimeMs,
      if (lastRefreshed != null) 'last_refreshed': lastRefreshed,
    });
  }

  EpisodeMetadataCompanion copyWith({
    Value<int>? id,
    Value<int>? showTmdbId,
    Value<int>? season,
    Value<int>? episode,
    Value<String?>? name,
    Value<String?>? overview,
    Value<DateTime?>? airDate,
    Value<String?>? stillPath,
    Value<String?>? localStillPath,
    Value<int?>? runtimeMs,
    Value<DateTime?>? lastRefreshed,
  }) {
    return EpisodeMetadataCompanion(
      id: id ?? this.id,
      showTmdbId: showTmdbId ?? this.showTmdbId,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      name: name ?? this.name,
      overview: overview ?? this.overview,
      airDate: airDate ?? this.airDate,
      stillPath: stillPath ?? this.stillPath,
      localStillPath: localStillPath ?? this.localStillPath,
      runtimeMs: runtimeMs ?? this.runtimeMs,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (showTmdbId.present) {
      map['show_tmdb_id'] = Variable<int>(showTmdbId.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (airDate.present) {
      map['air_date'] = Variable<DateTime>(airDate.value);
    }
    if (stillPath.present) {
      map['still_path'] = Variable<String>(stillPath.value);
    }
    if (localStillPath.present) {
      map['local_still_path'] = Variable<String>(localStillPath.value);
    }
    if (runtimeMs.present) {
      map['runtime_ms'] = Variable<int>(runtimeMs.value);
    }
    if (lastRefreshed.present) {
      map['last_refreshed'] = Variable<DateTime>(lastRefreshed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeMetadataCompanion(')
          ..write('id: $id, ')
          ..write('showTmdbId: $showTmdbId, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('name: $name, ')
          ..write('overview: $overview, ')
          ..write('airDate: $airDate, ')
          ..write('stillPath: $stillPath, ')
          ..write('localStillPath: $localStillPath, ')
          ..write('runtimeMs: $runtimeMs, ')
          ..write('lastRefreshed: $lastRefreshed')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LibraryFoldersTable libraryFolders = $LibraryFoldersTable(this);
  late final $MediaFilesTable mediaFiles = $MediaFilesTable(this);
  late final $WatchProgressTable watchProgress = $WatchProgressTable(this);
  late final $MovieMetadataTable movieMetadata = $MovieMetadataTable(this);
  late final $ShowMetadataTable showMetadata = $ShowMetadataTable(this);
  late final $EpisodeMetadataTable episodeMetadata = $EpisodeMetadataTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryFolders,
    mediaFiles,
    watchProgress,
    movieMetadata,
    showMetadata,
    episodeMetadata,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'library_folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('media_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_files',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('watch_progress', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LibraryFoldersTableCreateCompanionBuilder =
    LibraryFoldersCompanion Function({
      Value<int> id,
      required String path,
      required String displayName,
      required DateTime dateAdded,
    });
typedef $$LibraryFoldersTableUpdateCompanionBuilder =
    LibraryFoldersCompanion Function({
      Value<int> id,
      Value<String> path,
      Value<String> displayName,
      Value<DateTime> dateAdded,
    });

final class $$LibraryFoldersTableReferences
    extends BaseReferences<_$AppDatabase, $LibraryFoldersTable, LibraryFolder> {
  $$LibraryFoldersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MediaFilesTable, List<MediaFile>>
  _mediaFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mediaFiles,
    aliasName: 'library_folders__id__media_files__folder_id',
  );

  $$MediaFilesTableProcessedTableManager get mediaFilesRefs {
    final manager = $$MediaFilesTableTableManager(
      $_db,
      $_db.mediaFiles,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaFilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LibraryFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryFoldersTable> {
  $$LibraryFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> mediaFilesRefs(
    Expression<bool> Function($$MediaFilesTableFilterComposer f) f,
  ) {
    final $$MediaFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaFiles,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaFilesTableFilterComposer(
            $db: $db,
            $table: $db.mediaFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryFoldersTable> {
  $$LibraryFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryFoldersTable> {
  $$LibraryFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  Expression<T> mediaFilesRefs<T extends Object>(
    Expression<T> Function($$MediaFilesTableAnnotationComposer a) f,
  ) {
    final $$MediaFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaFiles,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryFoldersTable,
          LibraryFolder,
          $$LibraryFoldersTableFilterComposer,
          $$LibraryFoldersTableOrderingComposer,
          $$LibraryFoldersTableAnnotationComposer,
          $$LibraryFoldersTableCreateCompanionBuilder,
          $$LibraryFoldersTableUpdateCompanionBuilder,
          (LibraryFolder, $$LibraryFoldersTableReferences),
          LibraryFolder,
          PrefetchHooks Function({bool mediaFilesRefs})
        > {
  $$LibraryFoldersTableTableManager(
    _$AppDatabase db,
    $LibraryFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LibraryFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LibraryFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LibraryFoldersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
              }) => LibraryFoldersCompanion(
                id: id,
                path: path,
                displayName: displayName,
                dateAdded: dateAdded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String path,
                required String displayName,
                required DateTime dateAdded,
              }) => LibraryFoldersCompanion.insert(
                id: id,
                path: path,
                displayName: displayName,
                dateAdded: dateAdded,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LibraryFoldersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({mediaFilesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (mediaFilesRefs) db.mediaFiles],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mediaFilesRefs)
                    await $_getPrefetchedData<
                      LibraryFolder,
                      $LibraryFoldersTable,
                      MediaFile
                    >(
                      currentTable: table,
                      referencedTable: $$LibraryFoldersTableReferences
                          ._mediaFilesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$LibraryFoldersTableReferences(
                                db,
                                table,
                                p0,
                              ).mediaFilesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.folderId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LibraryFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryFoldersTable,
      LibraryFolder,
      $$LibraryFoldersTableFilterComposer,
      $$LibraryFoldersTableOrderingComposer,
      $$LibraryFoldersTableAnnotationComposer,
      $$LibraryFoldersTableCreateCompanionBuilder,
      $$LibraryFoldersTableUpdateCompanionBuilder,
      (LibraryFolder, $$LibraryFoldersTableReferences),
      LibraryFolder,
      PrefetchHooks Function({bool mediaFilesRefs})
    >;
typedef $$MediaFilesTableCreateCompanionBuilder =
    MediaFilesCompanion Function({
      Value<int> id,
      Value<int?> folderId,
      required String filePath,
      required String fileName,
      Value<int> fileSize,
      Value<DateTime?> dateModified,
      required DateTime dateScanned,
      Value<MediaType> mediaType,
      Value<String?> parsedTitle,
      Value<int?> parsedYear,
      Value<int?> parsedSeason,
      Value<int?> parsedEpisode,
      Value<int?> parsedEpisodeEnd,
      Value<int?> durationMs,
      Value<bool> hidden,
    });
typedef $$MediaFilesTableUpdateCompanionBuilder =
    MediaFilesCompanion Function({
      Value<int> id,
      Value<int?> folderId,
      Value<String> filePath,
      Value<String> fileName,
      Value<int> fileSize,
      Value<DateTime?> dateModified,
      Value<DateTime> dateScanned,
      Value<MediaType> mediaType,
      Value<String?> parsedTitle,
      Value<int?> parsedYear,
      Value<int?> parsedSeason,
      Value<int?> parsedEpisode,
      Value<int?> parsedEpisodeEnd,
      Value<int?> durationMs,
      Value<bool> hidden,
    });

final class $$MediaFilesTableReferences
    extends BaseReferences<_$AppDatabase, $MediaFilesTable, MediaFile> {
  $$MediaFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LibraryFoldersTable _folderIdTable(_$AppDatabase db) => db
      .libraryFolders
      .createAlias('media_files__folder_id__library_folders__id');

  $$LibraryFoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<int>('folder_id');
    if ($_column == null) return null;
    final manager = $$LibraryFoldersTableTableManager(
      $_db,
      $_db.libraryFolders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WatchProgressTable, List<WatchProgressData>>
  _watchProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.watchProgress,
    aliasName: 'media_files__id__watch_progress__media_file_id',
  );

  $$WatchProgressTableProcessedTableManager get watchProgressRefs {
    final manager = $$WatchProgressTableTableManager(
      $_db,
      $_db.watchProgress,
    ).filter((f) => f.mediaFileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_watchProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MediaFilesTableFilterComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateScanned => $composableBuilder(
    column: $table.dateScanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MediaType, MediaType, int> get mediaType =>
      $composableBuilder(
        column: $table.mediaType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get parsedTitle => $composableBuilder(
    column: $table.parsedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parsedYear => $composableBuilder(
    column: $table.parsedYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parsedSeason => $composableBuilder(
    column: $table.parsedSeason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parsedEpisode => $composableBuilder(
    column: $table.parsedEpisode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parsedEpisodeEnd => $composableBuilder(
    column: $table.parsedEpisodeEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryFoldersTableFilterComposer get folderId {
    final $$LibraryFoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.libraryFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryFoldersTableFilterComposer(
            $db: $db,
            $table: $db.libraryFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> watchProgressRefs(
    Expression<bool> Function($$WatchProgressTableFilterComposer f) f,
  ) {
    final $$WatchProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchProgress,
      getReferencedColumn: (t) => t.mediaFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchProgressTableFilterComposer(
            $db: $db,
            $table: $db.watchProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateScanned => $composableBuilder(
    column: $table.dateScanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parsedTitle => $composableBuilder(
    column: $table.parsedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parsedYear => $composableBuilder(
    column: $table.parsedYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parsedSeason => $composableBuilder(
    column: $table.parsedSeason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parsedEpisode => $composableBuilder(
    column: $table.parsedEpisode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parsedEpisodeEnd => $composableBuilder(
    column: $table.parsedEpisodeEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryFoldersTableOrderingComposer get folderId {
    final $$LibraryFoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.libraryFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryFoldersTableOrderingComposer(
            $db: $db,
            $table: $db.libraryFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateScanned => $composableBuilder(
    column: $table.dateScanned,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MediaType, int> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get parsedTitle => $composableBuilder(
    column: $table.parsedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parsedYear => $composableBuilder(
    column: $table.parsedYear,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parsedSeason => $composableBuilder(
    column: $table.parsedSeason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parsedEpisode => $composableBuilder(
    column: $table.parsedEpisode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parsedEpisodeEnd => $composableBuilder(
    column: $table.parsedEpisodeEnd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  $$LibraryFoldersTableAnnotationComposer get folderId {
    final $$LibraryFoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.libraryFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryFoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> watchProgressRefs<T extends Object>(
    Expression<T> Function($$WatchProgressTableAnnotationComposer a) f,
  ) {
    final $$WatchProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchProgress,
      getReferencedColumn: (t) => t.mediaFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.watchProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaFilesTable,
          MediaFile,
          $$MediaFilesTableFilterComposer,
          $$MediaFilesTableOrderingComposer,
          $$MediaFilesTableAnnotationComposer,
          $$MediaFilesTableCreateCompanionBuilder,
          $$MediaFilesTableUpdateCompanionBuilder,
          (MediaFile, $$MediaFilesTableReferences),
          MediaFile,
          PrefetchHooks Function({bool folderId, bool watchProgressRefs})
        > {
  $$MediaFilesTableTableManager(_$AppDatabase db, $MediaFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MediaFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MediaFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MediaFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> folderId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<DateTime?> dateModified = const Value.absent(),
                Value<DateTime> dateScanned = const Value.absent(),
                Value<MediaType> mediaType = const Value.absent(),
                Value<String?> parsedTitle = const Value.absent(),
                Value<int?> parsedYear = const Value.absent(),
                Value<int?> parsedSeason = const Value.absent(),
                Value<int?> parsedEpisode = const Value.absent(),
                Value<int?> parsedEpisodeEnd = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
              }) => MediaFilesCompanion(
                id: id,
                folderId: folderId,
                filePath: filePath,
                fileName: fileName,
                fileSize: fileSize,
                dateModified: dateModified,
                dateScanned: dateScanned,
                mediaType: mediaType,
                parsedTitle: parsedTitle,
                parsedYear: parsedYear,
                parsedSeason: parsedSeason,
                parsedEpisode: parsedEpisode,
                parsedEpisodeEnd: parsedEpisodeEnd,
                durationMs: durationMs,
                hidden: hidden,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> folderId = const Value.absent(),
                required String filePath,
                required String fileName,
                Value<int> fileSize = const Value.absent(),
                Value<DateTime?> dateModified = const Value.absent(),
                required DateTime dateScanned,
                Value<MediaType> mediaType = const Value.absent(),
                Value<String?> parsedTitle = const Value.absent(),
                Value<int?> parsedYear = const Value.absent(),
                Value<int?> parsedSeason = const Value.absent(),
                Value<int?> parsedEpisode = const Value.absent(),
                Value<int?> parsedEpisodeEnd = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
              }) => MediaFilesCompanion.insert(
                id: id,
                folderId: folderId,
                filePath: filePath,
                fileName: fileName,
                fileSize: fileSize,
                dateModified: dateModified,
                dateScanned: dateScanned,
                mediaType: mediaType,
                parsedTitle: parsedTitle,
                parsedYear: parsedYear,
                parsedSeason: parsedSeason,
                parsedEpisode: parsedEpisode,
                parsedEpisodeEnd: parsedEpisodeEnd,
                durationMs: durationMs,
                hidden: hidden,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MediaFilesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            folderId = false,
            watchProgressRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (watchProgressRefs) db.watchProgress,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (folderId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.folderId,
                            referencedTable: $$MediaFilesTableReferences
                                ._folderIdTable(db),
                            referencedColumn:
                                $$MediaFilesTableReferences
                                    ._folderIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (watchProgressRefs)
                    await $_getPrefetchedData<
                      MediaFile,
                      $MediaFilesTable,
                      WatchProgressData
                    >(
                      currentTable: table,
                      referencedTable: $$MediaFilesTableReferences
                          ._watchProgressRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MediaFilesTableReferences(
                                db,
                                table,
                                p0,
                              ).watchProgressRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.mediaFileId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MediaFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaFilesTable,
      MediaFile,
      $$MediaFilesTableFilterComposer,
      $$MediaFilesTableOrderingComposer,
      $$MediaFilesTableAnnotationComposer,
      $$MediaFilesTableCreateCompanionBuilder,
      $$MediaFilesTableUpdateCompanionBuilder,
      (MediaFile, $$MediaFilesTableReferences),
      MediaFile,
      PrefetchHooks Function({bool folderId, bool watchProgressRefs})
    >;
typedef $$WatchProgressTableCreateCompanionBuilder =
    WatchProgressCompanion Function({
      Value<int> id,
      required int mediaFileId,
      required int positionMs,
      required int durationMs,
      required DateTime lastWatchedAt,
      Value<bool> isFinished,
    });
typedef $$WatchProgressTableUpdateCompanionBuilder =
    WatchProgressCompanion Function({
      Value<int> id,
      Value<int> mediaFileId,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<DateTime> lastWatchedAt,
      Value<bool> isFinished,
    });

final class $$WatchProgressTableReferences
    extends
        BaseReferences<_$AppDatabase, $WatchProgressTable, WatchProgressData> {
  $$WatchProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MediaFilesTable _mediaFileIdTable(_$AppDatabase db) => db.mediaFiles
      .createAlias('watch_progress__media_file_id__media_files__id');

  $$MediaFilesTableProcessedTableManager get mediaFileId {
    final $_column = $_itemColumn<int>('media_file_id')!;

    final manager = $$MediaFilesTableTableManager(
      $_db,
      $_db.mediaFiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaFileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WatchProgressTableFilterComposer
    extends Composer<_$AppDatabase, $WatchProgressTable> {
  $$WatchProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastWatchedAt => $composableBuilder(
    column: $table.lastWatchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFinished => $composableBuilder(
    column: $table.isFinished,
    builder: (column) => ColumnFilters(column),
  );

  $$MediaFilesTableFilterComposer get mediaFileId {
    final $$MediaFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaFileId,
      referencedTable: $db.mediaFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaFilesTableFilterComposer(
            $db: $db,
            $table: $db.mediaFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchProgressTable> {
  $$WatchProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastWatchedAt => $composableBuilder(
    column: $table.lastWatchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFinished => $composableBuilder(
    column: $table.isFinished,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaFilesTableOrderingComposer get mediaFileId {
    final $$MediaFilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaFileId,
      referencedTable: $db.mediaFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaFilesTableOrderingComposer(
            $db: $db,
            $table: $db.mediaFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchProgressTable> {
  $$WatchProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastWatchedAt => $composableBuilder(
    column: $table.lastWatchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFinished => $composableBuilder(
    column: $table.isFinished,
    builder: (column) => column,
  );

  $$MediaFilesTableAnnotationComposer get mediaFileId {
    final $$MediaFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaFileId,
      referencedTable: $db.mediaFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchProgressTable,
          WatchProgressData,
          $$WatchProgressTableFilterComposer,
          $$WatchProgressTableOrderingComposer,
          $$WatchProgressTableAnnotationComposer,
          $$WatchProgressTableCreateCompanionBuilder,
          $$WatchProgressTableUpdateCompanionBuilder,
          (WatchProgressData, $$WatchProgressTableReferences),
          WatchProgressData,
          PrefetchHooks Function({bool mediaFileId})
        > {
  $$WatchProgressTableTableManager(_$AppDatabase db, $WatchProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$WatchProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$WatchProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$WatchProgressTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mediaFileId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<DateTime> lastWatchedAt = const Value.absent(),
                Value<bool> isFinished = const Value.absent(),
              }) => WatchProgressCompanion(
                id: id,
                mediaFileId: mediaFileId,
                positionMs: positionMs,
                durationMs: durationMs,
                lastWatchedAt: lastWatchedAt,
                isFinished: isFinished,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mediaFileId,
                required int positionMs,
                required int durationMs,
                required DateTime lastWatchedAt,
                Value<bool> isFinished = const Value.absent(),
              }) => WatchProgressCompanion.insert(
                id: id,
                mediaFileId: mediaFileId,
                positionMs: positionMs,
                durationMs: durationMs,
                lastWatchedAt: lastWatchedAt,
                isFinished: isFinished,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$WatchProgressTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({mediaFileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (mediaFileId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.mediaFileId,
                            referencedTable: $$WatchProgressTableReferences
                                ._mediaFileIdTable(db),
                            referencedColumn:
                                $$WatchProgressTableReferences
                                    ._mediaFileIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WatchProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchProgressTable,
      WatchProgressData,
      $$WatchProgressTableFilterComposer,
      $$WatchProgressTableOrderingComposer,
      $$WatchProgressTableAnnotationComposer,
      $$WatchProgressTableCreateCompanionBuilder,
      $$WatchProgressTableUpdateCompanionBuilder,
      (WatchProgressData, $$WatchProgressTableReferences),
      WatchProgressData,
      PrefetchHooks Function({bool mediaFileId})
    >;
typedef $$MovieMetadataTableCreateCompanionBuilder =
    MovieMetadataCompanion Function({
      Value<int> id,
      required String movieKey,
      Value<int?> tmdbId,
      Value<String?> title,
      Value<int?> year,
      Value<String?> overview,
      Value<int?> runtimeMs,
      Value<double> voteAverage,
      Value<String?> genres,
      Value<String?> posterPath,
      Value<String?> backdropPath,
      Value<String?> localPosterPath,
      Value<String?> localBackdropPath,
      Value<double> matchConfidence,
      Value<MatchStatus> matchStatus,
      Value<DateTime?> lastRefreshed,
    });
typedef $$MovieMetadataTableUpdateCompanionBuilder =
    MovieMetadataCompanion Function({
      Value<int> id,
      Value<String> movieKey,
      Value<int?> tmdbId,
      Value<String?> title,
      Value<int?> year,
      Value<String?> overview,
      Value<int?> runtimeMs,
      Value<double> voteAverage,
      Value<String?> genres,
      Value<String?> posterPath,
      Value<String?> backdropPath,
      Value<String?> localPosterPath,
      Value<String?> localBackdropPath,
      Value<double> matchConfidence,
      Value<MatchStatus> matchStatus,
      Value<DateTime?> lastRefreshed,
    });

class $$MovieMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $MovieMetadataTable> {
  $$MovieMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movieKey => $composableBuilder(
    column: $table.movieKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runtimeMs => $composableBuilder(
    column: $table.runtimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPosterPath => $composableBuilder(
    column: $table.localPosterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localBackdropPath => $composableBuilder(
    column: $table.localBackdropPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MatchStatus, MatchStatus, int>
  get matchStatus => $composableBuilder(
    column: $table.matchStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastRefreshed => $composableBuilder(
    column: $table.lastRefreshed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovieMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $MovieMetadataTable> {
  $$MovieMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movieKey => $composableBuilder(
    column: $table.movieKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runtimeMs => $composableBuilder(
    column: $table.runtimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPosterPath => $composableBuilder(
    column: $table.localPosterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localBackdropPath => $composableBuilder(
    column: $table.localBackdropPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matchStatus => $composableBuilder(
    column: $table.matchStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRefreshed => $composableBuilder(
    column: $table.lastRefreshed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovieMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovieMetadataTable> {
  $$MovieMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get movieKey =>
      $composableBuilder(column: $table.movieKey, builder: (column) => column);

  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<int> get runtimeMs =>
      $composableBuilder(column: $table.runtimeMs, builder: (column) => column);

  GeneratedColumn<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPosterPath => $composableBuilder(
    column: $table.localPosterPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localBackdropPath => $composableBuilder(
    column: $table.localBackdropPath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MatchStatus, int> get matchStatus =>
      $composableBuilder(
        column: $table.matchStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastRefreshed => $composableBuilder(
    column: $table.lastRefreshed,
    builder: (column) => column,
  );
}

class $$MovieMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovieMetadataTable,
          MovieMetadataData,
          $$MovieMetadataTableFilterComposer,
          $$MovieMetadataTableOrderingComposer,
          $$MovieMetadataTableAnnotationComposer,
          $$MovieMetadataTableCreateCompanionBuilder,
          $$MovieMetadataTableUpdateCompanionBuilder,
          (
            MovieMetadataData,
            BaseReferences<
              _$AppDatabase,
              $MovieMetadataTable,
              MovieMetadataData
            >,
          ),
          MovieMetadataData,
          PrefetchHooks Function()
        > {
  $$MovieMetadataTableTableManager(_$AppDatabase db, $MovieMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MovieMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$MovieMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MovieMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> movieKey = const Value.absent(),
                Value<int?> tmdbId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<int?> runtimeMs = const Value.absent(),
                Value<double> voteAverage = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<String?> localPosterPath = const Value.absent(),
                Value<String?> localBackdropPath = const Value.absent(),
                Value<double> matchConfidence = const Value.absent(),
                Value<MatchStatus> matchStatus = const Value.absent(),
                Value<DateTime?> lastRefreshed = const Value.absent(),
              }) => MovieMetadataCompanion(
                id: id,
                movieKey: movieKey,
                tmdbId: tmdbId,
                title: title,
                year: year,
                overview: overview,
                runtimeMs: runtimeMs,
                voteAverage: voteAverage,
                genres: genres,
                posterPath: posterPath,
                backdropPath: backdropPath,
                localPosterPath: localPosterPath,
                localBackdropPath: localBackdropPath,
                matchConfidence: matchConfidence,
                matchStatus: matchStatus,
                lastRefreshed: lastRefreshed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String movieKey,
                Value<int?> tmdbId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<int?> runtimeMs = const Value.absent(),
                Value<double> voteAverage = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<String?> localPosterPath = const Value.absent(),
                Value<String?> localBackdropPath = const Value.absent(),
                Value<double> matchConfidence = const Value.absent(),
                Value<MatchStatus> matchStatus = const Value.absent(),
                Value<DateTime?> lastRefreshed = const Value.absent(),
              }) => MovieMetadataCompanion.insert(
                id: id,
                movieKey: movieKey,
                tmdbId: tmdbId,
                title: title,
                year: year,
                overview: overview,
                runtimeMs: runtimeMs,
                voteAverage: voteAverage,
                genres: genres,
                posterPath: posterPath,
                backdropPath: backdropPath,
                localPosterPath: localPosterPath,
                localBackdropPath: localBackdropPath,
                matchConfidence: matchConfidence,
                matchStatus: matchStatus,
                lastRefreshed: lastRefreshed,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovieMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovieMetadataTable,
      MovieMetadataData,
      $$MovieMetadataTableFilterComposer,
      $$MovieMetadataTableOrderingComposer,
      $$MovieMetadataTableAnnotationComposer,
      $$MovieMetadataTableCreateCompanionBuilder,
      $$MovieMetadataTableUpdateCompanionBuilder,
      (
        MovieMetadataData,
        BaseReferences<_$AppDatabase, $MovieMetadataTable, MovieMetadataData>,
      ),
      MovieMetadataData,
      PrefetchHooks Function()
    >;
typedef $$ShowMetadataTableCreateCompanionBuilder =
    ShowMetadataCompanion Function({
      Value<int> id,
      required String showKey,
      Value<int?> tmdbId,
      Value<String?> name,
      Value<int?> firstAirYear,
      Value<String?> overview,
      Value<String?> genres,
      Value<String?> posterPath,
      Value<String?> backdropPath,
      Value<String?> localPosterPath,
      Value<String?> localBackdropPath,
      Value<double> matchConfidence,
      Value<MatchStatus> matchStatus,
      Value<DateTime?> lastRefreshed,
    });
typedef $$ShowMetadataTableUpdateCompanionBuilder =
    ShowMetadataCompanion Function({
      Value<int> id,
      Value<String> showKey,
      Value<int?> tmdbId,
      Value<String?> name,
      Value<int?> firstAirYear,
      Value<String?> overview,
      Value<String?> genres,
      Value<String?> posterPath,
      Value<String?> backdropPath,
      Value<String?> localPosterPath,
      Value<String?> localBackdropPath,
      Value<double> matchConfidence,
      Value<MatchStatus> matchStatus,
      Value<DateTime?> lastRefreshed,
    });

class $$ShowMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $ShowMetadataTable> {
  $$ShowMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get showKey => $composableBuilder(
    column: $table.showKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstAirYear => $composableBuilder(
    column: $table.firstAirYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPosterPath => $composableBuilder(
    column: $table.localPosterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localBackdropPath => $composableBuilder(
    column: $table.localBackdropPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MatchStatus, MatchStatus, int>
  get matchStatus => $composableBuilder(
    column: $table.matchStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastRefreshed => $composableBuilder(
    column: $table.lastRefreshed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShowMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $ShowMetadataTable> {
  $$ShowMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get showKey => $composableBuilder(
    column: $table.showKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstAirYear => $composableBuilder(
    column: $table.firstAirYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPosterPath => $composableBuilder(
    column: $table.localPosterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localBackdropPath => $composableBuilder(
    column: $table.localBackdropPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matchStatus => $composableBuilder(
    column: $table.matchStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRefreshed => $composableBuilder(
    column: $table.lastRefreshed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShowMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShowMetadataTable> {
  $$ShowMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get showKey =>
      $composableBuilder(column: $table.showKey, builder: (column) => column);

  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get firstAirYear => $composableBuilder(
    column: $table.firstAirYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPosterPath => $composableBuilder(
    column: $table.localPosterPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localBackdropPath => $composableBuilder(
    column: $table.localBackdropPath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MatchStatus, int> get matchStatus =>
      $composableBuilder(
        column: $table.matchStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastRefreshed => $composableBuilder(
    column: $table.lastRefreshed,
    builder: (column) => column,
  );
}

class $$ShowMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShowMetadataTable,
          ShowMetadataData,
          $$ShowMetadataTableFilterComposer,
          $$ShowMetadataTableOrderingComposer,
          $$ShowMetadataTableAnnotationComposer,
          $$ShowMetadataTableCreateCompanionBuilder,
          $$ShowMetadataTableUpdateCompanionBuilder,
          (
            ShowMetadataData,
            BaseReferences<_$AppDatabase, $ShowMetadataTable, ShowMetadataData>,
          ),
          ShowMetadataData,
          PrefetchHooks Function()
        > {
  $$ShowMetadataTableTableManager(_$AppDatabase db, $ShowMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ShowMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ShowMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$ShowMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> showKey = const Value.absent(),
                Value<int?> tmdbId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> firstAirYear = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<String?> localPosterPath = const Value.absent(),
                Value<String?> localBackdropPath = const Value.absent(),
                Value<double> matchConfidence = const Value.absent(),
                Value<MatchStatus> matchStatus = const Value.absent(),
                Value<DateTime?> lastRefreshed = const Value.absent(),
              }) => ShowMetadataCompanion(
                id: id,
                showKey: showKey,
                tmdbId: tmdbId,
                name: name,
                firstAirYear: firstAirYear,
                overview: overview,
                genres: genres,
                posterPath: posterPath,
                backdropPath: backdropPath,
                localPosterPath: localPosterPath,
                localBackdropPath: localBackdropPath,
                matchConfidence: matchConfidence,
                matchStatus: matchStatus,
                lastRefreshed: lastRefreshed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String showKey,
                Value<int?> tmdbId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> firstAirYear = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<String?> localPosterPath = const Value.absent(),
                Value<String?> localBackdropPath = const Value.absent(),
                Value<double> matchConfidence = const Value.absent(),
                Value<MatchStatus> matchStatus = const Value.absent(),
                Value<DateTime?> lastRefreshed = const Value.absent(),
              }) => ShowMetadataCompanion.insert(
                id: id,
                showKey: showKey,
                tmdbId: tmdbId,
                name: name,
                firstAirYear: firstAirYear,
                overview: overview,
                genres: genres,
                posterPath: posterPath,
                backdropPath: backdropPath,
                localPosterPath: localPosterPath,
                localBackdropPath: localBackdropPath,
                matchConfidence: matchConfidence,
                matchStatus: matchStatus,
                lastRefreshed: lastRefreshed,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShowMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShowMetadataTable,
      ShowMetadataData,
      $$ShowMetadataTableFilterComposer,
      $$ShowMetadataTableOrderingComposer,
      $$ShowMetadataTableAnnotationComposer,
      $$ShowMetadataTableCreateCompanionBuilder,
      $$ShowMetadataTableUpdateCompanionBuilder,
      (
        ShowMetadataData,
        BaseReferences<_$AppDatabase, $ShowMetadataTable, ShowMetadataData>,
      ),
      ShowMetadataData,
      PrefetchHooks Function()
    >;
typedef $$EpisodeMetadataTableCreateCompanionBuilder =
    EpisodeMetadataCompanion Function({
      Value<int> id,
      required int showTmdbId,
      required int season,
      required int episode,
      Value<String?> name,
      Value<String?> overview,
      Value<DateTime?> airDate,
      Value<String?> stillPath,
      Value<String?> localStillPath,
      Value<int?> runtimeMs,
      Value<DateTime?> lastRefreshed,
    });
typedef $$EpisodeMetadataTableUpdateCompanionBuilder =
    EpisodeMetadataCompanion Function({
      Value<int> id,
      Value<int> showTmdbId,
      Value<int> season,
      Value<int> episode,
      Value<String?> name,
      Value<String?> overview,
      Value<DateTime?> airDate,
      Value<String?> stillPath,
      Value<String?> localStillPath,
      Value<int?> runtimeMs,
      Value<DateTime?> lastRefreshed,
    });

class $$EpisodeMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $EpisodeMetadataTable> {
  $$EpisodeMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get showTmdbId => $composableBuilder(
    column: $table.showTmdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get airDate => $composableBuilder(
    column: $table.airDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stillPath => $composableBuilder(
    column: $table.stillPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localStillPath => $composableBuilder(
    column: $table.localStillPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runtimeMs => $composableBuilder(
    column: $table.runtimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRefreshed => $composableBuilder(
    column: $table.lastRefreshed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EpisodeMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $EpisodeMetadataTable> {
  $$EpisodeMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get showTmdbId => $composableBuilder(
    column: $table.showTmdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get airDate => $composableBuilder(
    column: $table.airDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stillPath => $composableBuilder(
    column: $table.stillPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localStillPath => $composableBuilder(
    column: $table.localStillPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runtimeMs => $composableBuilder(
    column: $table.runtimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRefreshed => $composableBuilder(
    column: $table.lastRefreshed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EpisodeMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpisodeMetadataTable> {
  $$EpisodeMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get showTmdbId => $composableBuilder(
    column: $table.showTmdbId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<DateTime> get airDate =>
      $composableBuilder(column: $table.airDate, builder: (column) => column);

  GeneratedColumn<String> get stillPath =>
      $composableBuilder(column: $table.stillPath, builder: (column) => column);

  GeneratedColumn<String> get localStillPath => $composableBuilder(
    column: $table.localStillPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get runtimeMs =>
      $composableBuilder(column: $table.runtimeMs, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRefreshed => $composableBuilder(
    column: $table.lastRefreshed,
    builder: (column) => column,
  );
}

class $$EpisodeMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpisodeMetadataTable,
          EpisodeMetadataData,
          $$EpisodeMetadataTableFilterComposer,
          $$EpisodeMetadataTableOrderingComposer,
          $$EpisodeMetadataTableAnnotationComposer,
          $$EpisodeMetadataTableCreateCompanionBuilder,
          $$EpisodeMetadataTableUpdateCompanionBuilder,
          (
            EpisodeMetadataData,
            BaseReferences<
              _$AppDatabase,
              $EpisodeMetadataTable,
              EpisodeMetadataData
            >,
          ),
          EpisodeMetadataData,
          PrefetchHooks Function()
        > {
  $$EpisodeMetadataTableTableManager(
    _$AppDatabase db,
    $EpisodeMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$EpisodeMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$EpisodeMetadataTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$EpisodeMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> showTmdbId = const Value.absent(),
                Value<int> season = const Value.absent(),
                Value<int> episode = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<DateTime?> airDate = const Value.absent(),
                Value<String?> stillPath = const Value.absent(),
                Value<String?> localStillPath = const Value.absent(),
                Value<int?> runtimeMs = const Value.absent(),
                Value<DateTime?> lastRefreshed = const Value.absent(),
              }) => EpisodeMetadataCompanion(
                id: id,
                showTmdbId: showTmdbId,
                season: season,
                episode: episode,
                name: name,
                overview: overview,
                airDate: airDate,
                stillPath: stillPath,
                localStillPath: localStillPath,
                runtimeMs: runtimeMs,
                lastRefreshed: lastRefreshed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int showTmdbId,
                required int season,
                required int episode,
                Value<String?> name = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<DateTime?> airDate = const Value.absent(),
                Value<String?> stillPath = const Value.absent(),
                Value<String?> localStillPath = const Value.absent(),
                Value<int?> runtimeMs = const Value.absent(),
                Value<DateTime?> lastRefreshed = const Value.absent(),
              }) => EpisodeMetadataCompanion.insert(
                id: id,
                showTmdbId: showTmdbId,
                season: season,
                episode: episode,
                name: name,
                overview: overview,
                airDate: airDate,
                stillPath: stillPath,
                localStillPath: localStillPath,
                runtimeMs: runtimeMs,
                lastRefreshed: lastRefreshed,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EpisodeMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpisodeMetadataTable,
      EpisodeMetadataData,
      $$EpisodeMetadataTableFilterComposer,
      $$EpisodeMetadataTableOrderingComposer,
      $$EpisodeMetadataTableAnnotationComposer,
      $$EpisodeMetadataTableCreateCompanionBuilder,
      $$EpisodeMetadataTableUpdateCompanionBuilder,
      (
        EpisodeMetadataData,
        BaseReferences<
          _$AppDatabase,
          $EpisodeMetadataTable,
          EpisodeMetadataData
        >,
      ),
      EpisodeMetadataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LibraryFoldersTableTableManager get libraryFolders =>
      $$LibraryFoldersTableTableManager(_db, _db.libraryFolders);
  $$MediaFilesTableTableManager get mediaFiles =>
      $$MediaFilesTableTableManager(_db, _db.mediaFiles);
  $$WatchProgressTableTableManager get watchProgress =>
      $$WatchProgressTableTableManager(_db, _db.watchProgress);
  $$MovieMetadataTableTableManager get movieMetadata =>
      $$MovieMetadataTableTableManager(_db, _db.movieMetadata);
  $$ShowMetadataTableTableManager get showMetadata =>
      $$ShowMetadataTableTableManager(_db, _db.showMetadata);
  $$EpisodeMetadataTableTableManager get episodeMetadata =>
      $$EpisodeMetadataTableTableManager(_db, _db.episodeMetadata);
}
