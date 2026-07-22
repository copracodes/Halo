import '../../data/database/app_database.dart';
import 'media_display.dart';

/// How a library grid is ordered. Toggled from the Movies tab header.
enum LibrarySort {
  alphabetical,
  recentlyAdded;

  String get label => switch (this) {
        LibrarySort.alphabetical => 'A–Z',
        LibrarySort.recentlyAdded => 'Recent',
      };
}

/// Returns [files] ordered by [sort], leaving the input untouched.
///
/// A–Z sorts on the displayed title (not the raw filename) so the grid reads in
/// the order the user actually sees, and falls back to the filename for ties.
/// Recently added is newest first by the date the file entered the library.
List<MediaFile> sortMedia(List<MediaFile> files, LibrarySort sort) {
  final sorted = [...files];
  switch (sort) {
    case LibrarySort.alphabetical:
      sorted.sort((a, b) {
        final byTitle = a.displayTitle.toLowerCase().compareTo(
              b.displayTitle.toLowerCase(),
            );
        if (byTitle != 0) return byTitle;
        return a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase());
      });
    case LibrarySort.recentlyAdded:
      sorted.sort((a, b) {
        final byDate = b.dateScanned.compareTo(a.dateScanned);
        if (byDate != 0) return byDate;
        return a.displayTitle.toLowerCase().compareTo(
              b.displayTitle.toLowerCase(),
            );
      });
  }
  return sorted;
}
