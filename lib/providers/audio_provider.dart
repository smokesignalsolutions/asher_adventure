import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';

class AudioState {
  final double volume;
  final bool isMuted;

  const AudioState({this.volume = 0.7, this.isMuted = false});

  AudioState copyWith({double? volume, bool? isMuted}) {
    return AudioState(
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class AudioNotifier extends StateNotifier<AudioState> {
  final AudioService _audio = AudioService();

  AudioNotifier() : super(const AudioState()) {
    _init();
  }

  Future<void> _init() async {
    await _audio.init();
    state = AudioState(volume: _audio.volume, isMuted: _audio.isMuted);
  }

  Future<void> playMusic(MusicTrack track) async {
    await _audio.playMusic(track);
  }

  Future<void> stopMusic() async {
    await _audio.stopMusic();
  }

  Future<void> playSfx(SfxType sfx) async {
    await _audio.playSfx(sfx);
  }

  Future<void> setVolume(double value) async {
    await _audio.setVolume(value);
    state = state.copyWith(volume: value);
  }

  Future<void> toggleMute() async {
    await _audio.toggleMute();
    state = state.copyWith(isMuted: _audio.isMuted);
  }
}

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});
