# Halo

## Project Vision

Halo is a beautiful, offline-first **local video player** with a Netflix-style
experience for movies and TV shows the user has already downloaded.

- **Index in place, never move.** The user's existing downloads are scanned and
  catalogued where they live on disk. Halo never moves, copies, or renames the
  original media files.
- **Enriched later.** Discovered titles are enriched with TMDB metadata
  (posters, backdrops, overviews, episode data) after indexing. Metadata is an
  enhancement — its absence never blocks browsing or playback.
- **Polished playback.** A cinematic, Netflix-like UI for browsing and a clean,
  full-screen player for watching.
- **No user profiles.** Single-user by design. No accounts, no login.
- **Offline-first.** The app is fully usable with no network. Only TMDB
  enrichment needs connectivity, and it degrades gracefully.

## Platform Policy

Halo is a **mobile app**. Two target platforms, treated differently:

- **Desktop (Windows / macOS / Linux) — permanently out of scope.** Never build
  for it, never `flutter run -d windows/macos/linux`, and never write
  desktop-specific code. Removing the `windows/`, `macos/`, and `linux/`
  platform folders is fine.
- **Android — the only build & test target for now.** All builds and device
  passes are Android-only (see Testing & verification workflow).
- **iOS — an in-scope future target.** It can't be built or tested yet (no
  iPhone/Mac available), so it stays out of the verification loop for now. But
  **write iOS-compatible code by default:**
  - Keep the `ios/` platform folder.
  - Prefer plugins that support **both Android and iOS**.
  - Guard any Android-only API behind a small abstraction/interface, so an iOS
    implementation can be added later **without refactoring**.
  - Whenever a task forces an Android-only choice, **mention it briefly** so the
    iOS gap is visible.
- **Library work specifically:** folder picking/scanning uses Android's Storage
  Access Framework. Put it behind a **`FolderAccess`-style interface** and ship
  the Android implementation now, so an iOS implementation can slot in later.

## Tech Stack

- **Flutter + Dart** — mobile UI. Android is the only build/test target; iOS is
  an in-scope future target (see Platform Policy). Desktop is out of scope.
- **media_kit** (mpv-based) — video playback on Android and iOS
  (`media_kit`, `media_kit_video`, `media_kit_libs_video`).
- **drift** (SQLite) — **the single source of truth for all persistent state**:
  the media index (`LibraryFolders`, `MediaFiles`) and playback progress
  (`WatchProgress`), with TMDB metadata to follow. Wired up in Phase 2.1.
  Schema lives in `data/database/app_database.dart`; run
  `dart run build_runner build` after changing tables to regenerate
  `app_database.g.dart`.
- **shared_preferences** — **only** for trivial app settings/flags (e.g. the
  one-time resume-migration flag). Never the store of record for library or
  playback data; that all lives in drift.
- **http** — TMDB REST calls (`data/tmdb/`). Always behind `TmdbClient`, which
  returns a `TmdbResult` instead of throwing, so metadata failures can never
  reach the UI as exceptions.
- **Riverpod** (`flutter_riverpod`) — state management.
- **saf_util** — Android Storage Access Framework: persistable folder grants +
  recursive listing. Always used behind the `FolderAccess` interface
  (`features/library/folder_access/`) so an iOS implementation can slot in later
  (see Platform Policy). Never call `saf_util` directly outside that folder.
- **file_picker** — ad-hoc single-file playback from the home screen (the
  library itself is scanned via `FolderAccess`, not file_picker).

## Architecture

Feature-first structure under `lib/`. Each feature owns its screens, widgets,
and state; shared concerns live in `core/`; persistence lives in `data/`.

```
lib/
├── main.dart                 # Entry point: MediaKit init, ProviderScope, theme
├── core/
│   ├── theme/                # app_theme.dart, app_colors.dart (dark-first)
│   ├── utils/                # small pure helpers (format_utils.dart)
│   └── constants/            # app_constants.dart
├── features/
│   ├── home/                 # empty state, tabbed shell, Home tab (rows)
│   ├── player/               # media_kit playback surface + controller
│   ├── library/              # scanner, folder_access/ (SAF), parser/ (pure Dart),
│   │                         # Movies/TV tabs, show detail, widgets/ (cards, grids)
│   └── metadata/             # TMDB attribution + (temporary) debug probe
├── config/                   # app_secrets.dart, secrets.example.dart
│                             # secrets.dart is git-ignored — see Secrets below
└── data/
    ├── database/             # drift db (app_database.dart + .g.dart, schema v2)
    ├── tmdb/                 # TmdbClient (transport), TmdbApi (endpoints),
    │                         # models/, image URL building, TmdbResult
    └── repositories/         # LibraryRepository, ProgressRepository (features <-> db)
```

