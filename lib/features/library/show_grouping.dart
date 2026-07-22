import '../../data/database/app_database.dart';
import 'media_display.dart';

/// One season of a [Show], with its episodes in broadcast order.
class SeasonGroup {
  const SeasonGroup({required this.season, required this.episodes});

  /// The season number, or null for episodes with no detectable season —
  /// absolute-numbered anime, specials, or a flat folder of episodes.
  final int? season;

  final List<MediaFile> episodes;

  String get label => season == null ? 'Episodes' : 'Season $season';
}

/// A TV show assembled from the episode files that share a title. This is what
/// the TV tab renders — the grid shows *shows*, not files.
class Show {
  const Show({required this.title, required this.seasons});

  /// Display spelling of the show name (the first one seen among its files).
  final String title;

  /// Seasons in ascending order; the unnumbered group, if any, comes last.
  final List<SeasonGroup> seasons;

  /// Stable identity across rebuilds — the normalised title, which is exactly
  /// what the files were grouped by.
  String get id => normalizeShowTitle(title);

  int get episodeCount =>
      seasons.fold(0, (total, season) => total + season.episodes.length);

  /// Number of *numbered* seasons; the unnumbered bucket isn't a season.
  int get seasonCount => seasons.where((s) => s.season != null).length;
}

/// Collapses whitespace and case so "The Office" and "the  office" land in the
/// same show.
String normalizeShowTitle(String title) =>
    title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

/// Groups episode files into shows and seasons.
///
/// Files are keyed by their normalised [MediaFileDisplay.displayTitle]; within a
/// show they are bucketed by `parsedSeason` (null forming its own trailing
/// group) and ordered by episode number.
///
/// When the same show is spelled inconsistently across files, the spelling used
/// by the most files wins — one oddly-cased download shouldn't rename the card.
/// Every step falls back to file-name order, so the result is identical for a
/// given set of files no matter what order they arrive in and the grid doesn't
/// reshuffle when the stream re-emits.
List<Show> groupIntoShows(List<MediaFile> episodes) {
  // Sort the input first so ties — in show spelling and in files with no
  // episode number — resolve the same way every time.
  final files = [...episodes]
    ..sort((a, b) => a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));

  final spellings = <String, Map<String, int>>{};
  final bySeason = <String, Map<int?, List<MediaFile>>>{};

  for (final file in files) {
    final title = _collapseWhitespace(file.displayTitle);
    final key = normalizeShowTitle(title);
    if (key.isEmpty) continue;
    final counts = spellings.putIfAbsent(key, () => <String, int>{});
    counts[title] = (counts[title] ?? 0) + 1;
    bySeason
        .putIfAbsent(key, () => <int?, List<MediaFile>>{})
        .putIfAbsent(file.parsedSeason, () => <MediaFile>[])
        .add(file);
  }

  final shows = <Show>[];
  for (final entry in bySeason.entries) {
    final seasonNumbers = entry.value.keys.toList()..sort(_bySeasonNumber);
    shows.add(
      Show(
        title: _mostCommon(spellings[entry.key]!),
        seasons: [
          for (final season in seasonNumbers)
            SeasonGroup(
              season: season,
              episodes: [...entry.value[season]!]..sort(_byEpisodeNumber),
            ),
        ],
      ),
    );
  }

  shows.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  return shows;
}

String _collapseWhitespace(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ');

/// The key with the highest count. [counts] is built in file-name order and
/// iterated in insertion order, so an all-square tie goes to the first file.
String _mostCommon(Map<String, int> counts) {
  var best = counts.keys.first;
  for (final entry in counts.entries) {
    if (entry.value > counts[best]!) best = entry.key;
  }
  return best;
}

/// Ascending season number, with the unnumbered group last.
int _bySeasonNumber(int? a, int? b) {
  if (a == null) return b == null ? 0 : 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Ascending episode number, with unnumbered files last and filename as the
/// tie-breaker so the order is total.
int _byEpisodeNumber(MediaFile a, MediaFile b) {
  final ae = a.parsedEpisode;
  final be = b.parsedEpisode;
  if (ae != null && be != null && ae != be) return ae.compareTo(be);
  if (ae == null && be != null) return 1;
  if (ae != null && be == null) return -1;
  return a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase());
}
