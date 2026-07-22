import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Thin seam over media_kit's [Player]/[VideoController].
///
/// Exists so the notifier depends on an interface rather than the concrete,
/// native-backed [Player]: it lets the single-player guard dispose any engine
/// uniformly, and lets tests substitute a fake (a real [Player] can't be
/// constructed headlessly — its constructor spins up a native mpv instance).
abstract class PlayerEngine {
  PlayerStream get stream;
  VideoController? get videoController;

  Future<void> open(String uri);
  Future<void> play();
  Future<void> pause();
  Future<void> playOrPause();
  Future<void> seek(Duration position);
  Future<void> setRate(double rate);
  Future<void> setVolume(double volume);
  Future<void> setAudioTrack(AudioTrack track);
  Future<void> setSubtitleTrack(SubtitleTrack track);
  Future<void> dispose();
}

/// Default [PlayerEngine] backed by a real media_kit [Player].
class MediaKitEngine implements PlayerEngine {
  MediaKitEngine() {
    _player = Player();
    _videoController = VideoController(_player);
  }

  late final Player _player;
  late final VideoController _videoController;

  @override
  PlayerStream get stream => _player.stream;

  @override
  VideoController? get videoController => _videoController;

  @override
  Future<void> open(String uri) => _player.open(Media(uri));

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> playOrPause() => _player.playOrPause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setRate(double rate) => _player.setRate(rate);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> setAudioTrack(AudioTrack track) => _player.setAudioTrack(track);

  @override
  Future<void> setSubtitleTrack(SubtitleTrack track) =>
      _player.setSubtitleTrack(track);

  @override
  Future<void> dispose() => _player.dispose();
}