Placeholder files exist in each folder to establish the structure; most contain
`UnimplementedError` stubs or minimal widgets to be filled in per phase.

## Conventions

- **Null-safety** throughout. No `!` bang operators without a clear invariant.
- **Small widgets, split into files.** Prefer many focused widget files over
  large build methods.
- **No business logic inside widgets.** Widgets observe Riverpod
  providers/notifiers and render; logic lives in notifiers, services, and
  repositories.
- **Dark theme is the default and primary theme.** It is what ships; a light
  theme, if ever added, is a later polish concern. See `core/theme/`.
- Depend inward: features → repositories → database. Widgets never touch the
  database directly.

## Secrets / TMDB token

The TMDB **v4 Read Access Token** lives in `lib/config/secrets.dart`, which is
**git-ignored**. A fresh clone will not compile until it exists:

```bash
cp lib/config/secrets.example.dart lib/config/secrets.dart
# then paste the token into tmdbReadAccessToken
```

Get the token from https://www.themoviedb.org/settings/api → **API Read Access
Token** (the long `eyJ...` string, *not* the v3 API key). It is sent as
`Authorization: Bearer <token>`; the credential never appears in a URL.

A `--dart-define=TMDB_TOKEN=...` takes precedence over the file when supplied,
for builds that shouldn't write the token to disk. Read both through
`AppSecrets`, never `secrets.dart` directly.

**An empty token is a supported state.** The app stays fully usable and TMDB
calls return an `unauthorized` failure without hitting the network — metadata
is an enhancement, never a prerequisite (see Project Vision).

**TMDB attribution is required by their terms.** `TmdbAttribution` renders the
"Metadata provided by TMDB" line on Manage Folders. The official logo must be
downloaded from https://www.themoviedb.org/about/logos-attribution, saved to
`assets/tmdb/tmdb_logo.png`, and declared in `pubspec.yaml`; never substitute a
hand-made approximation of their mark.

## Build Phases

- **Phase 1 — Playback core (current).** media_kit-based player, app shell,
  dark theme, home screen. Open a file and play it.
- **Phase 2 — Library scanner.** Recursively index local folders in place into
  drift; Netflix-style browsing grid.
- **Phase 3 — TMDB metadata.** Match indexed titles and enrich with posters,
  overviews, and episode data.
- **Phase 4 — Resume / continue-watching.** Persist playback progress and
  surface a continue-watching row.
- **Phase 5 — Polish.** Transitions, artwork treatments, keyboard/remote
  navigation, and overall UX refinement.

## Commands

```bash
flutter pub get          # install dependencies
flutter analyze          # static analysis — must be clean
flutter test             # run tests
flutter build apk --debug  # full native build (Android is the primary target)
flutter run              # launch on the connected Android device
```

## Testing & verification workflow

This project targets **Android as the primary platform**. Follow this workflow
for every task, without exception.

- **Android-only builds & passes.** Desktop is out of scope and iOS can't be
  tested yet (see Platform Policy), so every build and device pass is Android.
  Never run `flutter build windows`/`macos`/`linux` or `flutter run -d windows`.
  iOS still needs iOS-compatible code — it just stays out of the verification
  loop below.
- **Every task must pass all three checks, all green:**
  1. `flutter analyze`
  2. `flutter test`
  3. `flutter build apk --debug`
- **After the checks pass, the task is NOT done.** Do not declare completion.
  Instead, say exactly: **"Ready for device pass — please connect your phone"**,
  then wait for the user to confirm the phone is connected.
- Once the user confirms, run `flutter run` to launch on the device and give a
  precise, numbered list of what to test manually.
- **Only mark the task complete after the user confirms the device pass
  succeeded.**
