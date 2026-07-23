// Verifies the critical exit-path invariant: when the player provider is
// disposed (screen popped), the notifier tears down and disposes the underlying
// player engine. A fake engine stands in for the native media_kit player, which
// can't be constructed headlessly.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:halo/features/player/player_controller.dart';
import 'package:halo/features/player/player_engine.dart';

class _FakeEngine implements PlayerEngine {
  bool disposed = false;
  bool paused = false;

  @override
  Future<void> dispose() async => disposed = true;

  @override
  Future<void> pause() async => paused = true;

  // The disposal test never touches these.
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
  Future<void> setRate(double rate) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> setAudioTrack(AudioTrack track) async {}
  @override
  Future<void> setSubtitleTrack(SubtitleTrack track) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('disposing the provider stops and disposes the player engine', () {
    final fake = _FakeEngine();
    final container = ProviderContainer();
    // Keep the auto-dispose provider alive until we dispose the container.
    container.listen(playerControllerProvider, (_, __) {}, fireImmediately: true);

    // Simulate an opened player, then tear the provider down.
    container.read(playerControllerProvider.notifier).debugAttachEngine(fake);
    expect(fake.disposed, isFalse);

    container.dispose();

    expect(fake.paused, isTrue, reason: 'audio should be stopped on exit');
    expect(fake.disposed, isTrue, reason: 'native player must be disposed');
  });
}
