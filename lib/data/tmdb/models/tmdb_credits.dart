import 'tmdb_json.dart';

/// A billed cast member.
class TmdbCastMember {
  const TmdbCastMember({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    this.order = 0,
  });

  final int id;
  final String name;
  final String? character;
  final String? profilePath;

  /// Billing order; lower is more prominent.
  final int order;

  factory TmdbCastMember.fromJson(Map<String, dynamic> json) {
    return TmdbCastMember(
      id: asInt(json['id']) ?? 0,
      name: asString(json['name']) ?? '',
      character: asString(json['character']),
      profilePath: asString(json['profile_path']),
      order: asInt(json['order']) ?? 0,
    );
  }
}

/// A crew member Halo cares about — directors and writers, not the full unit.
class TmdbCrewMember {
  const TmdbCrewMember({
    required this.id,
    required this.name,
    required this.job,
    this.department,
    this.profilePath,
  });

  final int id;
  final String name;
  final String job;
  final String? department;
  final String? profilePath;

  factory TmdbCrewMember.fromJson(Map<String, dynamic> json) {
    return TmdbCrewMember(
      id: asInt(json['id']) ?? 0,
      name: asString(json['name']) ?? '',
      job: asString(json['job']) ?? '',
      department: asString(json['department']),
      profilePath: asString(json['profile_path']),
    );
  }
}

/// Cast and crew, as returned by the `credits` append-to-response.
class TmdbCredits {
  const TmdbCredits({this.cast = const [], this.crew = const []});

  static const empty = TmdbCredits();

  /// In billing order.
  final List<TmdbCastMember> cast;
  final List<TmdbCrewMember> crew;

  List<TmdbCrewMember> get directors =>
      crew.where((member) => member.job == 'Director').toList();

  List<TmdbCrewMember> get writers => crew
      .where((member) => member.job == 'Writer' || member.job == 'Screenplay')
      .toList();

  factory TmdbCredits.fromJson(Map<String, dynamic> json) {
    return TmdbCredits(
      cast: asObjectList(json['cast'])
          .map(TmdbCastMember.fromJson)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
      crew: asObjectList(json['crew']).map(TmdbCrewMember.fromJson).toList(),
    );
  }
}

/// One artwork entry from the `images` append-to-response.
class TmdbImageRef {
  const TmdbImageRef({
    required this.filePath,
    this.width = 0,
    this.height = 0,
    this.voteAverage = 0,
    this.languageCode,
  });

  final String filePath;
  final int width;
  final int height;
  final double voteAverage;

  /// `iso_639_1`; null for language-neutral artwork, which is usually what a
  /// poster wall wants.
  final String? languageCode;

  factory TmdbImageRef.fromJson(Map<String, dynamic> json) {
    return TmdbImageRef(
      filePath: asString(json['file_path']) ?? '',
      width: asInt(json['width']) ?? 0,
      height: asInt(json['height']) ?? 0,
      voteAverage: asDouble(json['vote_average']) ?? 0,
      languageCode: asString(json['iso_639_1']),
    );
  }
}

/// Alternative artwork, best-rated first.
class TmdbImageSet {
  const TmdbImageSet({this.posters = const [], this.backdrops = const []});

  static const empty = TmdbImageSet();

  final List<TmdbImageRef> posters;
  final List<TmdbImageRef> backdrops;

  factory TmdbImageSet.fromJson(Map<String, dynamic> json) {
    List<TmdbImageRef> read(String key) =>
        asObjectList(json[key])
            .map(TmdbImageRef.fromJson)
            .where((image) => image.filePath.isNotEmpty)
            .toList()
          ..sort((a, b) => b.voteAverage.compareTo(a.voteAverage));

    return TmdbImageSet(
      posters: read('posters'),
      backdrops: read('backdrops'),
    );
  }
}
