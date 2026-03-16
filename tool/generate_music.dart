import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// ── Constants ────────────────────────────────────────────────────────────────
const int sampleRate = 22050;
const int bitsPerSample = 8;
const int numChannels = 1;

final Random _rng = Random(42);

// ── Note Frequencies ─────────────────────────────────────────────────────────
const double C3 = 130.81, Cs3 = 138.59, D3 = 146.83, Ds3 = 155.56,
    E3 = 164.81, F3 = 174.61, Fs3 = 185.00, G3 = 196.00, Gs3 = 207.65,
    A3 = 220.00, As3 = 233.08, B3 = 246.94;
const double C4 = 261.63, Cs4 = 277.18, D4 = 293.66, Ds4 = 311.13,
    E4 = 329.63, F4 = 349.23, Fs4 = 369.99, G4 = 392.00, Gs4 = 415.30,
    A4 = 440.00, As4 = 466.16, B4 = 493.88;
const double C5 = 523.25, Cs5 = 554.37, D5 = 587.33, Ds5 = 622.25,
    E5 = 659.26, F5 = 698.46, Fs5 = 739.99, G5 = 783.99, Gs5 = 830.61,
    A5 = 880.00, As5 = 932.33, B5 = 987.77;
const double C2 = 65.41, D2 = 73.42, E2 = 82.41, F2 = 87.31, G2 = 98.00,
    A2 = 110.00, As2 = 116.54, B2 = 123.47;
const double REST = 0.0;

// ── Waveform Types ───────────────────────────────────────────────────────────
enum Wave { square, triangle, sawtooth, noise, sine }

// ── ADSR Envelope ────────────────────────────────────────────────────────────
class Envelope {
  final double attack, decay, sustain, release;
  const Envelope({
    this.attack = 0.01,
    this.decay = 0.05,
    this.sustain = 0.7,
    this.release = 0.05,
  });

  double amplitude(double t, double duration) {
    final releaseStart = duration - release;
    if (t < attack) return t / attack;
    if (t < attack + decay) {
      return 1.0 - (1.0 - sustain) * ((t - attack) / decay);
    }
    if (t < releaseStart) return sustain;
    if (t < duration) return sustain * (1.0 - (t - releaseStart) / release);
    return 0.0;
  }
}

// ── Note Definition ──────────────────────────────────────────────────────────
class Note {
  final double freq;
  final double beats;
  final Wave wave;
  final double volume;
  const Note(this.freq, this.beats, this.wave, [this.volume = 0.8]);
}

// ── Channel: sequence of notes with an envelope ──────────────────────────────
class Channel {
  final List<Note> notes;
  final Envelope envelope;
  const Channel(this.notes, [this.envelope = const Envelope()]);
}

// ── Track Definition ─────────────────────────────────────────────────────────
class Track {
  final String name;
  final double bpm;
  final List<Channel> channels;
  const Track(this.name, this.bpm, this.channels);
}

// ── Waveform sample generator ────────────────────────────────────────────────
double waveform(Wave w, double phase) {
  switch (w) {
    case Wave.square:
      return (phase % 1.0 < 0.5) ? 1.0 : -1.0;
    case Wave.triangle:
      return 2.0 * (2.0 * (phase % 1.0) - 1.0).abs() - 1.0;
    case Wave.sawtooth:
      return 2.0 * (phase % 1.0) - 1.0;
    case Wave.noise:
      return _rng.nextDouble() * 2.0 - 1.0;
    case Wave.sine:
      return sin(2.0 * pi * phase);
  }
}

// ── Render a track to PCM samples ────────────────────────────────────────────
Uint8List renderTrack(Track track) {
  final beatDuration = 60.0 / track.bpm;

  // Calculate total duration from the longest channel
  double totalDuration = 0;
  for (final ch in track.channels) {
    double d = 0;
    for (final n in ch.notes) {
      d += n.beats * beatDuration;
    }
    if (d > totalDuration) totalDuration = d;
  }

  final numSamples = (totalDuration * sampleRate).toInt();
  final buffer = Float64List(numSamples);

  for (final ch in track.channels) {
    double time = 0;
    double phase = 0;
    for (final note in ch.notes) {
      final noteDur = note.beats * beatDuration;
      final startSample = (time * sampleRate).toInt();
      final endSample = ((time + noteDur) * sampleRate).toInt().clamp(0, numSamples);

      for (int i = startSample; i < endSample; i++) {
        final t = (i - startSample) / sampleRate;
        final env = ch.envelope.amplitude(t, noteDur);
        if (note.freq > 0) {
          final sample = waveform(note.wave, phase) * note.volume * env;
          buffer[i] += sample;
          phase += note.freq / sampleRate;
        }
      }
      time += noteDur;
      if (note.freq <= 0) phase = 0;
    }
  }

  // Normalize and convert to 8-bit unsigned
  double maxVal = 0;
  for (int i = 0; i < numSamples; i++) {
    if (buffer[i].abs() > maxVal) maxVal = buffer[i].abs();
  }
  if (maxVal < 0.001) maxVal = 1.0;

  final pcm = Uint8List(numSamples);
  for (int i = 0; i < numSamples; i++) {
    final normalized = buffer[i] / maxVal;
    pcm[i] = ((normalized * 0.45 + 0.5) * 255).round().clamp(0, 255);
  }
  return pcm;
}

// ── Write WAV file ───────────────────────────────────────────────────────────
void writeWav(String path, Uint8List pcm) {
  final dataSize = pcm.length;
  final fileSize = 36 + dataSize;
  final header = ByteData(44);

  // RIFF header
  header.setUint8(0, 0x52); // R
  header.setUint8(1, 0x49); // I
  header.setUint8(2, 0x46); // F
  header.setUint8(3, 0x46); // F
  header.setUint32(4, fileSize, Endian.little);
  header.setUint8(8, 0x57);  // W
  header.setUint8(9, 0x41);  // A
  header.setUint8(10, 0x56); // V
  header.setUint8(11, 0x45); // E

  // fmt chunk
  header.setUint8(12, 0x66); // f
  header.setUint8(13, 0x6D); // m
  header.setUint8(14, 0x74); // t
  header.setUint8(15, 0x20); // (space)
  header.setUint32(16, 16, Endian.little); // chunk size
  header.setUint16(20, 1, Endian.little);  // PCM format
  header.setUint16(22, numChannels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, sampleRate * numChannels * bitsPerSample ~/ 8, Endian.little);
  header.setUint16(32, numChannels * bitsPerSample ~/ 8, Endian.little);
  header.setUint16(34, bitsPerSample, Endian.little);

  // data chunk
  header.setUint8(36, 0x64); // d
  header.setUint8(37, 0x61); // a
  header.setUint8(38, 0x74); // t
  header.setUint8(39, 0x61); // a
  header.setUint32(40, dataSize, Endian.little);

  final file = File(path);
  file.writeAsBytesSync([...header.buffer.asUint8List(), ...pcm]);
}

// ══════════════════════════════════════════════════════════════════════════════
// TRACK DEFINITIONS — 10 categories x 5 variants each
// ══════════════════════════════════════════════════════════════════════════════

// ── Helper: repeat a pattern N times ─────────────────────────────────────────
List<Note> rep(List<Note> pattern, int times) =>
    [for (int i = 0; i < times; i++) ...pattern];

// ── Helper: arpeggio from chord tones ────────────────────────────────────────
List<Note> arp(List<double> freqs, double beats, Wave w, [double vol = 0.7]) =>
    [for (final f in freqs) Note(f, beats, w, vol)];

