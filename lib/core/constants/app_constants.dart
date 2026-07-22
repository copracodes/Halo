/// App-wide constant values.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Halo';

  /// Video file extensions the library scanner will recognise (lowercase, no
  /// leading dot). Phase 2.
  static const Set<String> supportedVideoExtensions = {
    'mp4',
    'mkv',
    'avi',
    'mov',
    'webm',
    'm4v',
    'ts',
    'flv',
    'wmv',
    '3gp',
  };
}
