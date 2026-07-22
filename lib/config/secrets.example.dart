// Template for the git-ignored `secrets.dart`.
//
// Setup:
//   1. Copy this file to `lib/config/secrets.dart`.
//   2. Paste your TMDB v4 Read Access Token between the quotes.
//
// `secrets.dart` is git-ignored, so the token never reaches the repository.
// This template is checked in so a fresh clone knows what is required — the
// project will not compile until `secrets.dart` exists.

/// TMDB **v4 Read Access Token** (not the v3 API key).
///
/// Find it at https://www.themoviedb.org/settings/api under
/// "API Read Access Token". It is a long string beginning `eyJ...`, and it is
/// sent as `Authorization: Bearer <token>`.
///
/// Leave empty to run without metadata: the app stays fully usable, and TMDB
/// calls return a "not configured" failure rather than throwing.
const String tmdbReadAccessToken = '';
