import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MusicTrack {
  title,
  exploration,
  battle,
  bossBattle,
  shop,
  rest,
  event,
  treasure,
  victory,
  gameOver;

  static final _rng = Random();

  /// Returns a random variant path for this track (1-5).
  String get assetPath {
    final variant = _rng.nextInt(5) + 1;
    final baseName = switch (this) {
      MusicTrack.title => 'title_theme',
      MusicTrack.exploration => 'exploration',
      MusicTrack.battle => 'battle',
      MusicTrack.bossBattle => 'boss_battle',
      MusicTrack.shop => 'shop',
      MusicTrack.rest => 'rest',
      MusicTrack.event => 'event',
      MusicTrack.treasure => 'treasure',
      MusicTrack.victory => 'victory',
      MusicTrack.gameOver => 'game_over',
    };
    return 'audio/music/${baseName}_$variant.wav';
  }
}

enum SfxType {
  attackHit('audio/sfx/attack_hit.wav'),
  meleeHit('audio/sfx/melee_hit.wav'),
  spellCast('audio/sfx/spell_cast.wav'),
  levelUp('audio/sfx/level_up.wav'),
  goldPickup('audio/sfx/gold_pickup.wav'),
  menuSelect('audio/sfx/menu_select.wav');

  final String assetPath;
  const SfxType(this.assetPath);
}

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final _musicPlayer = AudioPlayer();
  final _sfxPlayer = AudioPlayer();

  MusicTrack? _currentTrack;
  String? _currentPath;
  double _volume = 0.7;
  bool _muted = false;
  bool _initialized = false;

  double get volume => _volume;
  bool get isMuted => _muted;
  MusicTrack? get currentTrack => _currentTrack;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('audio_volume') ?? 0.7;
    _muted = prefs.getBool('audio_muted') ?? false;

    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _applyVolume();
  }

  Future<void> playMusic(MusicTrack track) async {
    if (track == _currentTrack) return;
    _currentTrack = track;

    // Pick a random variant each time the track type changes
    _currentPath = track.assetPath;

    await _musicPlayer.stop();
    if (!_muted) {
      await _musicPlayer.setSource(AssetSource(_currentPath!));
      await _applyVolume();
      await _musicPlayer.resume();
    }
  }

  Future<void> stopMusic() async {
    _currentTrack = null;
    await _musicPlayer.stop();
  }

  Future<void> playSfx(SfxType sfx) async {
    if (_muted) return;
    await _sfxPlayer.stop();
    // SFX play louder than music (1.3x, capped at 1.0)
    await _sfxPlayer.setVolume((_volume * 1.3).clamp(0.0, 1.0));
    await _sfxPlayer.play(AssetSource(sfx.assetPath));
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _applyVolume();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('audio_volume', _volume);
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    if (_muted) {
      await _musicPlayer.pause();
    } else if (_currentPath != null) {
      await _musicPlayer.setSource(AssetSource(_currentPath!));
      await _applyVolume();
      await _musicPlayer.resume();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_muted', _muted);
  }

  Future<void> setMuted(bool muted) async {
    if (_muted == muted) return;
    _muted = muted;
    if (_muted) {
      await _musicPlayer.pause();
    } else if (_currentPath != null) {
      await _musicPlayer.setSource(AssetSource(_currentPath!));
      await _applyVolume();
      await _musicPlayer.resume();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_muted', _muted);
  }

  Future<void> _applyVolume() async {
    await _musicPlayer.setVolume(_muted ? 0.0 : _volume);
  }
}
