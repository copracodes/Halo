/// A library folder the user granted access to, identified by an opaque,
/// persistable [uri] (an Android SAF tree URI today). [displayName] is a
/// human-friendly label for the folder.
class PickedFolder {
  const PickedFolder({required this.uri, required this.displayName});

  final String uri;
  final String displayName;
}

/// A file discovered while enumerating a folder. [uri] is the stable, opaque
/// handle used to identify and (later) open the file.
class ScannedFile {
  const ScannedFile({
    required this.uri,
    required this.name,
    required this.size,
    required this.lastModified,
    this.parentPath = const [],
  });

  final String uri;
  final String name;
  final int size;

  /// Milliseconds since epoch, or 0 if the source doesn't report it.
  final int lastModified;

  /// Names of the folders between the file and the library root, nearest-first
  /// and excluding the root itself (e.g. `['Season 2', 'Breaking Bad']`). Used
  /// by the parser for folder-based season detection.
  final List<String> parentPath;
}

/// Platform-agnostic access to user-granted library folders.
///
/// This is the seam that keeps the Storage Access Framework (Android-only) out
/// of the rest of the app: the scanner and UI depend on this interface, and an
/// iOS implementation can be added later without touching them (see CLAUDE.md
/// Platform Policy). The only implementation today is Android's
/// `SafFolderAccess`.
abstract interface class FolderAccess {
  /// Opens the system folder picker and returns the chosen folder with a
  /// persisted, restart-surviving grant, or null if the user cancelled.
  Future<PickedFolder?> pickFolder();

  /// Emits every file (not directory) found by walking [folderUri] recursively.
  /// Directories are traversed but not emitted. Extension filtering is the
  /// caller's job.
  Stream<ScannedFile> listFiles(String folderUri);

  /// Opens [fileUri] and returns a native file descriptor for it. Used to hand
  /// a `content://` sidecar subtitle to the player as `fd://<n>`, which is how
  /// content URIs are opened on Android (a platform where they aren't real
  /// paths). The caller must [closeFileDescriptor] it when done.
  Future<int> openFileDescriptor(String fileUri);

  /// Closes a descriptor from [openFileDescriptor].
  Future<void> closeFileDescriptor(int fd);

  /// Whether the persisted grant for [folderUri] is still valid (survives app
  /// restarts until the user revokes it).
  Future<bool> hasAccess(String folderUri);

  /// Releases the persisted grant for [folderUri].
  Future<void> releaseFolder(String folderUri);
}
