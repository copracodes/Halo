import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/playback_prefs_repository.dart';

/// Global playback defaults: the languages and subtitle behaviour a fresh title
/// starts from before it has learned any of its own preferences, plus the
/// speed-memory toggle. Per-show and per-film choices override these.
class PlaybackSettingsScreen extends ConsumerWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(playbackPrefsRepositoryProvider);
    final globalAsync = ref.watch(globalPlaybackPrefsProvider);
    final global = globalAsync.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Playback')),
      body: ListView(
        children: [
          const _SectionLabel('LANGUAGES'),
          _LanguageTile(
            title: 'Preferred audio language',
            subtitle: 'Auto-select this audio track when a title has it',
            value: global?.preferredAudioLang,
            onChanged: (code) => prefs.saveGlobalAudioLang(code),
          ),
          _LanguageTile(
            title: 'Preferred subtitle language',
            subtitle: 'Auto-select this subtitle track when subtitles are on',
            value: global?.preferredSubtitleLang,
            onChanged: (code) => prefs.saveGlobalSubtitleLang(code),
          ),
          const Divider(height: 24),
          const _SectionLabel('SUBTITLES'),
          SwitchListTile(
            title: const Text(
              'Show subtitles by default',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: const Text(
              'New titles start with subtitles on',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            value: global?.subtitlesEnabled ?? false,
            activeThumbColor: AppColors.accent,
            onChanged: (on) => prefs.saveGlobalSubtitlesEnabled(on),
          ),
          const Divider(height: 24),
          const _SectionLabel('SPEED'),
          SwitchListTile(
            title: const Text(
              'Remember playback speed per show',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: const Text(
              'Each show and film keeps the speed you last used',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            value: global?.rememberSpeedPerShow ?? true,
            activeThumbColor: AppColors.accent,
            onChanged: (on) => prefs.saveRememberSpeed(on),
          ),
        ],
      ),
    );
  }
}

/// The languages offered as defaults, by canonical code. Kept short and common;
/// per-title learning covers anything not listed here.
const List<({String code, String label})> _languages = [
  (code: 'en', label: 'English'),
  (code: 'es', label: 'Spanish'),
  (code: 'fr', label: 'French'),
  (code: 'de', label: 'German'),
  (code: 'it', label: 'Italian'),
  (code: 'pt', label: 'Portuguese'),
  (code: 'ru', label: 'Russian'),
  (code: 'ja', label: 'Japanese'),
  (code: 'ko', label: 'Korean'),
  (code: 'zh', label: 'Chinese'),
  (code: 'hi', label: 'Hindi'),
  (code: 'ar', label: 'Arabic'),
  (code: 'nl', label: 'Dutch'),
  (code: 'sv', label: 'Swedish'),
  (code: 'pl', label: 'Polish'),
  (code: 'tr', label: 'Turkish'),
];

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // A stored code that isn't in the short list still shows as "No preference"
    // in the menu, but the underlying value is left alone until changed.
    final known = _languages.any((l) => l.code == value);

    return ListTile(
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: DropdownButton<String?>(
        value: known ? value : null,
        dropdownColor: AppColors.surface,
        underline: const SizedBox.shrink(),
        hint: const Text(
          'No preference',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        items: [
          const DropdownMenuItem<String?>(
            child: Text(
              'No preference',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          for (final language in _languages)
            DropdownMenuItem<String?>(
              value: language.code,
              child: Text(
                language.label,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// The global playback-preferences row as a live stream, for this screen.
final globalPlaybackPrefsProvider =
    StreamProvider<PlaybackPrefsData?>((ref) {
  return ref.watch(playbackPrefsRepositoryProvider).watchGlobal();
});