// ── BATTLE (140-170 BPM, minor keys, driving) ───────────────────────────────
List<Track> battleTracks() => [
  // Battle 1 — Am, 160 BPM
  Track('battle_1', 160, [
    Channel(rep([
      Note(A4, 0.5, Wave.square), Note(C5, 0.5, Wave.square),
      Note(E5, 0.5, Wave.square), Note(A4, 0.25, Wave.square),
      Note(REST, 0.25, Wave.square),
      Note(G4, 0.5, Wave.square), Note(A4, 0.5, Wave.square),
      Note(E4, 0.5, Wave.square), Note(A4, 0.5, Wave.square),
      Note(C5, 0.25, Wave.square), Note(B4, 0.25, Wave.square),
      Note(A4, 0.5, Wave.square), Note(G4, 0.5, Wave.square),
      Note(E4, 0.75, Wave.square), Note(REST, 0.25, Wave.square),
    ], 4), const Envelope(attack: 0.005, decay: 0.02, sustain: 0.8, release: 0.02)),
    Channel(rep([
      Note(A2, 1.0, Wave.triangle), Note(A2, 0.5, Wave.triangle),
      Note(E3, 0.5, Wave.triangle), Note(A2, 1.0, Wave.triangle),
      Note(G2, 1.0, Wave.triangle), Note(A2, 0.5, Wave.triangle),
      Note(C3, 0.5, Wave.triangle), Note(E3, 1.0, Wave.triangle),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.9, release: 0.03)),
    Channel(rep([
      Note(100, 0.25, Wave.noise, 0.4), Note(REST, 0.25, Wave.noise),
      Note(200, 0.25, Wave.noise, 0.3), Note(REST, 0.25, Wave.noise),
      Note(100, 0.25, Wave.noise, 0.4), Note(REST, 0.25, Wave.noise),
      Note(200, 0.25, Wave.noise, 0.3), Note(100, 0.125, Wave.noise, 0.5),
      Note(REST, 0.125, Wave.noise),
    ], 8), const Envelope(attack: 0.002, decay: 0.01, sustain: 0.5, release: 0.01)),
  ]),
  // Battle 2 — Em, 150 BPM
  Track('battle_2', 150, [
    Channel(rep([
      Note(E4, 0.5, Wave.square), Note(G4, 0.25, Wave.square),
      Note(B4, 0.25, Wave.square), Note(E5, 0.5, Wave.square),
      Note(D5, 0.5, Wave.square),
      Note(B4, 0.5, Wave.square), Note(G4, 0.5, Wave.square),
      Note(A4, 0.5, Wave.square), Note(B4, 0.5, Wave.square),
      Note(E4, 0.5, Wave.square), Note(REST, 0.5, Wave.square),
      Note(D4, 0.5, Wave.square), Note(E4, 0.5, Wave.square),
      Note(G4, 0.5, Wave.square), Note(B4, 0.5, Wave.square),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.75, release: 0.02)),
    Channel(rep([
      Note(E2, 1.0, Wave.triangle), Note(E2, 0.5, Wave.triangle),
      Note(G2, 0.5, Wave.triangle), Note(B2, 1.0, Wave.triangle),
      Note(A2, 1.0, Wave.triangle), Note(E2, 0.5, Wave.triangle),
      Note(D3, 0.5, Wave.triangle), Note(E3, 1.0, Wave.triangle),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
    Channel(rep([
      Note(150, 0.25, Wave.noise, 0.45), Note(REST, 0.5, Wave.noise),
      Note(200, 0.25, Wave.noise, 0.3),
      Note(150, 0.25, Wave.noise, 0.45), Note(REST, 0.25, Wave.noise),
      Note(200, 0.25, Wave.noise, 0.3), Note(150, 0.125, Wave.noise, 0.4),
      Note(REST, 0.125, Wave.noise),
    ], 6), const Envelope(attack: 0.002, decay: 0.01, sustain: 0.5, release: 0.01)),
  ]),
  // Battle 3 — Dm, 165 BPM
  Track('battle_3', 165, [
    Channel(rep([
      Note(D5, 0.25, Wave.sawtooth), Note(F5, 0.25, Wave.sawtooth),
      Note(A4, 0.5, Wave.sawtooth), Note(D5, 0.5, Wave.sawtooth),
      Note(C5, 0.25, Wave.sawtooth), Note(A4, 0.25, Wave.sawtooth),
      Note(G4, 0.5, Wave.sawtooth), Note(F4, 0.5, Wave.sawtooth),
      Note(E4, 0.5, Wave.sawtooth), Note(D4, 0.5, Wave.sawtooth),
      Note(F4, 0.5, Wave.sawtooth), Note(A4, 0.5, Wave.sawtooth),
      Note(D5, 0.25, Wave.sawtooth), Note(REST, 0.25, Wave.sawtooth),
      Note(C5, 0.5, Wave.sawtooth),
    ], 4), const Envelope(attack: 0.005, decay: 0.02, sustain: 0.7, release: 0.02)),
    Channel(rep([
      Note(D2, 0.5, Wave.triangle), Note(D2, 0.5, Wave.triangle),
      Note(A2, 0.5, Wave.triangle), Note(D2, 0.5, Wave.triangle),
      Note(C3, 0.5, Wave.triangle), Note(A2, 0.5, Wave.triangle),
      Note(G2, 0.5, Wave.triangle), Note(A2, 0.5, Wave.triangle),
    ], 5), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
    Channel(rep([
      Note(100, 0.25, Wave.noise, 0.5), Note(REST, 0.25, Wave.noise),
      Note(250, 0.125, Wave.noise, 0.25), Note(REST, 0.125, Wave.noise),
      Note(100, 0.25, Wave.noise, 0.5), Note(250, 0.125, Wave.noise, 0.25),
      Note(REST, 0.375, Wave.noise),
    ], 10), const Envelope(attack: 0.002, decay: 0.01, sustain: 0.5, release: 0.01)),
  ]),
  // Battle 4 — Cm, 145 BPM
  Track('battle_4', 145, [
    Channel(rep([
      Note(C5, 0.5, Wave.square), Note(Ds5, 0.5, Wave.square),
      Note(G4, 0.5, Wave.square), Note(C5, 0.25, Wave.square),
      Note(As4, 0.25, Wave.square),
      Note(G4, 0.5, Wave.square), Note(F4, 0.5, Wave.square),
      Note(Ds4, 0.5, Wave.square), Note(C4, 0.5, Wave.square),
      Note(Ds4, 0.5, Wave.square), Note(G4, 0.5, Wave.square),
      Note(C5, 0.5, Wave.square), Note(REST, 0.5, Wave.square),
    ], 4), const Envelope(attack: 0.005, decay: 0.02, sustain: 0.8, release: 0.02)),
    Channel(rep([
      Note(C2, 1.0, Wave.triangle), Note(Ds3, 0.5, Wave.triangle),
      Note(G2, 0.5, Wave.triangle), Note(C2, 1.0, Wave.triangle),
      Note(As2, 0.5, Wave.triangle), Note(G2, 0.5, Wave.triangle),
      Note(F2, 0.5, Wave.triangle), Note(G2, 0.5, Wave.triangle),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
    Channel(rep([
      Note(120, 0.25, Wave.noise, 0.4), Note(REST, 0.25, Wave.noise),
      Note(250, 0.25, Wave.noise, 0.3), Note(120, 0.25, Wave.noise, 0.4),
      Note(REST, 0.5, Wave.noise),
      Note(120, 0.25, Wave.noise, 0.4), Note(REST, 0.25, Wave.noise),
    ], 8), const Envelope(attack: 0.002, decay: 0.01, sustain: 0.5, release: 0.01)),
  ]),
  // Battle 5 — Gm, 170 BPM
  Track('battle_5', 170, [
    Channel(rep([
      Note(G4, 0.25, Wave.square), Note(As4, 0.25, Wave.square),
      Note(D5, 0.5, Wave.square), Note(G5, 0.5, Wave.square, 0.7),
      Note(F5, 0.25, Wave.square), Note(D5, 0.25, Wave.square),
      Note(C5, 0.5, Wave.square), Note(As4, 0.5, Wave.square),
      Note(G4, 0.5, Wave.square), Note(D4, 0.5, Wave.square),
      Note(G4, 0.5, Wave.square), Note(As4, 0.25, Wave.square),
      Note(C5, 0.25, Wave.square), Note(D5, 0.5, Wave.square),
      Note(REST, 0.25, Wave.square), Note(G4, 0.25, Wave.square),
    ], 4), const Envelope(attack: 0.003, decay: 0.02, sustain: 0.8, release: 0.02)),
    Channel(rep([
      Note(G2, 0.5, Wave.triangle), Note(G2, 0.5, Wave.triangle),
      Note(D3, 0.5, Wave.triangle), Note(G2, 0.5, Wave.triangle),
      Note(F2, 0.5, Wave.triangle), Note(G2, 0.5, Wave.triangle),
      Note(As2, 0.5, Wave.triangle), Note(D3, 0.5, Wave.triangle),
    ], 5), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
    Channel(rep([
      Note(100, 0.125, Wave.noise, 0.5), Note(REST, 0.125, Wave.noise),
      Note(200, 0.125, Wave.noise, 0.3), Note(REST, 0.125, Wave.noise),
      Note(100, 0.125, Wave.noise, 0.5), Note(REST, 0.125, Wave.noise),
      Note(200, 0.125, Wave.noise, 0.3), Note(100, 0.125, Wave.noise, 0.45),
    ], 12), const Envelope(attack: 0.002, decay: 0.01, sustain: 0.5, release: 0.01)),
  ]),
];

// ── BOSS BATTLE (120-150 BPM, minor, menacing) ──────────────────────────────
List<Track> bossBattleTracks() => [
  // Boss 1 — Am, 130 BPM, heavy
  Track('boss_battle_1', 130, [
    Channel(rep([
      Note(A3, 1.0, Wave.sawtooth), Note(REST, 0.5, Wave.sawtooth),
      Note(A3, 0.5, Wave.sawtooth), Note(C4, 1.0, Wave.sawtooth),
      Note(B3, 0.5, Wave.sawtooth), Note(A3, 0.5, Wave.sawtooth),
      Note(E4, 1.0, Wave.sawtooth), Note(REST, 0.5, Wave.sawtooth),
      Note(D4, 0.5, Wave.sawtooth), Note(C4, 1.0, Wave.sawtooth),
      Note(A3, 1.0, Wave.sawtooth),
    ], 3), const Envelope(attack: 0.01, decay: 0.05, sustain: 0.8, release: 0.05)),
    Channel(rep([
      Note(A2, 1.5, Wave.triangle, 0.9), Note(A2, 0.5, Wave.triangle, 0.9),
      Note(E2, 1.0, Wave.triangle, 0.9), Note(A2, 1.0, Wave.triangle, 0.9),
      Note(G2, 1.5, Wave.triangle, 0.9), Note(A2, 0.5, Wave.triangle, 0.9),
      Note(E2, 1.0, Wave.triangle, 0.9), Note(A2, 1.0, Wave.triangle, 0.9),
    ], 3), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.9, release: 0.05)),
    Channel(rep([
      Note(80, 0.5, Wave.noise, 0.5), Note(REST, 0.5, Wave.noise),
      Note(80, 0.25, Wave.noise, 0.5), Note(80, 0.25, Wave.noise, 0.6),
      Note(REST, 0.5, Wave.noise),
      Note(80, 0.5, Wave.noise, 0.5), Note(REST, 0.5, Wave.noise),
      Note(200, 0.25, Wave.noise, 0.3), Note(REST, 0.25, Wave.noise),
      Note(80, 0.5, Wave.noise, 0.5), Note(REST, 0.5, Wave.noise),
    ], 4), const Envelope(attack: 0.005, decay: 0.02, sustain: 0.6, release: 0.02)),
  ]),
  // Boss 2 — Em, 140 BPM
  Track('boss_battle_2', 140, [
    Channel(rep([
      Note(E4, 0.5, Wave.square, 0.9), Note(E4, 0.25, Wave.square, 0.7),
      Note(REST, 0.25, Wave.square),
      Note(G4, 0.5, Wave.square, 0.9), Note(Fs4, 0.5, Wave.square),
      Note(E4, 1.0, Wave.square), Note(D4, 0.5, Wave.square),
      Note(E4, 0.5, Wave.square),
      Note(B3, 1.0, Wave.square), Note(REST, 0.5, Wave.square),
      Note(E4, 0.5, Wave.square),
    ], 4), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(E2, 1.0, Wave.triangle, 0.9), Note(E2, 1.0, Wave.triangle, 0.9),
      Note(G2, 1.0, Wave.triangle, 0.9), Note(B2, 1.0, Wave.triangle, 0.9),
      Note(A2, 1.0, Wave.triangle, 0.9), Note(E2, 1.0, Wave.triangle, 0.9),
    ], 4), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.9, release: 0.05)),
    Channel(rep([
      Note(90, 0.5, Wave.noise, 0.5), Note(200, 0.25, Wave.noise, 0.3),
      Note(REST, 0.25, Wave.noise),
      Note(90, 0.25, Wave.noise, 0.5), Note(REST, 0.25, Wave.noise),
      Note(90, 0.5, Wave.noise, 0.5), Note(200, 0.25, Wave.noise, 0.3),
      Note(REST, 0.25, Wave.noise), Note(90, 0.5, Wave.noise, 0.5),
      Note(REST, 0.5, Wave.noise),
    ], 5), const Envelope(attack: 0.003, decay: 0.01, sustain: 0.5, release: 0.01)),
  ]),
  // Boss 3 — Cm, 125 BPM, slow and heavy
  Track('boss_battle_3', 125, [
    Channel(rep([
      Note(C4, 1.5, Wave.sawtooth, 0.85), Note(Ds4, 1.0, Wave.sawtooth, 0.8),
      Note(C4, 0.5, Wave.sawtooth), Note(REST, 1.0, Wave.sawtooth),
      Note(G3, 1.0, Wave.sawtooth, 0.9), Note(As3, 1.0, Wave.sawtooth),
      Note(C4, 1.5, Wave.sawtooth, 0.85), Note(REST, 0.5, Wave.sawtooth),
    ], 3), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.75, release: 0.05)),
    Channel(rep([
      Note(C2, 2.0, Wave.triangle, 0.95), Note(G2, 2.0, Wave.triangle, 0.9),
      Note(As2, 2.0, Wave.triangle, 0.9), Note(C2, 2.0, Wave.triangle, 0.95),
    ], 3), const Envelope(attack: 0.03, decay: 0.05, sustain: 0.9, release: 0.05)),
    Channel(rep([
      Note(70, 0.75, Wave.noise, 0.55), Note(REST, 0.75, Wave.noise),
      Note(70, 0.5, Wave.noise, 0.55), Note(REST, 0.5, Wave.noise),
      Note(70, 0.75, Wave.noise, 0.55), Note(REST, 0.25, Wave.noise),
      Note(200, 0.25, Wave.noise, 0.3), Note(REST, 0.25, Wave.noise),
    ], 6), const Envelope(attack: 0.005, decay: 0.02, sustain: 0.5, release: 0.02)),
  ]),
  // Boss 4 — Dm, 145 BPM
  Track('boss_battle_4', 145, [
    Channel(rep([
      Note(D4, 0.5, Wave.square), Note(F4, 0.5, Wave.square),
      Note(A4, 0.5, Wave.square), Note(D5, 0.5, Wave.square, 0.9),
      Note(C5, 0.25, Wave.square), Note(A4, 0.25, Wave.square),
      Note(G4, 0.5, Wave.square), Note(F4, 0.5, Wave.square),
      Note(E4, 0.5, Wave.square), Note(D4, 1.0, Wave.square),
      Note(REST, 0.5, Wave.square),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(D2, 1.5, Wave.triangle, 0.9), Note(A2, 0.5, Wave.triangle, 0.85),
      Note(D2, 1.0, Wave.triangle, 0.9), Note(C3, 1.0, Wave.triangle, 0.85),
      Note(A2, 1.0, Wave.triangle, 0.85), Note(D2, 0.5, Wave.triangle, 0.9),
    ], 4), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.9, release: 0.05)),
    Channel(rep([
      Note(100, 0.25, Wave.noise, 0.5), Note(REST, 0.25, Wave.noise),
      Note(100, 0.25, Wave.noise, 0.5), Note(200, 0.25, Wave.noise, 0.3),
      Note(REST, 0.5, Wave.noise),
      Note(100, 0.5, Wave.noise, 0.5), Note(REST, 0.5, Wave.noise),
    ], 6), const Envelope(attack: 0.003, decay: 0.01, sustain: 0.5, release: 0.01)),
  ]),
  // Boss 5 — Gm, 135 BPM
  Track('boss_battle_5', 135, [
    Channel(rep([
      Note(G3, 1.0, Wave.sawtooth, 0.85), Note(As3, 0.5, Wave.sawtooth),
      Note(D4, 0.5, Wave.sawtooth),
      Note(G4, 1.0, Wave.sawtooth, 0.9), Note(F4, 0.5, Wave.sawtooth),
      Note(D4, 0.5, Wave.sawtooth),
      Note(C4, 1.0, Wave.sawtooth), Note(As3, 0.5, Wave.sawtooth),
      Note(G3, 0.5, Wave.sawtooth),
      Note(D4, 1.0, Wave.sawtooth), Note(REST, 0.5, Wave.sawtooth),
      Note(G3, 0.5, Wave.sawtooth),
    ], 3), const Envelope(attack: 0.01, decay: 0.04, sustain: 0.8, release: 0.04)),
    Channel(rep([
      Note(G2, 2.0, Wave.triangle, 0.9), Note(D2, 1.0, Wave.triangle, 0.85),
      Note(C2, 1.0, Wave.triangle, 0.85),
      Note(G2, 1.0, Wave.triangle, 0.9), Note(As2, 1.0, Wave.triangle, 0.85),
      Note(D3, 1.0, Wave.triangle, 0.85), Note(G2, 1.0, Wave.triangle, 0.9),
    ], 3), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.9, release: 0.05)),
    Channel(rep([
      Note(80, 0.5, Wave.noise, 0.5), Note(REST, 0.5, Wave.noise),
      Note(80, 0.25, Wave.noise, 0.5), Note(REST, 0.25, Wave.noise),
      Note(200, 0.25, Wave.noise, 0.3), Note(REST, 0.25, Wave.noise),
      Note(80, 0.5, Wave.noise, 0.5), Note(REST, 0.25, Wave.noise),
      Note(80, 0.25, Wave.noise, 0.5),
    ], 5), const Envelope(attack: 0.003, decay: 0.01, sustain: 0.5, release: 0.01)),
  ]),
];

// ── SHOP (110-130 BPM, major, cheerful) ──────────────────────────────────────
List<Track> shopTracks() => [
  // Shop 1 — C major, 120 BPM
  Track('shop_1', 120, [
    Channel(rep([
      Note(C5, 0.5, Wave.square, 0.7), Note(E5, 0.5, Wave.square, 0.7),
      Note(G5, 0.5, Wave.square, 0.7), Note(E5, 0.5, Wave.square, 0.7),
      Note(F5, 0.5, Wave.square, 0.7), Note(D5, 0.5, Wave.square, 0.7),
      Note(E5, 0.5, Wave.square, 0.7), Note(C5, 0.5, Wave.square, 0.7),
      Note(D5, 0.5, Wave.square, 0.7), Note(E5, 0.5, Wave.square, 0.7),
      Note(C5, 1.0, Wave.square, 0.7),
    ], 4), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.7, release: 0.03)),
    Channel(rep([
      Note(C3, 1.0, Wave.triangle), Note(G3, 1.0, Wave.triangle),
      Note(F3, 1.0, Wave.triangle), Note(G3, 1.0, Wave.triangle),
      Note(C3, 1.0, Wave.triangle), Note(E3, 1.0, Wave.triangle),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(300, 0.25, Wave.noise, 0.2), Note(REST, 0.75, Wave.noise),
      Note(300, 0.25, Wave.noise, 0.2), Note(REST, 0.25, Wave.noise),
      Note(300, 0.25, Wave.noise, 0.2), Note(REST, 0.25, Wave.noise),
    ], 8), const Envelope(attack: 0.002, decay: 0.01, sustain: 0.4, release: 0.01)),
  ]),
  // Shop 2 — F major, 115 BPM
  Track('shop_2', 115, [
    Channel(rep([
      Note(F4, 0.5, Wave.square, 0.7), Note(A4, 0.5, Wave.square, 0.7),
      Note(C5, 0.5, Wave.square, 0.7), Note(A4, 0.25, Wave.square, 0.7),
      Note(F4, 0.25, Wave.square, 0.7),
      Note(G4, 0.5, Wave.square, 0.7), Note(A4, 0.5, Wave.square, 0.7),
      Note(As4, 0.5, Wave.square, 0.7), Note(A4, 0.5, Wave.square, 0.7),
      Note(G4, 0.5, Wave.square, 0.7), Note(F4, 0.5, Wave.square, 0.7),
      Note(A4, 0.5, Wave.square, 0.7), Note(C5, 0.5, Wave.square, 0.7),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.7, release: 0.03)),
    Channel(rep([
      Note(F2, 1.0, Wave.triangle), Note(C3, 0.5, Wave.triangle),
      Note(A2, 0.5, Wave.triangle), Note(As2, 1.0, Wave.triangle),
      Note(C3, 1.0, Wave.triangle), Note(F2, 1.0, Wave.triangle),
      Note(G2, 1.0, Wave.triangle),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.8, release: 0.03)),
  ]),
  // Shop 3 — G major, 125 BPM
  Track('shop_3', 125, [
    Channel(rep([
      Note(G4, 0.25, Wave.sine, 0.8), Note(B4, 0.25, Wave.sine, 0.8),
      Note(D5, 0.25, Wave.sine, 0.8), Note(G5, 0.25, Wave.sine, 0.8),
      Note(D5, 0.5, Wave.sine, 0.8), Note(B4, 0.5, Wave.sine, 0.8),
      Note(A4, 0.5, Wave.sine, 0.8), Note(B4, 0.5, Wave.sine, 0.8),
      Note(G4, 0.5, Wave.sine, 0.8), Note(A4, 0.5, Wave.sine, 0.8),
      Note(B4, 0.5, Wave.sine, 0.8), Note(D5, 0.5, Wave.sine, 0.8),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.7, release: 0.03)),
    Channel(rep([
      Note(G2, 1.0, Wave.triangle), Note(D3, 1.0, Wave.triangle),
      Note(C3, 1.0, Wave.triangle), Note(D3, 0.5, Wave.triangle),
      Note(G2, 0.5, Wave.triangle),
      Note(G2, 1.0, Wave.triangle), Note(B2, 1.0, Wave.triangle),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.8, release: 0.03)),
  ]),
  // Shop 4 — D major, 130 BPM
  Track('shop_4', 130, [
    Channel(rep([
      Note(D5, 0.5, Wave.square, 0.7), Note(Fs4, 0.5, Wave.square, 0.7),
      Note(A4, 0.5, Wave.square, 0.7), Note(D5, 0.25, Wave.square, 0.7),
      Note(E5, 0.25, Wave.square, 0.7),
      Note(Fs5, 0.5, Wave.square, 0.7), Note(E5, 0.5, Wave.square, 0.7),
      Note(D5, 0.5, Wave.square, 0.7), Note(A4, 0.5, Wave.square, 0.7),
      Note(B4, 0.5, Wave.square, 0.7), Note(A4, 0.5, Wave.square, 0.7),
      Note(Fs4, 0.5, Wave.square, 0.7), Note(D4, 0.5, Wave.square, 0.7),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.7, release: 0.03)),
    Channel(rep([
      Note(D2, 1.0, Wave.triangle), Note(A2, 0.5, Wave.triangle),
      Note(D3, 0.5, Wave.triangle), Note(G2, 1.0, Wave.triangle),
      Note(A2, 1.0, Wave.triangle), Note(D2, 0.5, Wave.triangle),
      Note(Fs3, 0.5, Wave.triangle),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.8, release: 0.03)),
  ]),
  // Shop 5 — Bb major, 118 BPM
  Track('shop_5', 118, [
    Channel(rep([
      Note(As4, 0.5, Wave.square, 0.7), Note(D5, 0.5, Wave.square, 0.7),
      Note(F5, 0.5, Wave.square, 0.7), Note(D5, 0.25, Wave.square, 0.7),
      Note(As4, 0.25, Wave.square, 0.7),
      Note(C5, 0.5, Wave.square, 0.7), Note(D5, 0.5, Wave.square, 0.7),
      Note(As4, 0.5, Wave.square, 0.7), Note(G4, 0.5, Wave.square, 0.7),
      Note(F4, 0.5, Wave.square, 0.7), Note(G4, 0.5, Wave.square, 0.7),
      Note(As4, 1.0, Wave.square, 0.7),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.7, release: 0.03)),
    Channel(rep([
      Note(As2, 1.0, Wave.triangle), Note(F2, 0.5, Wave.triangle),
      Note(As2, 0.5, Wave.triangle),
      Note(Ds3, 1.0, Wave.triangle), Note(F3, 1.0, Wave.triangle),
      Note(As2, 1.0, Wave.triangle), Note(C3, 1.0, Wave.triangle),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.8, release: 0.03)),
  ]),
];

// ── EXPLORATION (100-120 BPM, adventurous) ───────────────────────────────────
List<Track> explorationTracks() => [
  // Exploration 1 — C major, 110 BPM
  Track('exploration_1', 110, [
    Channel(rep([
      Note(C4, 1.0, Wave.square, 0.65), Note(E4, 0.5, Wave.square, 0.65),
      Note(G4, 0.5, Wave.square, 0.65),
      Note(A4, 1.0, Wave.square, 0.65), Note(G4, 0.5, Wave.square, 0.65),
      Note(E4, 0.5, Wave.square, 0.65),
      Note(F4, 1.0, Wave.square, 0.65), Note(E4, 0.5, Wave.square, 0.65),
      Note(D4, 0.5, Wave.square, 0.65),
      Note(C4, 1.5, Wave.square, 0.65), Note(REST, 0.5, Wave.square),
    ], 4), const Envelope(attack: 0.01, decay: 0.04, sustain: 0.65, release: 0.04)),
    Channel(rep([
      Note(C3, 2.0, Wave.triangle, 0.7), Note(F3, 2.0, Wave.triangle, 0.7),
      Note(G3, 2.0, Wave.triangle, 0.7), Note(C3, 2.0, Wave.triangle, 0.7),
    ], 4), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.8, release: 0.05)),
    Channel(rep([
      Note(REST, 2.0, Wave.noise), Note(300, 0.25, Wave.noise, 0.15),
      Note(REST, 1.75, Wave.noise),
    ], 6), const Envelope(attack: 0.002, decay: 0.01, sustain: 0.3, release: 0.01)),
  ]),
  // Exploration 2 — G mixolydian, 105 BPM
  Track('exploration_2', 105, [
    Channel(rep([
      Note(G4, 0.5, Wave.triangle, 0.7), Note(A4, 0.5, Wave.triangle, 0.7),
      Note(B4, 1.0, Wave.triangle, 0.7),
      Note(D5, 0.5, Wave.triangle, 0.7), Note(C5, 0.5, Wave.triangle, 0.7),
      Note(B4, 0.5, Wave.triangle, 0.7), Note(A4, 0.5, Wave.triangle, 0.7),
      Note(G4, 1.0, Wave.triangle, 0.7), Note(F4, 0.5, Wave.triangle, 0.7),
      Note(G4, 1.5, Wave.triangle, 0.7),
    ], 4), const Envelope(attack: 0.02, decay: 0.04, sustain: 0.7, release: 0.04)),
    Channel(rep([
      Note(G2, 2.0, Wave.triangle, 0.65), Note(C3, 2.0, Wave.triangle, 0.65),
      Note(F3, 2.0, Wave.triangle, 0.65), Note(G2, 1.0, Wave.triangle, 0.65),
      Note(D3, 1.0, Wave.triangle, 0.65),
    ], 4), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.8, release: 0.05)),
  ]),
  // Exploration 3 — D dorian, 115 BPM
  Track('exploration_3', 115, [
    Channel(rep([
      Note(D4, 0.5, Wave.square, 0.6), Note(F4, 0.5, Wave.square, 0.6),
      Note(A4, 0.5, Wave.square, 0.6), Note(G4, 0.5, Wave.square, 0.6),
      Note(B4, 1.0, Wave.square, 0.6),
      Note(A4, 0.5, Wave.square, 0.6), Note(G4, 0.5, Wave.square, 0.6),
      Note(F4, 0.5, Wave.square, 0.6), Note(E4, 0.5, Wave.square, 0.6),
      Note(D4, 1.0, Wave.square, 0.6), Note(REST, 0.5, Wave.square),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.65, release: 0.03)),
    Channel(rep([
      Note(D2, 1.5, Wave.triangle, 0.7), Note(A2, 0.5, Wave.triangle, 0.7),
      Note(G2, 1.5, Wave.triangle, 0.7), Note(D2, 0.5, Wave.triangle, 0.7),
      Note(C3, 1.0, Wave.triangle, 0.7), Note(D3, 1.0, Wave.triangle, 0.7),
    ], 4), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.8, release: 0.05)),
  ]),
  // Exploration 4 — F lydian, 100 BPM
  Track('exploration_4', 100, [
    Channel(rep([
      Note(F4, 1.0, Wave.sine, 0.75), Note(A4, 0.5, Wave.sine, 0.75),
      Note(B4, 0.5, Wave.sine, 0.75),
      Note(C5, 1.0, Wave.sine, 0.75), Note(A4, 1.0, Wave.sine, 0.75),
      Note(G4, 0.5, Wave.sine, 0.75), Note(F4, 0.5, Wave.sine, 0.75),
      Note(E4, 1.0, Wave.sine, 0.75), Note(F4, 1.0, Wave.sine, 0.75),
      Note(REST, 1.0, Wave.sine),
    ], 3), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.7, release: 0.05)),
    Channel(rep([
      Note(F2, 2.0, Wave.triangle, 0.65), Note(C3, 2.0, Wave.triangle, 0.65),
      Note(G2, 2.0, Wave.triangle, 0.65), Note(F2, 2.0, Wave.triangle, 0.65),
    ], 3), const Envelope(attack: 0.03, decay: 0.05, sustain: 0.8, release: 0.05)),
  ]),
  // Exploration 5 — A major, 120 BPM
  Track('exploration_5', 120, [
    Channel(rep([
      Note(A4, 0.5, Wave.square, 0.65), Note(Cs5, 0.5, Wave.square, 0.65),
      Note(E5, 0.5, Wave.square, 0.65), Note(D5, 0.5, Wave.square, 0.65),
      Note(Cs5, 0.5, Wave.square, 0.65), Note(B4, 0.5, Wave.square, 0.65),
      Note(A4, 0.5, Wave.square, 0.65), Note(E4, 0.5, Wave.square, 0.65),
      Note(Fs4, 0.5, Wave.square, 0.65), Note(A4, 0.5, Wave.square, 0.65),
      Note(B4, 0.5, Wave.square, 0.65), Note(Cs5, 0.5, Wave.square, 0.65),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.65, release: 0.03)),
    Channel(rep([
      Note(A2, 1.5, Wave.triangle, 0.7), Note(E3, 0.5, Wave.triangle, 0.7),
      Note(D3, 1.0, Wave.triangle, 0.7), Note(A2, 1.0, Wave.triangle, 0.7),
      Note(E3, 1.0, Wave.triangle, 0.7), Note(A2, 0.5, Wave.triangle, 0.7),
    ], 4), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.8, release: 0.05)),
  ]),
];

// ── REST (70-90 BPM, gentle, calm) ───────────────────────────────────────────
List<Track> restTracks() => [
  // Rest 1 — C major, 80 BPM
  Track('rest_1', 80, [
    Channel(rep([
      Note(C4, 2.0, Wave.sine, 0.5), Note(E4, 2.0, Wave.sine, 0.5),
      Note(G4, 2.0, Wave.sine, 0.5), Note(F4, 2.0, Wave.sine, 0.5),
      Note(E4, 2.0, Wave.sine, 0.5), Note(D4, 2.0, Wave.sine, 0.5),
      Note(C4, 3.0, Wave.sine, 0.5), Note(REST, 1.0, Wave.sine),
    ], 2), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.6, release: 0.1)),
    Channel(rep([
      Note(C3, 4.0, Wave.triangle, 0.4), Note(F3, 4.0, Wave.triangle, 0.4),
      Note(G3, 4.0, Wave.triangle, 0.4), Note(C3, 4.0, Wave.triangle, 0.4),
    ], 2), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.7, release: 0.1)),
  ]),
  // Rest 2 — G major, 75 BPM
  Track('rest_2', 75, [
    Channel(rep([
      Note(G4, 2.0, Wave.sine, 0.5), Note(B4, 2.0, Wave.sine, 0.5),
      Note(D5, 2.0, Wave.sine, 0.45), Note(C5, 2.0, Wave.sine, 0.5),
      Note(B4, 2.0, Wave.sine, 0.5), Note(A4, 2.0, Wave.sine, 0.5),
      Note(G4, 3.0, Wave.sine, 0.5), Note(REST, 1.0, Wave.sine),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.6, release: 0.1)),
    Channel(rep([
      Note(G2, 4.0, Wave.triangle, 0.4), Note(C3, 4.0, Wave.triangle, 0.4),
      Note(D3, 4.0, Wave.triangle, 0.4), Note(G2, 4.0, Wave.triangle, 0.4),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.7, release: 0.1)),
  ]),
  // Rest 3 — F major, 70 BPM
  Track('rest_3', 70, [
    Channel(rep([
      Note(F4, 2.0, Wave.triangle, 0.5), Note(A4, 2.0, Wave.triangle, 0.5),
      Note(C5, 3.0, Wave.triangle, 0.45), Note(REST, 1.0, Wave.triangle),
      Note(As4, 2.0, Wave.triangle, 0.5), Note(A4, 2.0, Wave.triangle, 0.5),
      Note(G4, 2.0, Wave.triangle, 0.5), Note(F4, 3.0, Wave.triangle, 0.5),
      Note(REST, 1.0, Wave.triangle),
    ], 1), const Envelope(attack: 0.06, decay: 0.1, sustain: 0.6, release: 0.1)),
    Channel(rep([
      Note(F2, 4.0, Wave.sine, 0.35), Note(As2, 4.0, Wave.sine, 0.35),
      Note(C3, 4.0, Wave.sine, 0.35), Note(F2, 4.0, Wave.sine, 0.35),
      Note(G2, 2.0, Wave.sine, 0.35), Note(F2, 2.0, Wave.sine, 0.35),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.7, release: 0.1)),
  ]),
  // Rest 4 — D major, 85 BPM
  Track('rest_4', 85, [
    Channel(rep([
      Note(D4, 1.5, Wave.sine, 0.5), Note(Fs4, 1.5, Wave.sine, 0.5),
      Note(A4, 2.0, Wave.sine, 0.45),
      Note(G4, 1.5, Wave.sine, 0.5), Note(Fs4, 1.5, Wave.sine, 0.5),
      Note(E4, 2.0, Wave.sine, 0.5), Note(D4, 2.5, Wave.sine, 0.5),
      Note(REST, 1.0, Wave.sine),
    ], 2), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.6, release: 0.1)),
    Channel(rep([
      Note(D2, 3.0, Wave.triangle, 0.4), Note(G2, 3.0, Wave.triangle, 0.4),
      Note(A2, 3.0, Wave.triangle, 0.4), Note(D2, 3.0, Wave.triangle, 0.4),
      Note(E2, 1.5, Wave.triangle, 0.4), Note(D2, 1.5, Wave.triangle, 0.4),
    ], 2), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.7, release: 0.1)),
  ]),
  // Rest 5 — Eb major, 78 BPM
  Track('rest_5', 78, [
    Channel(rep([
      Note(Ds4, 2.0, Wave.sine, 0.5), Note(G4, 2.0, Wave.sine, 0.5),
      Note(As4, 2.0, Wave.sine, 0.45),
      Note(G4, 2.0, Wave.sine, 0.5), Note(F4, 2.0, Wave.sine, 0.5),
      Note(Ds4, 3.0, Wave.sine, 0.5), Note(REST, 1.0, Wave.sine),
    ], 2), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.6, release: 0.1)),
    Channel(rep([
      Note(Ds3, 4.0, Wave.triangle, 0.4), Note(As2, 4.0, Wave.triangle, 0.4),
      Note(F3, 2.0, Wave.triangle, 0.4), Note(Ds3, 2.0, Wave.triangle, 0.4),
      Note(As2, 2.0, Wave.triangle, 0.4), Note(Ds3, 2.0, Wave.triangle, 0.4),
    ], 2), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.7, release: 0.1)),
  ]),
];

// ── EVENT (90-110 BPM, mysterious, modal) ────────────────────────────────────
List<Track> eventTracks() => [
  // Event 1 — D phrygian, 100 BPM
  Track('event_1', 100, [
    Channel(rep([
      Note(D4, 1.0, Wave.square, 0.6), Note(Ds4, 1.0, Wave.square, 0.6),
      Note(F4, 0.5, Wave.square, 0.6), Note(G4, 0.5, Wave.square, 0.6),
      Note(A4, 1.0, Wave.square, 0.55),
      Note(G4, 0.5, Wave.square, 0.6), Note(F4, 0.5, Wave.square, 0.6),
      Note(Ds4, 1.0, Wave.square, 0.6), Note(D4, 1.5, Wave.square, 0.6),
      Note(REST, 0.5, Wave.square),
    ], 3), const Envelope(attack: 0.02, decay: 0.05, sustain: 0.6, release: 0.05)),
    Channel(rep([
      Note(D2, 2.0, Wave.triangle, 0.55), Note(Ds3, 2.0, Wave.triangle, 0.55),
      Note(A2, 2.0, Wave.triangle, 0.55), Note(D2, 2.0, Wave.triangle, 0.55),
    ], 3), const Envelope(attack: 0.03, decay: 0.05, sustain: 0.7, release: 0.05)),
  ]),
  // Event 2 — A locrian, 95 BPM
  Track('event_2', 95, [
    Channel(rep([
      Note(A3, 1.0, Wave.sine, 0.6), Note(As3, 1.0, Wave.sine, 0.6),
      Note(C4, 0.5, Wave.sine, 0.6), Note(D4, 0.5, Wave.sine, 0.6),
      Note(Ds4, 1.5, Wave.sine, 0.55), Note(REST, 0.5, Wave.sine),
      Note(D4, 1.0, Wave.sine, 0.6), Note(C4, 1.0, Wave.sine, 0.6),
      Note(As3, 0.5, Wave.sine, 0.6), Note(A3, 1.5, Wave.sine, 0.6),
    ], 3), const Envelope(attack: 0.03, decay: 0.05, sustain: 0.6, release: 0.05)),
    Channel(rep([
      Note(A2, 3.0, Wave.triangle, 0.5), Note(Ds3, 3.0, Wave.triangle, 0.5),
      Note(C3, 2.0, Wave.triangle, 0.5), Note(A2, 2.0, Wave.triangle, 0.5),
    ], 3), const Envelope(attack: 0.03, decay: 0.05, sustain: 0.7, release: 0.05)),
  ]),
  // Event 3 — E phrygian, 105 BPM
  Track('event_3', 105, [
    Channel(rep([
      Note(E4, 0.5, Wave.square, 0.55), Note(F4, 0.5, Wave.square, 0.55),
      Note(G4, 1.0, Wave.square, 0.55),
      Note(A4, 0.5, Wave.square, 0.55), Note(G4, 0.5, Wave.square, 0.55),
      Note(F4, 1.0, Wave.square, 0.55),
      Note(E4, 0.5, Wave.square, 0.55), Note(D4, 0.5, Wave.square, 0.55),
      Note(E4, 1.5, Wave.square, 0.55), Note(REST, 0.5, Wave.square),
      Note(B3, 1.0, Wave.square, 0.55), Note(E4, 1.0, Wave.square, 0.55),
    ], 3), const Envelope(attack: 0.02, decay: 0.04, sustain: 0.6, release: 0.04)),
    Channel(rep([
      Note(E2, 2.0, Wave.triangle, 0.55), Note(F2, 2.0, Wave.triangle, 0.55),
      Note(A2, 2.0, Wave.triangle, 0.55), Note(E2, 2.0, Wave.triangle, 0.55),
    ], 3), const Envelope(attack: 0.03, decay: 0.05, sustain: 0.7, release: 0.05)),
  ]),
  // Event 4 — B whole-tone, 90 BPM
  Track('event_4', 90, [
    Channel(rep([
      Note(B3, 1.0, Wave.sine, 0.55), Note(Cs4, 1.0, Wave.sine, 0.55),
      Note(Ds4, 1.0, Wave.sine, 0.55), Note(F4, 1.0, Wave.sine, 0.55),
      Note(G4, 1.5, Wave.sine, 0.5), Note(REST, 0.5, Wave.sine),
      Note(F4, 1.0, Wave.sine, 0.55), Note(Ds4, 1.0, Wave.sine, 0.55),
      Note(Cs4, 0.5, Wave.sine, 0.55), Note(B3, 1.5, Wave.sine, 0.55),
    ], 3), const Envelope(attack: 0.03, decay: 0.06, sustain: 0.6, release: 0.06)),
    Channel(rep([
      Note(B2, 3.0, Wave.triangle, 0.5), Note(F2, 3.0, Wave.triangle, 0.5),
      Note(Ds3, 2.0, Wave.triangle, 0.5), Note(B2, 2.0, Wave.triangle, 0.5),
    ], 3), const Envelope(attack: 0.03, decay: 0.05, sustain: 0.7, release: 0.05)),
  ]),
  // Event 5 — G# diminished, 108 BPM
  Track('event_5', 108, [
    Channel(rep([
      Note(Gs4, 1.0, Wave.square, 0.55), Note(B4, 0.5, Wave.square, 0.55),
      Note(D5, 0.5, Wave.square, 0.55),
      Note(F5, 1.5, Wave.square, 0.5), Note(REST, 0.5, Wave.square),
      Note(D5, 1.0, Wave.square, 0.55), Note(B4, 0.5, Wave.square, 0.55),
      Note(Gs4, 0.5, Wave.square, 0.55),
      Note(F4, 1.0, Wave.square, 0.55), Note(Gs4, 1.5, Wave.square, 0.55),
      Note(REST, 0.5, Wave.square),
    ], 3), const Envelope(attack: 0.02, decay: 0.04, sustain: 0.6, release: 0.04)),
    Channel(rep([
      Note(Gs3, 2.0, Wave.triangle, 0.5), Note(D3, 2.0, Wave.triangle, 0.5),
      Note(F3, 2.0, Wave.triangle, 0.5), Note(Gs3, 2.0, Wave.triangle, 0.5),
    ], 3), const Envelope(attack: 0.03, decay: 0.05, sustain: 0.7, release: 0.05)),
  ]),
];

// ── TITLE THEME (110-130 BPM, heroic, major) ────────────────────────────────
List<Track> titleThemeTracks() => [
  // Title 1 — C major, 120 BPM, heroic
  Track('title_theme_1', 120, [
    Channel(rep([
      Note(C4, 0.5, Wave.square, 0.8), Note(E4, 0.5, Wave.square, 0.8),
      Note(G4, 1.0, Wave.square, 0.8),
      Note(C5, 1.0, Wave.square, 0.85), Note(B4, 0.5, Wave.square, 0.8),
      Note(G4, 0.5, Wave.square, 0.8),
      Note(A4, 1.0, Wave.square, 0.8), Note(G4, 0.5, Wave.square, 0.8),
      Note(F4, 0.5, Wave.square, 0.8),
      Note(E4, 1.0, Wave.square, 0.8), Note(D4, 0.5, Wave.square, 0.8),
      Note(C4, 0.5, Wave.square, 0.8),
    ], 4), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(C3, 1.0, Wave.triangle, 0.75), Note(G3, 1.0, Wave.triangle, 0.75),
      Note(E3, 1.0, Wave.triangle, 0.75), Note(G3, 1.0, Wave.triangle, 0.75),
      Note(F3, 1.0, Wave.triangle, 0.75), Note(C3, 1.0, Wave.triangle, 0.75),
      Note(G3, 1.0, Wave.triangle, 0.75), Note(C3, 1.0, Wave.triangle, 0.75),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
    Channel(rep([
      Note(100, 0.25, Wave.noise, 0.3), Note(REST, 0.75, Wave.noise),
      Note(200, 0.25, Wave.noise, 0.2), Note(REST, 0.25, Wave.noise),
      Note(100, 0.25, Wave.noise, 0.3), Note(REST, 0.25, Wave.noise),
    ], 8), const Envelope(attack: 0.002, decay: 0.01, sustain: 0.4, release: 0.01)),
  ]),
  // Title 2 — D major, 125 BPM
  Track('title_theme_2', 125, [
    Channel(rep([
      Note(D4, 0.5, Wave.square, 0.8), Note(Fs4, 0.5, Wave.square, 0.8),
      Note(A4, 0.5, Wave.square, 0.8), Note(D5, 1.0, Wave.square, 0.85),
      Note(Cs5, 0.5, Wave.square, 0.8),
      Note(B4, 0.5, Wave.square, 0.8), Note(A4, 0.5, Wave.square, 0.8),
      Note(G4, 0.5, Wave.square, 0.8), Note(Fs4, 0.5, Wave.square, 0.8),
      Note(A4, 0.5, Wave.square, 0.8), Note(D5, 0.5, Wave.square, 0.85),
      Note(A4, 0.5, Wave.square, 0.8), Note(D4, 0.5, Wave.square, 0.8),
      Note(REST, 0.5, Wave.square),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(D3, 1.0, Wave.triangle, 0.75), Note(A2, 1.0, Wave.triangle, 0.75),
      Note(G2, 1.0, Wave.triangle, 0.75), Note(A2, 1.0, Wave.triangle, 0.75),
      Note(D3, 1.0, Wave.triangle, 0.75), Note(Fs3, 1.0, Wave.triangle, 0.75),
      Note(A2, 1.0, Wave.triangle, 0.75),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
    Channel(rep([
      Note(100, 0.25, Wave.noise, 0.3), Note(REST, 0.25, Wave.noise),
      Note(200, 0.25, Wave.noise, 0.2), Note(REST, 0.25, Wave.noise),
      Note(100, 0.25, Wave.noise, 0.3), Note(REST, 0.75, Wave.noise),
    ], 6), const Envelope(attack: 0.002, decay: 0.01, sustain: 0.4, release: 0.01)),
  ]),
  // Title 3 — G major, 115 BPM
  Track('title_theme_3', 115, [
    Channel(rep([
      Note(G4, 1.0, Wave.square, 0.8), Note(B4, 0.5, Wave.square, 0.8),
      Note(D5, 0.5, Wave.square, 0.8),
      Note(G5, 1.0, Wave.square, 0.85), Note(Fs5, 0.5, Wave.square, 0.8),
      Note(E5, 0.5, Wave.square, 0.8),
      Note(D5, 1.0, Wave.square, 0.8), Note(C5, 0.5, Wave.square, 0.8),
      Note(B4, 0.5, Wave.square, 0.8),
      Note(A4, 0.5, Wave.square, 0.8), Note(B4, 0.5, Wave.square, 0.8),
      Note(G4, 1.0, Wave.square, 0.8),
    ], 4), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(G2, 2.0, Wave.triangle, 0.75), Note(D3, 2.0, Wave.triangle, 0.75),
      Note(C3, 2.0, Wave.triangle, 0.75), Note(G2, 2.0, Wave.triangle, 0.75),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
  ]),
  // Title 4 — F major, 130 BPM
  Track('title_theme_4', 130, [
    Channel(rep([
      Note(F4, 0.25, Wave.sawtooth, 0.7), Note(A4, 0.25, Wave.sawtooth, 0.7),
      Note(C5, 0.25, Wave.sawtooth, 0.7), Note(F5, 0.25, Wave.sawtooth, 0.7),
      Note(E5, 0.5, Wave.sawtooth, 0.7), Note(C5, 0.5, Wave.sawtooth, 0.7),
      Note(D5, 0.5, Wave.sawtooth, 0.7), Note(C5, 0.5, Wave.sawtooth, 0.7),
      Note(As4, 0.5, Wave.sawtooth, 0.7), Note(A4, 0.5, Wave.sawtooth, 0.7),
      Note(G4, 0.5, Wave.sawtooth, 0.7), Note(F4, 0.5, Wave.sawtooth, 0.7),
      Note(A4, 0.5, Wave.sawtooth, 0.7), Note(C5, 0.5, Wave.sawtooth, 0.7),
    ], 3), const Envelope(attack: 0.005, decay: 0.02, sustain: 0.75, release: 0.02)),
    Channel(rep([
      Note(F2, 1.0, Wave.triangle, 0.75), Note(C3, 1.0, Wave.triangle, 0.75),
      Note(As2, 1.0, Wave.triangle, 0.75), Note(C3, 1.0, Wave.triangle, 0.75),
      Note(F2, 1.0, Wave.triangle, 0.75), Note(G2, 1.0, Wave.triangle, 0.75),
      Note(A2, 1.0, Wave.triangle, 0.75),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
  ]),
  // Title 5 — Bb major, 118 BPM
  Track('title_theme_5', 118, [
    Channel(rep([
      Note(As4, 0.5, Wave.square, 0.8), Note(D5, 0.5, Wave.square, 0.8),
      Note(F5, 1.0, Wave.square, 0.85),
      Note(Ds5, 0.5, Wave.square, 0.8), Note(D5, 0.5, Wave.square, 0.8),
      Note(C5, 0.5, Wave.square, 0.8), Note(As4, 0.5, Wave.square, 0.8),
      Note(C5, 1.0, Wave.square, 0.8), Note(D5, 0.5, Wave.square, 0.8),
      Note(As4, 0.5, Wave.square, 0.8),
      Note(G4, 0.5, Wave.square, 0.8), Note(As4, 1.5, Wave.square, 0.8),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(As2, 2.0, Wave.triangle, 0.75), Note(F3, 2.0, Wave.triangle, 0.75),
      Note(Ds3, 2.0, Wave.triangle, 0.75), Note(As2, 1.0, Wave.triangle, 0.75),
      Note(C3, 1.0, Wave.triangle, 0.75),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
  ]),
];

// ── TREASURE (120-140 BPM, bright, exciting) ─────────────────────────────────
List<Track> treasureTracks() => [
  // Treasure 1 — C major, 130 BPM, sparkling arpeggios
  Track('treasure_1', 130, [
    Channel(rep([
      Note(C5, 0.25, Wave.square, 0.75), Note(E5, 0.25, Wave.square, 0.75),
      Note(G5, 0.25, Wave.square, 0.75), Note(C5, 0.25, Wave.square, 0.75),
      Note(D5, 0.25, Wave.square, 0.75), Note(F5, 0.25, Wave.square, 0.75),
      Note(A5, 0.25, Wave.square, 0.75), Note(F5, 0.25, Wave.square, 0.75),
      Note(E5, 0.25, Wave.square, 0.75), Note(G5, 0.25, Wave.square, 0.75),
      Note(C5, 0.5, Wave.square, 0.75),
      Note(D5, 0.25, Wave.square, 0.75), Note(E5, 0.25, Wave.square, 0.75),
      Note(C5, 0.5, Wave.square, 0.75),
    ], 5), const Envelope(attack: 0.003, decay: 0.02, sustain: 0.75, release: 0.02)),
    Channel(rep([
      Note(C3, 1.0, Wave.triangle, 0.7), Note(G3, 1.0, Wave.triangle, 0.7),
      Note(F3, 1.0, Wave.triangle, 0.7), Note(C3, 0.5, Wave.triangle, 0.7),
      Note(E3, 0.5, Wave.triangle, 0.7),
    ], 5), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.8, release: 0.03)),
  ]),
  // Treasure 2 — G major, 135 BPM
  Track('treasure_2', 135, [
    Channel(rep([
      Note(G4, 0.25, Wave.square, 0.75), Note(B4, 0.25, Wave.square, 0.75),
      Note(D5, 0.25, Wave.square, 0.75), Note(G5, 0.5, Wave.square, 0.75),
      Note(D5, 0.25, Wave.square, 0.75),
      Note(B4, 0.25, Wave.square, 0.75), Note(A4, 0.25, Wave.square, 0.75),
      Note(B4, 0.5, Wave.square, 0.75), Note(D5, 0.25, Wave.square, 0.75),
      Note(G5, 0.5, Wave.square, 0.75), Note(Fs5, 0.25, Wave.square, 0.75),
      Note(G5, 0.5, Wave.square, 0.75), Note(REST, 0.25, Wave.square),
    ], 4), const Envelope(attack: 0.003, decay: 0.02, sustain: 0.75, release: 0.02)),
    Channel(rep([
      Note(G2, 1.0, Wave.triangle, 0.7), Note(D3, 0.5, Wave.triangle, 0.7),
      Note(B2, 0.5, Wave.triangle, 0.7),
      Note(C3, 1.0, Wave.triangle, 0.7), Note(G2, 1.0, Wave.triangle, 0.7),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.8, release: 0.03)),
  ]),
  // Treasure 3 — D major, 125 BPM
  Track('treasure_3', 125, [
    Channel(rep([
      Note(D5, 0.25, Wave.sine, 0.8), Note(Fs5, 0.25, Wave.sine, 0.8),
      Note(A5, 0.5, Wave.sine, 0.8),
      Note(Fs5, 0.25, Wave.sine, 0.8), Note(D5, 0.25, Wave.sine, 0.8),
      Note(A4, 0.25, Wave.sine, 0.8), Note(D5, 0.25, Wave.sine, 0.8),
      Note(E5, 0.5, Wave.sine, 0.8), Note(Fs5, 0.5, Wave.sine, 0.8),
      Note(D5, 0.5, Wave.sine, 0.8), Note(A4, 0.5, Wave.sine, 0.8),
      Note(D5, 0.5, Wave.sine, 0.8), Note(REST, 0.5, Wave.sine),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.7, release: 0.03)),
    Channel(rep([
      Note(D3, 1.0, Wave.triangle, 0.7), Note(A2, 1.0, Wave.triangle, 0.7),
      Note(G2, 0.5, Wave.triangle, 0.7), Note(A2, 0.5, Wave.triangle, 0.7),
      Note(D3, 1.0, Wave.triangle, 0.7), Note(Fs3, 1.0, Wave.triangle, 0.7),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.8, release: 0.03)),
  ]),
  // Treasure 4 — F major, 140 BPM
  Track('treasure_4', 140, [
    Channel(rep([
      Note(F5, 0.25, Wave.square, 0.75), Note(A5, 0.25, Wave.square, 0.75),
      Note(C5, 0.5, Wave.square, 0.75),
      Note(F5, 0.25, Wave.square, 0.75), Note(E5, 0.25, Wave.square, 0.75),
      Note(D5, 0.25, Wave.square, 0.75), Note(C5, 0.25, Wave.square, 0.75),
      Note(As4, 0.5, Wave.square, 0.75), Note(C5, 0.5, Wave.square, 0.75),
      Note(F5, 0.5, Wave.square, 0.75), Note(E5, 0.25, Wave.square, 0.75),
      Note(F5, 0.75, Wave.square, 0.75),
    ], 4), const Envelope(attack: 0.003, decay: 0.02, sustain: 0.75, release: 0.02)),
    Channel(rep([
      Note(F2, 1.0, Wave.triangle, 0.7), Note(C3, 0.5, Wave.triangle, 0.7),
      Note(A2, 0.5, Wave.triangle, 0.7),
      Note(As2, 1.0, Wave.triangle, 0.7), Note(F2, 1.0, Wave.triangle, 0.7),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.8, release: 0.03)),
  ]),
  // Treasure 5 — A major, 128 BPM
  Track('treasure_5', 128, [
    Channel(rep([
      Note(A4, 0.25, Wave.square, 0.75), Note(Cs5, 0.25, Wave.square, 0.75),
      Note(E5, 0.25, Wave.square, 0.75), Note(A5, 0.5, Wave.square, 0.75),
      Note(E5, 0.25, Wave.square, 0.75),
      Note(Cs5, 0.25, Wave.square, 0.75), Note(B4, 0.25, Wave.square, 0.75),
      Note(Cs5, 0.5, Wave.square, 0.75), Note(E5, 0.5, Wave.square, 0.75),
      Note(A5, 0.5, Wave.square, 0.75), Note(Gs5, 0.25, Wave.square, 0.75),
      Note(A5, 0.5, Wave.square, 0.75), Note(REST, 0.25, Wave.square),
    ], 4), const Envelope(attack: 0.003, decay: 0.02, sustain: 0.75, release: 0.02)),
    Channel(rep([
      Note(A2, 1.0, Wave.triangle, 0.7), Note(E3, 0.5, Wave.triangle, 0.7),
      Note(Cs3, 0.5, Wave.triangle, 0.7),
      Note(D3, 1.0, Wave.triangle, 0.7), Note(A2, 1.0, Wave.triangle, 0.7),
    ], 4), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.8, release: 0.03)),
  ]),
];

// ── VICTORY (120-130 BPM, triumphant, fanfare) ──────────────────────────────
List<Track> victoryTracks() => [
  // Victory 1 — C major, 125 BPM
  Track('victory_1', 125, [
    Channel(rep([
      Note(C5, 0.5, Wave.square, 0.85), Note(E5, 0.5, Wave.square, 0.85),
      Note(G5, 1.0, Wave.square, 0.9),
      Note(G5, 0.5, Wave.square, 0.85), Note(A5, 0.5, Wave.square, 0.85),
      Note(G5, 0.5, Wave.square, 0.85), Note(E5, 0.5, Wave.square, 0.85),
      Note(C5, 1.0, Wave.square, 0.9),
      Note(D5, 0.5, Wave.square, 0.85), Note(E5, 0.5, Wave.square, 0.85),
      Note(F5, 0.5, Wave.square, 0.85), Note(E5, 0.5, Wave.square, 0.85),
      Note(C5, 1.0, Wave.square, 0.9),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(C3, 1.0, Wave.triangle, 0.8), Note(E3, 1.0, Wave.triangle, 0.8),
      Note(G3, 1.0, Wave.triangle, 0.8), Note(C3, 1.0, Wave.triangle, 0.8),
      Note(F3, 1.0, Wave.triangle, 0.8), Note(G3, 1.0, Wave.triangle, 0.8),
      Note(C3, 1.0, Wave.triangle, 0.8), Note(G3, 1.0, Wave.triangle, 0.8),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
    Channel(rep([
      Note(100, 0.25, Wave.noise, 0.35), Note(REST, 0.25, Wave.noise),
      Note(200, 0.25, Wave.noise, 0.25), Note(REST, 0.25, Wave.noise),
      Note(100, 0.25, Wave.noise, 0.35), Note(200, 0.125, Wave.noise, 0.25),
      Note(REST, 0.375, Wave.noise),
    ], 7), const Envelope(attack: 0.002, decay: 0.01, sustain: 0.4, release: 0.01)),
  ]),
  // Victory 2 — G major, 128 BPM
  Track('victory_2', 128, [
    Channel(rep([
      Note(G4, 0.5, Wave.square, 0.85), Note(B4, 0.5, Wave.square, 0.85),
      Note(D5, 0.5, Wave.square, 0.85), Note(G5, 1.0, Wave.square, 0.9),
      Note(Fs5, 0.5, Wave.square, 0.85),
      Note(E5, 0.5, Wave.square, 0.85), Note(D5, 0.5, Wave.square, 0.85),
      Note(C5, 0.5, Wave.square, 0.85), Note(B4, 0.5, Wave.square, 0.85),
      Note(D5, 0.5, Wave.square, 0.85), Note(G5, 1.0, Wave.square, 0.9),
      Note(REST, 0.5, Wave.square),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(G2, 1.0, Wave.triangle, 0.8), Note(B2, 1.0, Wave.triangle, 0.8),
      Note(D3, 1.0, Wave.triangle, 0.8), Note(G2, 1.0, Wave.triangle, 0.8),
      Note(C3, 1.0, Wave.triangle, 0.8), Note(D3, 1.0, Wave.triangle, 0.8),
      Note(G2, 1.0, Wave.triangle, 0.8),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
  ]),
  // Victory 3 — D major, 122 BPM
  Track('victory_3', 122, [
    Channel(rep([
      Note(D5, 1.0, Wave.sawtooth, 0.7), Note(Fs5, 0.5, Wave.sawtooth, 0.7),
      Note(A5, 0.5, Wave.sawtooth, 0.7),
      Note(A5, 0.5, Wave.sawtooth, 0.7), Note(G5, 0.5, Wave.sawtooth, 0.7),
      Note(Fs5, 0.5, Wave.sawtooth, 0.7), Note(E5, 0.5, Wave.sawtooth, 0.7),
      Note(D5, 1.0, Wave.sawtooth, 0.7), Note(A4, 0.5, Wave.sawtooth, 0.7),
      Note(D5, 0.5, Wave.sawtooth, 0.7),
      Note(Fs5, 1.0, Wave.sawtooth, 0.75), Note(REST, 0.5, Wave.sawtooth),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.75, release: 0.03)),
    Channel(rep([
      Note(D3, 1.0, Wave.triangle, 0.8), Note(A2, 1.0, Wave.triangle, 0.8),
      Note(D3, 1.0, Wave.triangle, 0.8), Note(G2, 1.0, Wave.triangle, 0.8),
      Note(A2, 1.0, Wave.triangle, 0.8), Note(D3, 1.0, Wave.triangle, 0.8),
      Note(A2, 1.0, Wave.triangle, 0.8),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
  ]),
  // Victory 4 — F major, 120 BPM
  Track('victory_4', 120, [
    Channel(rep([
      Note(F4, 0.5, Wave.square, 0.85), Note(A4, 0.5, Wave.square, 0.85),
      Note(C5, 1.0, Wave.square, 0.9),
      Note(F5, 1.0, Wave.square, 0.9), Note(E5, 0.5, Wave.square, 0.85),
      Note(C5, 0.5, Wave.square, 0.85),
      Note(D5, 0.5, Wave.square, 0.85), Note(C5, 0.5, Wave.square, 0.85),
      Note(As4, 0.5, Wave.square, 0.85), Note(A4, 0.5, Wave.square, 0.85),
      Note(C5, 0.5, Wave.square, 0.85), Note(F5, 1.0, Wave.square, 0.9),
      Note(REST, 0.5, Wave.square),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(F2, 1.0, Wave.triangle, 0.8), Note(A2, 1.0, Wave.triangle, 0.8),
      Note(C3, 1.0, Wave.triangle, 0.8), Note(F2, 1.0, Wave.triangle, 0.8),
      Note(As2, 1.0, Wave.triangle, 0.8), Note(C3, 1.0, Wave.triangle, 0.8),
      Note(F2, 1.0, Wave.triangle, 0.8),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
  ]),
  // Victory 5 — Bb major, 130 BPM
  Track('victory_5', 130, [
    Channel(rep([
      Note(As4, 0.5, Wave.square, 0.85), Note(D5, 0.5, Wave.square, 0.85),
      Note(F5, 1.0, Wave.square, 0.9),
      Note(G5, 0.5, Wave.square, 0.85), Note(F5, 0.5, Wave.square, 0.85),
      Note(Ds5, 0.5, Wave.square, 0.85), Note(D5, 0.5, Wave.square, 0.85),
      Note(C5, 0.5, Wave.square, 0.85), Note(As4, 0.5, Wave.square, 0.85),
      Note(D5, 0.5, Wave.square, 0.85), Note(F5, 0.5, Wave.square, 0.85),
      Note(As5, 1.0, Wave.square, 0.9), Note(REST, 0.5, Wave.square),
    ], 3), const Envelope(attack: 0.005, decay: 0.03, sustain: 0.8, release: 0.03)),
    Channel(rep([
      Note(As2, 1.0, Wave.triangle, 0.8), Note(D3, 1.0, Wave.triangle, 0.8),
      Note(F3, 1.0, Wave.triangle, 0.8), Note(As2, 1.0, Wave.triangle, 0.8),
      Note(Ds3, 1.0, Wave.triangle, 0.8), Note(F3, 1.0, Wave.triangle, 0.8),
      Note(As2, 1.0, Wave.triangle, 0.8),
    ], 3), const Envelope(attack: 0.01, decay: 0.03, sustain: 0.85, release: 0.03)),
  ]),
];

// ── GAME OVER (60-80 BPM, somber, minor) ─────────────────────────────────────
List<Track> gameOverTracks() => [
  // Game Over 1 — Am, 70 BPM
  Track('game_over_1', 70, [
    Channel(rep([
      Note(A4, 2.0, Wave.sine, 0.6), Note(G4, 2.0, Wave.sine, 0.6),
      Note(F4, 2.0, Wave.sine, 0.55), Note(E4, 3.0, Wave.sine, 0.55),
      Note(REST, 1.0, Wave.sine),
      Note(D4, 2.0, Wave.sine, 0.55), Note(C4, 2.0, Wave.sine, 0.5),
      Note(A3, 3.0, Wave.sine, 0.5), Note(REST, 1.0, Wave.sine),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.5, release: 0.15)),
    Channel(rep([
      Note(A2, 4.0, Wave.triangle, 0.45), Note(F2, 4.0, Wave.triangle, 0.45),
      Note(E2, 4.0, Wave.triangle, 0.45), Note(A2, 4.0, Wave.triangle, 0.45),
      Note(D2, 2.0, Wave.triangle, 0.45), Note(A2, 2.0, Wave.triangle, 0.45),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.6, release: 0.1)),
  ]),
  // Game Over 2 — Em, 65 BPM
  Track('game_over_2', 65, [
    Channel(rep([
      Note(E4, 2.0, Wave.triangle, 0.55), Note(D4, 2.0, Wave.triangle, 0.55),
      Note(C4, 2.0, Wave.triangle, 0.5),
      Note(B3, 3.0, Wave.triangle, 0.5), Note(REST, 1.0, Wave.triangle),
      Note(A3, 2.0, Wave.triangle, 0.5), Note(G3, 2.0, Wave.triangle, 0.5),
      Note(E3, 3.0, Wave.triangle, 0.45), Note(REST, 1.0, Wave.triangle),
    ], 1), const Envelope(attack: 0.06, decay: 0.1, sustain: 0.5, release: 0.15)),
    Channel(rep([
      Note(E2, 4.0, Wave.sine, 0.4), Note(C2, 4.0, Wave.sine, 0.4),
      Note(A2, 4.0, Wave.sine, 0.4), Note(E2, 4.0, Wave.sine, 0.4),
      Note(G2, 2.0, Wave.sine, 0.4), Note(E2, 2.0, Wave.sine, 0.4),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.6, release: 0.1)),
  ]),
  // Game Over 3 — Dm, 75 BPM
  Track('game_over_3', 75, [
    Channel(rep([
      Note(D4, 1.5, Wave.sine, 0.55), Note(F4, 1.5, Wave.sine, 0.55),
      Note(E4, 2.0, Wave.sine, 0.5),
      Note(D4, 1.5, Wave.sine, 0.55), Note(C4, 1.5, Wave.sine, 0.5),
      Note(A3, 3.0, Wave.sine, 0.5), Note(REST, 1.0, Wave.sine),
      Note(G3, 2.0, Wave.sine, 0.5), Note(F3, 2.0, Wave.sine, 0.45),
      Note(D3, 2.0, Wave.sine, 0.45), Note(REST, 1.0, Wave.sine),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.5, release: 0.15)),
    Channel(rep([
      Note(D2, 3.0, Wave.triangle, 0.45), Note(F2, 3.0, Wave.triangle, 0.45),
      Note(A2, 3.0, Wave.triangle, 0.45), Note(D2, 3.0, Wave.triangle, 0.45),
      Note(G2, 3.0, Wave.triangle, 0.45), Note(D2, 3.0, Wave.triangle, 0.45),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.6, release: 0.1)),
  ]),
  // Game Over 4 — Cm, 60 BPM
  Track('game_over_4', 60, [
    Channel(rep([
      Note(C4, 2.0, Wave.sine, 0.55), Note(Ds4, 2.0, Wave.sine, 0.55),
      Note(G4, 3.0, Wave.sine, 0.5), Note(REST, 1.0, Wave.sine),
      Note(F4, 2.0, Wave.sine, 0.5), Note(Ds4, 2.0, Wave.sine, 0.5),
      Note(C4, 3.0, Wave.sine, 0.5), Note(REST, 1.0, Wave.sine),
      Note(As3, 2.0, Wave.sine, 0.45), Note(G3, 2.0, Wave.sine, 0.45),
      Note(C3, 3.0, Wave.sine, 0.4), Note(REST, 1.0, Wave.sine),
    ], 1), const Envelope(attack: 0.06, decay: 0.12, sustain: 0.5, release: 0.2)),
    Channel(rep([
      Note(C2, 4.0, Wave.triangle, 0.4), Note(Ds3, 4.0, Wave.triangle, 0.4),
      Note(G2, 4.0, Wave.triangle, 0.4), Note(C2, 4.0, Wave.triangle, 0.4),
      Note(As2, 4.0, Wave.triangle, 0.4), Note(C2, 4.0, Wave.triangle, 0.4),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.6, release: 0.1)),
  ]),
  // Game Over 5 — Gm, 68 BPM
  Track('game_over_5', 68, [
    Channel(rep([
      Note(G4, 2.0, Wave.sine, 0.55), Note(F4, 2.0, Wave.sine, 0.55),
      Note(Ds4, 2.0, Wave.sine, 0.5),
      Note(D4, 3.0, Wave.sine, 0.5), Note(REST, 1.0, Wave.sine),
      Note(C4, 2.0, Wave.sine, 0.5), Note(As3, 2.0, Wave.sine, 0.5),
      Note(G3, 3.0, Wave.sine, 0.45), Note(REST, 1.0, Wave.sine),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.5, release: 0.15)),
    Channel(rep([
      Note(G2, 4.0, Wave.triangle, 0.45), Note(Ds3, 4.0, Wave.triangle, 0.45),
      Note(D3, 4.0, Wave.triangle, 0.45), Note(G2, 4.0, Wave.triangle, 0.45),
      Note(C3, 2.0, Wave.triangle, 0.45), Note(G2, 2.0, Wave.triangle, 0.45),
    ], 1), const Envelope(attack: 0.05, decay: 0.1, sustain: 0.6, release: 0.1)),
  ]),
];

// ══════════════════════════════════════════════════════════════════════════════
// MAIN
// ══════════════════════════════════════════════════════════════════════════════
void main() {
  final outDir = Directory('assets/audio/music');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final allCategories = <String, List<Track>>{
    'battle': battleTracks(),
    'boss_battle': bossBattleTracks(),
    'shop': shopTracks(),
    'exploration': explorationTracks(),
    'rest': restTracks(),
    'event': eventTracks(),
    'title_theme': titleThemeTracks(),
    'treasure': treasureTracks(),
    'victory': victoryTracks(),
    'game_over': gameOverTracks(),
  };

  int totalFiles = 0;
  for (final entry in allCategories.entries) {
    final category = entry.key;
    final tracks = entry.value;
    for (int i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      final pcm = renderTrack(track);
      final variantPath = '${outDir.path}/${category}_${i + 1}.wav';
      writeWav(variantPath, pcm);
      final sizeKB = File(variantPath).lengthSync() / 1024;
      print('  ${track.name}.wav  (${sizeKB.toStringAsFixed(0)} KB)');

      // Copy variant 1 to the base filename
      if (i == 0) {
        final basePath = '${outDir.path}/$category.wav';
        File(variantPath).copySync(basePath);
        print('  -> copied to $category.wav');
      }
      totalFiles++;
    }
  }
  print('\nDone! Generated $totalFiles variant files + 10 base files.');
}
