/// How a media file was classified by the filename parser. Kept in its own
/// dependency-free file so the pure-Dart parser can use it without importing
/// the drift database (which pulls in Flutter).
enum MediaType { movie, episode, unknown }
