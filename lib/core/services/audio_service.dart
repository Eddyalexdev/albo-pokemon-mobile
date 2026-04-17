import 'package:just_audio/just_audio.dart';

/// Service for managing background and battle music using just_audio.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final AudioPlayer _battleMusicPlayer = AudioPlayer();

  bool _isBattleMusicPlaying = false;

  /// Play background music (loops continuously).
  Future<void> playBgMusic() async {
    await _bgMusicPlayer.setAsset('assets/audio/bg-music.mp3');
    await _bgMusicPlayer.setLoopMode(LoopMode.one);
    await _bgMusicPlayer.play();
    _isBattleMusicPlaying = false;
  }

  /// Crossfade from background music to battle music.
  Future<void> crossfadeToBattle() async {
    if (_isBattleMusicPlaying) return;

    await _battleMusicPlayer.setAsset('assets/audio/battle-music.mp3');
    await _battleMusicPlayer.setLoopMode(LoopMode.one);

    // Crossfade: lower bg, raise battle over 500ms
    _bgMusicPlayer.setVolume(0.3);
    await Future.delayed(const Duration(milliseconds: 250));
    await _battleMusicPlayer.play();
    await Future.delayed(const Duration(milliseconds: 250));
    await _bgMusicPlayer.stop();
    _bgMusicPlayer.setVolume(1.0);
    _isBattleMusicPlaying = true;
  }

  /// Crossfade from battle music back to background music.
  Future<void> crossfadeToBg() async {
    if (!_isBattleMusicPlaying) return;

    // Crossfade: lower battle, raise bg over 500ms
    _battleMusicPlayer.setVolume(0.3);
    await Future.delayed(const Duration(milliseconds: 250));
    await _bgMusicPlayer.play();
    await Future.delayed(const Duration(milliseconds: 250));
    await _battleMusicPlayer.stop();
    _battleMusicPlayer.setVolume(1.0);
    _isBattleMusicPlaying = false;
  }

  /// Stop all music.
  Future<void> stop() async {
    await _bgMusicPlayer.stop();
    await _battleMusicPlayer.stop();
    _isBattleMusicPlaying = false;
  }

  /// Dispose all audio players.
  void dispose() {
    _bgMusicPlayer.dispose();
    _battleMusicPlayer.dispose();
  }
}
