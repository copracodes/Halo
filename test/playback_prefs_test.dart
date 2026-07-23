// Sticky playback preferences: the resolution order (show beats global beats
// default), the repository's partial writes, and speed persistence honouring
// the global toggle — the last driven through the real controller against a
// fake engine.

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/data/repositories/playback_prefs_repository.dart';
import 'package:halo/features/player/playback_prefs.dart';
import 'package:halo/features/player/player_controller.dart';
import 'package:halo/features/player/player_engine.dart';

/// A no-op engine so the controller can be driven without a native player.
class _FakeEngine implements PlayerEngine {
  double? rate;

  @override
  Future<void> setRate(double value) async => rate = value;

  @override
  Future<void> dispose() async {}
  @override
  Future<void> pause() async {}

  @override
  PlayerStream get stream => throw UnimplementedError();
  @override
  VideoController? get videoController => null;
  @override
  Future<void> open(String uri, {Duration? startAt, bool play = true}) async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> playOrPause() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> setAudioTrack(AudioTrack track) async {}
  @override
  Future<void> setSubtitleTrack(SubtitleTrack track) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PlaybackPrefsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PlaybackPrefsRepository(db);
  });

  tearDown(() async => db.close());

  const show = PlaybackScope(PrefScope.show, 'breaking bad');

  group('resolution order', () {
    test('a show preference beats the global default', () async {
      await repo.saveGlobalAudioLang('en');
      await repo.saveAudioPref(show.type, show.key, lang: 'ja');

      final resolved = resolvePlaybackPrefs(
        scope: await repo.forScope(show.type, show.key),
        global: await repo.global(),
      );

      expect(resolved.audioLang, 'ja');
    });

    test('the global default applies when the scope has no opinion', () async {
      await repo.saveGlobalSubtitleLang('en');

      final resolved = resolvePlaybackPrefs(
        scope: await repo.forScope(show.type, show.key),
        global: await repo.global(),
      );

      expect(resolved.subtitleLang, 'en');
    });

    test('nothing set resolves to the built-in defaults', () async {
      final resolved = resolvePlaybackPrefs(
        scope: await repo.forScope(show.type, show.key),
        global: await repo.global(),
      );

      expect(resolved.audioLang, isNull);
      expect(resolved.subtitleLang, isNull);
      expect(resolved.subtitlesEnabled, isNull,
          reason: 'no opinion means keep the file default');
      expect(resolved.speed, 1.0);
    });

    test('a scope turning subtitles off overrides a global subtitle language',
        () async {
      await repo.saveGlobalSubtitleLang('en');
      await repo.saveGlobalSubtitlesEnabled(true);
      await repo.saveSubtitlesEnabled(show.type, show.key, false);

      final resolved = resolvePlaybackPrefs(
        scope: await repo.forScope(show.type, show.key),
        global: await repo.global(),
      );

      expect(resolved.subtitlesEnabled, isFalse,
          reason: 'the show’s "off" wins over the global language');
    });

    test('a per-show speed beats the global speed', () async {
      await repo.saveSpeed(PrefScope.global, '', 1.25);
      await repo.saveSpeed(show.type, show.key, 1.5);

      final resolved = resolvePlaybackPrefs(
        scope: await repo.forScope(show.type, show.key),
        global: await repo.global(),
      );

      expect(resolved.speed, 1.5);
    });

    test('subtitle delay defaults to zero and is remembered per show', () async {
      var resolved = resolvePlaybackPrefs(
        scope: await repo.forScope(show.type, show.key),
        global: await repo.global(),
      );
      expect(resolved.subtitleDelayMs, 0);

      await repo.saveSubtitleDelay(show.type, show.key, -1500);
      resolved = resolvePlaybackPrefs(
        scope: await repo.forScope(show.type, show.key),
        global: await repo.global(),
      );
      expect(resolved.subtitleDelayMs, -1500,
          reason: 'negative = subtitles earlier');
    });
  });

  group('repository partial writes', () {
    test('changing audio never disturbs a remembered subtitle or speed',
        () async {
      await repo.saveSubtitlePref(show.type, show.key, lang: 'en', enabled: true);
      await repo.saveSpeed(show.type, show.key, 1.5);
      await repo.saveAudioPref(show.type, show.key, lang: 'ja');

      final row = await repo.forScope(show.type, show.key);
      expect(row!.preferredAudioLang, 'ja');
      expect(row.preferredSubtitleLang, 'en', reason: 'subtitle untouched');
      expect(row.subtitlesEnabled, isTrue);
      expect(row.preferredSpeed, 1.5, reason: 'speed untouched');
    });
  });

  group('rememberSpeedPerShow', () {
    test('defaults on when never configured', () async {
      expect(rememberSpeedPerShow(await repo.global()), isTrue);
    });

    test('reflects the stored toggle', () async {
      await repo.saveRememberSpeed(false);
      expect(rememberSpeedPerShow(await repo.global()), isFalse);
    });
  });

  group('speed persistence honours the toggle', () {
    Future<(ProviderContainer, PlayerController, PlaybackPrefsRepository)>
        harness() async {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      container.listen(playerControllerProvider, (_, __) {}, fireImmediately: true);
      final controller = container.read(playerControllerProvider.notifier);
      final prefs = container.read(playbackPrefsRepositoryProvider);
      controller.debugAttachEngine(_FakeEngine());
      return (container, controller, prefs);
    }

    test('with the toggle on, a speed change is remembered for the show',
        () async {
      final (_, controller, prefs) = await harness();
      controller.debugConfigurePrefs(
        prefs: prefs,
        scope: show,
        rememberSpeed: true,
      );

      controller.setRate(1.5);
      await controller.debugLastPrefWrite;

      final row = await prefs.forScope(show.type, show.key);
      expect(row?.preferredSpeed, 1.5);
    });

    test('with the toggle off, a speed change is not persisted', () async {
      final (_, controller, prefs) = await harness();
      controller.debugConfigurePrefs(
        prefs: prefs,
        scope: show,
        rememberSpeed: false,
      );

      controller.setRate(1.5);
      await controller.debugLastPrefWrite;

      expect(controller.debugLastPrefWrite, isNull,
          reason: 'nothing was written');
      expect(await prefs.forScope(show.type, show.key), isNull);
    });
  });
}
