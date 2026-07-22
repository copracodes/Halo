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
          ..write('durationMs: $durationMs')
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
          other.durationMs == this.durationMs);
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
          ..write('durationMs: $durationMs')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LibraryFoldersTable libraryFolders = $LibraryFoldersTable(this);
  late final $MediaFilesTable mediaFiles = $MediaFilesTable(this);
  late final $WatchProgressTable watchProgress = $WatchProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryFolders,
    mediaFiles,
    watchProgress,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LibraryFoldersTableTableManager get libraryFolders =>
      $$LibraryFoldersTableTableManager(_db, _db.libraryFolders);
  $$MediaFilesTableTableManager get mediaFiles =>
      $$MediaFilesTableTableManager(_db, _db.mediaFiles);
  $$WatchProgressTableTableManager get watchProgress =>
      $$WatchProgressTableTableManager(_db, _db.watchProgress);
}
