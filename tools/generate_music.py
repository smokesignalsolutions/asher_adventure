#!/usr/bin/env python3
"""
Generate 8-bit style chiptune music and SFX for Asher's Adventure.
Uses only Python standard library (struct, wave, math, random).
Produces WAV files: 8-bit unsigned, mono, 22050 Hz sample rate.
"""

import struct
import wave
import math
import random
import os

SAMPLE_RATE = 22050
MAX_VAL = 255  # 8-bit unsigned

# --- Waveform generators ---

def square_wave(freq, t, duty=0.5):
    """Square wave: bright, classic chiptune sound."""
    if freq == 0:
        return 0.0
    phase = (t * freq) % 1.0
    return 1.0 if phase < duty else -1.0

def triangle_wave(freq, t):
    """Triangle wave: softer, bass-friendly."""
    if freq == 0:
        return 0.0
    phase = (t * freq) % 1.0
    return 4.0 * abs(phase - 0.5) - 1.0

def sawtooth_wave(freq, t):
    """Sawtooth wave: buzzy, aggressive."""
    if freq == 0:
        return 0.0
    phase = (t * freq) % 1.0
    return 2.0 * phase - 1.0

def noise(t):
    """Pseudo-random noise for percussion."""
    return random.uniform(-1.0, 1.0)

def sine_wave(freq, t):
    """Sine wave: pure tone."""
    if freq == 0:
        return 0.0
    return math.sin(2.0 * math.pi * freq * t)

# --- Note frequencies (A4 = 440 Hz) ---

NOTE_FREQS = {}
NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
for octave in range(0, 9):
    for i, name in enumerate(NOTE_NAMES):
        midi = (octave + 1) * 12 + i
        NOTE_FREQS[f"{name}{octave}"] = 440.0 * (2.0 ** ((midi - 69) / 12.0))
NOTE_FREQS['REST'] = 0.0

def note(name):
    """Get frequency for a note name like 'C4', 'A#3', 'REST'."""
    return NOTE_FREQS.get(name, 0.0)

# --- Envelope ---

def adsr_envelope(t, duration, attack=0.02, decay=0.05, sustain_level=0.7, release=0.05):
    """ADSR envelope for shaping volume over time."""
    release_start = duration - release
    if t < attack:
        return t / attack
    elif t < attack + decay:
        return 1.0 - (1.0 - sustain_level) * ((t - attack) / decay)
    elif t < release_start:
        return sustain_level
    elif t < duration:
        return sustain_level * (1.0 - (t - release_start) / release)
    return 0.0

# --- Rendering ---

def render_samples(duration, channels_func):
    """
    Render audio samples.
    channels_func(t) should return a float in [-1, 1].
    """
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = channels_func(t)
        val = max(-1.0, min(1.0, val))
        # Convert to 8-bit unsigned
        byte_val = int((val + 1.0) * 0.5 * MAX_VAL)
        byte_val = max(0, min(MAX_VAL, byte_val))
        samples.append(byte_val)
    return samples

def write_wav(filename, samples):
    """Write samples to a WAV file (8-bit unsigned mono)."""
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(1)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(bytes(samples))
    print(f"  Written: {filename} ({len(samples)} samples, {len(samples)/SAMPLE_RATE:.1f}s)")

# --- Pattern sequencer ---

def sequence_notes(pattern, bpm, waveform_func, volume=0.3, duty=None, attack=0.01, decay=0.03, sustain=0.7, release=0.03):
    """
    Generate audio from a note pattern.
    pattern: list of (note_name, beats) tuples
    Returns a function that takes t and returns sample value.
    """
    beat_dur = 60.0 / bpm
    events = []
    current_time = 0.0
    for note_name, beats in pattern:
        dur = beats * beat_dur
        freq = note(note_name)
        events.append((current_time, dur, freq))
        current_time += dur
    total_duration = current_time

    def gen(t):
        for start, dur, freq in events:
            if start <= t < start + dur:
                local_t = t - start
                env = adsr_envelope(local_t, dur, attack, decay, sustain, release)
                if duty is not None:
                    val = square_wave(freq, t, duty)
                else:
                    val = waveform_func(freq, t)
                return val * env * volume
        return 0.0

    return gen, total_duration

def mix(*generators):
    """Mix multiple audio generator functions."""
    def gen(t):
        return sum(g(t) for g in generators)
    return gen

# --- Drum patterns ---

def drum_pattern(pattern, bpm, volume=0.15):
    """
    pattern: list of (drum_type, beats) where drum_type is 'kick', 'snare', 'hat', 'rest'
    """
    beat_dur = 60.0 / bpm
    events = []
    current_time = 0.0
    for drum_type, beats in pattern:
        dur = beats * beat_dur
        events.append((current_time, dur, drum_type))
        current_time += dur

    def gen(t):
        for start, dur, dtype in events:
            if start <= t < start + dur:
                local_t = t - start
                if dtype == 'kick':
                    freq = 80.0 * math.exp(-local_t * 30)
                    env = math.exp(-local_t * 15)
                    return sine_wave(freq, t) * env * volume * 1.5
                elif dtype == 'snare':
                    env = math.exp(-local_t * 20)
                    return noise(t) * env * volume
                elif dtype == 'hat':
                    env = math.exp(-local_t * 40)
                    return noise(t) * env * volume * 0.5
                elif dtype == 'rest':
                    return 0.0
        return 0.0

    return gen, current_time

# --- Arpeggio helper ---

def arpeggio(notes_list, bpm, speed=4, waveform_func=square_wave, volume=0.2, duty=0.25):
    """Quick arpeggio over a list of note names, cycling."""
    beat_dur = 60.0 / bpm
    arp_dur = beat_dur / speed
    total_beats = len(notes_list)
    total_dur = total_beats * arp_dur

    def gen(t):
        idx = int(t / arp_dur) % len(notes_list)
        freq = note(notes_list[idx])
        local_t = t % arp_dur
        env = adsr_envelope(local_t, arp_dur, 0.005, 0.02, 0.6, 0.01)
        if duty is not None:
            val = square_wave(freq, t, duty)
        else:
            val = waveform_func(freq, t)
        return val * env * volume

    return gen, total_dur

# ============================================================
# TRACK COMPOSITIONS
# ============================================================

def generate_title_theme():
    """Majestic, inviting fantasy fanfare for the title screen."""
    bpm = 120

    # Main melody - heroic fanfare
    melody_pattern = [
        ('C4', 1), ('E4', 1), ('G4', 1), ('C5', 2),
        ('B4', 0.5), ('A4', 0.5), ('G4', 1), ('E4', 1), ('G4', 2),
        ('A4', 1), ('G4', 0.5), ('F4', 0.5), ('E4', 1), ('D4', 1), ('C4', 2),
        ('C4', 1), ('E4', 1), ('G4', 1), ('C5', 2),
        ('D5', 1), ('C5', 0.5), ('B4', 0.5), ('A4', 1), ('B4', 1), ('C5', 2),
        ('G4', 1), ('A4', 1), ('B4', 1), ('C5', 3),
    ]
    melody, dur1 = sequence_notes(melody_pattern, bpm, square_wave, volume=0.25, duty=0.5,
                                   attack=0.02, decay=0.05, sustain=0.6, release=0.05)

    # Counter melody - triangle wave harmony
    counter_pattern = [
        ('E3', 2), ('G3', 2), ('C4', 2), ('E4', 2),
        ('F3', 2), ('A3', 2), ('C4', 2), ('E4', 1), ('D4', 1),
        ('E3', 2), ('G3', 2), ('C4', 2), ('E4', 2),
        ('D3', 2), ('F3', 2), ('G3', 2), ('C4', 2),
        ('E3', 2), ('G3', 2), ('B3', 2), ('C4', 2),
    ]
    counter, dur2 = sequence_notes(counter_pattern, bpm, triangle_wave, volume=0.18,
                                    attack=0.03, decay=0.05, sustain=0.5, release=0.05)

    # Bass line
    bass_pattern = [
        ('C2', 2), ('C2', 2), ('E2', 2), ('G2', 2),
        ('F2', 2), ('F2', 2), ('A2', 2), ('G2', 2),
        ('C2', 2), ('C2', 2), ('E2', 2), ('G2', 2),
        ('G2', 2), ('G2', 2), ('G2', 2), ('C2', 2),
        ('C2', 2), ('D2', 2), ('G2', 2), ('C2', 2),
    ]
    bass, dur3 = sequence_notes(bass_pattern, bpm, triangle_wave, volume=0.22,
                                 attack=0.01, decay=0.02, sustain=0.8, release=0.02)

    # Drums
    drum_pat = [
        ('kick', 1), ('hat', 0.5), ('hat', 0.5), ('snare', 1), ('hat', 0.5), ('hat', 0.5),
    ] * 10
    drums, dur4 = drum_pattern(drum_pat, bpm, volume=0.12)

    total = max(dur1, dur2, dur3, dur4)
    samples = render_samples(total, mix(melody, counter, bass, drums))
    return samples

def generate_exploration():
    """Upbeat, adventurous map exploration theme."""
    bpm = 130

    melody_pattern = [
        ('G4', 0.5), ('A4', 0.5), ('B4', 1), ('D5', 1), ('B4', 0.5), ('A4', 0.5),
        ('G4', 1), ('E4', 1), ('D4', 0.5), ('E4', 0.5), ('G4', 2),
        ('A4', 0.5), ('B4', 0.5), ('C5', 1), ('E5', 1), ('C5', 0.5), ('B4', 0.5),
        ('A4', 1), ('G4', 1), ('A4', 0.5), ('B4', 0.5), ('G4', 2),
        ('E4', 0.5), ('G4', 0.5), ('A4', 1), ('B4', 1), ('A4', 0.5), ('G4', 0.5),
        ('E4', 1), ('D4', 1), ('E4', 0.5), ('G4', 0.5), ('A4', 2),
        ('B4', 0.5), ('A4', 0.5), ('G4', 1), ('E4', 1), ('D4', 1),
        ('E4', 0.5), ('G4', 0.5), ('A4', 0.5), ('B4', 0.5), ('G4', 2),
    ]
    melody, dur1 = sequence_notes(melody_pattern, bpm, square_wave, volume=0.22, duty=0.25,
                                   attack=0.01, decay=0.03, sustain=0.6, release=0.03)

    # Bouncy bass
    bass_pattern = [
        ('G2', 0.5), ('REST', 0.5), ('G3', 0.5), ('REST', 0.5),
        ('D2', 0.5), ('REST', 0.5), ('D3', 0.5), ('REST', 0.5),
        ('C2', 0.5), ('REST', 0.5), ('C3', 0.5), ('REST', 0.5),
        ('D2', 0.5), ('REST', 0.5), ('D3', 0.5), ('REST', 0.5),
    ] * 4
    bass, dur2 = sequence_notes(bass_pattern, bpm, triangle_wave, volume=0.2,
                                 attack=0.01, decay=0.02, sustain=0.7, release=0.01)

    # Harmony arpeggios
    harmony_pattern = [
        ('G3', 0.25), ('B3', 0.25), ('D4', 0.25), ('B3', 0.25),
        ('G3', 0.25), ('B3', 0.25), ('D4', 0.25), ('B3', 0.25),
        ('C3', 0.25), ('E3', 0.25), ('G3', 0.25), ('E3', 0.25),
        ('D3', 0.25), ('F#3', 0.25), ('A3', 0.25), ('F#3', 0.25),
    ] * 4
    harmony, dur3 = sequence_notes(harmony_pattern, bpm, square_wave, volume=0.12, duty=0.125,
                                    attack=0.005, decay=0.02, sustain=0.4, release=0.01)

    drums_pat = [
        ('kick', 0.5), ('hat', 0.5), ('snare', 0.5), ('hat', 0.5),
    ] * 12
    drums, dur4 = drum_pattern(drums_pat, bpm, volume=0.1)

    total = max(dur1, dur2, dur3, dur4)
    samples = render_samples(total, mix(melody, bass, harmony, drums))
    return samples

def generate_battle():
    """Energetic, fun, heroic battle theme."""
    bpm = 150

    melody_pattern = [
        ('E4', 0.5), ('E4', 0.25), ('E4', 0.25), ('G4', 0.5), ('A4', 0.5),
        ('G4', 0.5), ('E4', 0.5), ('D4', 0.5), ('E4', 0.5),
        ('A4', 0.5), ('A4', 0.25), ('A4', 0.25), ('B4', 0.5), ('C5', 0.5),
        ('B4', 0.5), ('A4', 0.5), ('G4', 0.5), ('A4', 0.5),
        ('E5', 0.5), ('D5', 0.5), ('C5', 0.5), ('B4', 0.5),
        ('A4', 0.5), ('G4', 0.5), ('A4', 0.5), ('B4', 0.5),
        ('C5', 0.5), ('B4', 0.5), ('A4', 0.5), ('G4', 0.5),
        ('E4', 1), ('REST', 0.5), ('E4', 0.5),
    ]
    melody, dur1 = sequence_notes(melody_pattern, bpm, square_wave, volume=0.25, duty=0.5,
                                   attack=0.005, decay=0.03, sustain=0.7, release=0.02)

    # Driving bass
    bass_pattern = [
        ('A2', 0.25), ('A2', 0.25), ('REST', 0.25), ('A2', 0.25),
        ('A2', 0.25), ('A2', 0.25), ('REST', 0.25), ('A2', 0.25),
        ('C3', 0.25), ('C3', 0.25), ('REST', 0.25), ('C3', 0.25),
        ('D3', 0.25), ('D3', 0.25), ('REST', 0.25), ('D3', 0.25),
        ('A2', 0.25), ('A2', 0.25), ('REST', 0.25), ('A2', 0.25),
        ('E2', 0.25), ('E2', 0.25), ('REST', 0.25), ('E2', 0.25),
        ('F2', 0.25), ('F2', 0.25), ('REST', 0.25), ('F2', 0.25),
        ('G2', 0.25), ('G2', 0.25), ('REST', 0.25), ('E2', 0.25),
    ] * 2
    bass, dur2 = sequence_notes(bass_pattern, bpm, sawtooth_wave, volume=0.18,
                                 attack=0.005, decay=0.02, sustain=0.6, release=0.01)

    # Power chords / harmony
    power_pattern = [
        ('A3', 1), ('A3', 1), ('C4', 1), ('D4', 1),
        ('A3', 1), ('E3', 1), ('F3', 1), ('G3', 1),
    ] * 2
    power, dur3 = sequence_notes(power_pattern, bpm, square_wave, volume=0.12, duty=0.25,
                                  attack=0.01, decay=0.05, sustain=0.5, release=0.03)

    drums_pat = [
        ('kick', 0.25), ('hat', 0.25), ('kick', 0.25), ('hat', 0.25),
        ('snare', 0.25), ('hat', 0.25), ('kick', 0.25), ('hat', 0.25),
    ] * 8
    drums, dur4 = drum_pattern(drums_pat, bpm, volume=0.12)

    total = max(dur1, dur2, dur3, dur4)
    samples = render_samples(total, mix(melody, bass, power, drums))
    return samples

def generate_boss_battle():
    """Intense, fast, driving boss battle theme."""
    bpm = 170

    melody_pattern = [
        ('E4', 0.25), ('F4', 0.25), ('E4', 0.25), ('D#4', 0.25),
        ('E4', 0.5), ('G4', 0.5), ('B4', 0.5), ('A4', 0.5),
        ('G4', 0.25), ('A4', 0.25), ('G4', 0.25), ('F#4', 0.25),
        ('G4', 0.5), ('B4', 0.5), ('D5', 0.5), ('C5', 0.5),
        ('B4', 0.25), ('C5', 0.25), ('B4', 0.25), ('A4', 0.25),
        ('G4', 0.5), ('E4', 0.5), ('F#4', 0.5), ('G4', 0.5),
        ('A4', 0.5), ('B4', 0.5), ('C5', 0.5), ('D5', 0.5),
        ('E5', 1), ('D5', 0.5), ('B4', 0.5),
    ]
    melody, dur1 = sequence_notes(melody_pattern, bpm, sawtooth_wave, volume=0.22,
                                   attack=0.003, decay=0.02, sustain=0.7, release=0.01)

    # Aggressive bass
    bass_pattern = [
        ('E2', 0.25), ('E2', 0.25), ('E2', 0.25), ('REST', 0.25),
        ('E2', 0.25), ('E2', 0.25), ('G2', 0.25), ('REST', 0.25),
        ('A2', 0.25), ('A2', 0.25), ('A2', 0.25), ('REST', 0.25),
        ('B2', 0.25), ('B2', 0.25), ('A2', 0.25), ('REST', 0.25),
        ('C3', 0.25), ('C3', 0.25), ('C3', 0.25), ('REST', 0.25),
        ('B2', 0.25), ('B2', 0.25), ('A2', 0.25), ('REST', 0.25),
        ('G2', 0.25), ('A2', 0.25), ('B2', 0.25), ('REST', 0.25),
        ('E2', 0.5), ('E2', 0.5), ('E2', 0.5), ('REST', 0.5),
    ] * 2
    bass, dur2 = sequence_notes(bass_pattern, bpm, square_wave, volume=0.2, duty=0.75,
                                 attack=0.003, decay=0.01, sustain=0.8, release=0.005)

    # Ominous harmony
    harm_pattern = [
        ('E3', 2), ('G3', 2), ('A3', 2), ('B3', 2),
        ('C4', 2), ('B3', 2), ('A3', 2), ('E3', 2),
    ]
    harmony, dur3 = sequence_notes(harm_pattern, bpm, square_wave, volume=0.1, duty=0.125,
                                    attack=0.05, decay=0.1, sustain=0.4, release=0.05)

    drums_pat = [
        ('kick', 0.25), ('kick', 0.25), ('snare', 0.25), ('hat', 0.25),
        ('kick', 0.25), ('hat', 0.25), ('snare', 0.25), ('kick', 0.25),
    ] * 8
    drums, dur4 = drum_pattern(drums_pat, bpm, volume=0.14)

    total = max(dur1, dur2, dur3, dur4)
    samples = render_samples(total, mix(melody, bass, harmony, drums))
    return samples

def generate_shop():
    """Cheerful, light, mercantile shop theme."""
    bpm = 110

    melody_pattern = [
        ('C4', 0.5), ('E4', 0.5), ('G4', 0.5), ('E4', 0.5),
        ('F4', 0.5), ('A4', 0.5), ('G4', 1),
        ('E4', 0.5), ('D4', 0.5), ('C4', 0.5), ('D4', 0.5),
        ('E4', 1), ('G4', 1),
        ('A4', 0.5), ('G4', 0.5), ('F4', 0.5), ('E4', 0.5),
        ('D4', 0.5), ('E4', 0.5), ('C4', 1),
        ('D4', 0.5), ('E4', 0.5), ('F4', 0.5), ('G4', 0.5),
        ('A4', 1), ('G4', 1),
        ('C5', 0.5), ('B4', 0.5), ('A4', 0.5), ('G4', 0.5),
        ('F4', 0.5), ('E4', 0.5), ('D4', 1),
        ('C4', 0.5), ('E4', 0.5), ('G4', 1),
        ('C5', 2),
    ]
    melody, dur1 = sequence_notes(melody_pattern, bpm, square_wave, volume=0.2, duty=0.25,
                                   attack=0.01, decay=0.04, sustain=0.5, release=0.04)

    # Bouncy accompaniment
    acc_pattern = [
        ('C3', 0.25), ('E3', 0.25), ('G3', 0.25), ('E3', 0.25),
        ('F3', 0.25), ('A3', 0.25), ('C4', 0.25), ('A3', 0.25),
        ('G3', 0.25), ('B3', 0.25), ('D4', 0.25), ('B3', 0.25),
        ('C3', 0.25), ('E3', 0.25), ('G3', 0.25), ('E3', 0.25),
    ] * 5
    acc, dur2 = sequence_notes(acc_pattern, bpm, triangle_wave, volume=0.15,
                                attack=0.005, decay=0.02, sustain=0.4, release=0.01)

    bass_pattern = [
        ('C2', 1), ('F2', 1), ('G2', 1), ('C2', 1),
    ] * 5
    bass, dur3 = sequence_notes(bass_pattern, bpm, triangle_wave, volume=0.2,
                                 attack=0.01, decay=0.02, sustain=0.8, release=0.02)

    drums_pat = [
        ('hat', 0.5), ('hat', 0.5), ('kick', 0.5), ('hat', 0.5),
    ] * 10
    drums, dur4 = drum_pattern(drums_pat, bpm, volume=0.08)

    total = max(dur1, dur2, dur3, dur4)
    samples = render_samples(total, mix(melody, acc, bass, drums))
    return samples

def generate_rest():
    """Calm, peaceful rest/inn theme."""
    bpm = 72

    melody_pattern = [
        ('E4', 2), ('D4', 1), ('C4', 1), ('D4', 2), ('E4', 2),
        ('G4', 2), ('F4', 1), ('E4', 1), ('D4', 2), ('C4', 2),
        ('C4', 1), ('D4', 1), ('E4', 2), ('G4', 2), ('A4', 2),
        ('G4', 2), ('E4', 1), ('D4', 1), ('C4', 4),
    ]
    melody, dur1 = sequence_notes(melody_pattern, bpm, triangle_wave, volume=0.2,
                                   attack=0.05, decay=0.1, sustain=0.5, release=0.1)

    # Gentle arpeggio
    arp_pattern = [
        ('C3', 0.5), ('E3', 0.5), ('G3', 0.5), ('C4', 0.5),
        ('G3', 0.5), ('E3', 0.5), ('C3', 0.5), ('G2', 0.5),
        ('F3', 0.5), ('A3', 0.5), ('C4', 0.5), ('F4', 0.5),
        ('C4', 0.5), ('A3', 0.5), ('F3', 0.5), ('C3', 0.5),
    ] * 4
    arp, dur2 = sequence_notes(arp_pattern, bpm, sine_wave, volume=0.12,
                                attack=0.03, decay=0.05, sustain=0.3, release=0.05)

    bass_pattern = [
        ('C2', 4), ('F2', 4), ('G2', 4), ('C2', 4),
    ] * 2
    bass, dur3 = sequence_notes(bass_pattern, bpm, triangle_wave, volume=0.15,
                                 attack=0.05, decay=0.1, sustain=0.7, release=0.1)

    total = max(dur1, dur2, dur3)
    samples = render_samples(total, mix(melody, arp, bass))
    return samples

def generate_event():
    """Mysterious, curious event theme."""
    bpm = 95

    melody_pattern = [
        ('E4', 1), ('F4', 0.5), ('G#4', 1.5), ('A4', 1),
        ('B4', 0.5), ('A4', 0.5), ('G#4', 0.5), ('E4', 1.5),
        ('C4', 1), ('D4', 0.5), ('E4', 1.5), ('F4', 1),
        ('E4', 0.5), ('D4', 0.5), ('C4', 0.5), ('B3', 1.5),
        ('E4', 0.5), ('G#4', 0.5), ('B4', 1), ('A4', 1),
        ('G#4', 0.5), ('F4', 0.5), ('E4', 1), ('REST', 1),
        ('A3', 0.5), ('B3', 0.5), ('C4', 1), ('E4', 1),
        ('D4', 0.5), ('C4', 0.5), ('B3', 1), ('A3', 2),
    ]
    melody, dur1 = sequence_notes(melody_pattern, bpm, square_wave, volume=0.2, duty=0.5,
                                   attack=0.02, decay=0.05, sustain=0.5, release=0.05)

    # Eerie background
    bg_pattern = [
        ('A2', 2), ('E3', 2), ('A2', 2), ('G#2', 2),
        ('F2', 2), ('C3', 2), ('E2', 2), ('B2', 2),
    ] * 2
    bg, dur2 = sequence_notes(bg_pattern, bpm, triangle_wave, volume=0.15,
                               attack=0.08, decay=0.1, sustain=0.5, release=0.1)

    # Mysterious arpeggios
    myst_pattern = [
        ('A3', 0.25), ('C4', 0.25), ('E4', 0.25), ('C4', 0.25),
        ('G#3', 0.25), ('B3', 0.25), ('E4', 0.25), ('B3', 0.25),
        ('F3', 0.25), ('A3', 0.25), ('C4', 0.25), ('A3', 0.25),
        ('E3', 0.25), ('G#3', 0.25), ('B3', 0.25), ('G#3', 0.25),
    ] * 4
    myst, dur3 = sequence_notes(myst_pattern, bpm, square_wave, volume=0.08, duty=0.125,
                                 attack=0.005, decay=0.02, sustain=0.3, release=0.01)

    total = max(dur1, dur2, dur3)
    samples = render_samples(total, mix(melody, bg, myst))
    return samples

def generate_treasure():
    """Exciting, rewarding treasure discovery theme."""
    bpm = 140

    melody_pattern = [
        ('C5', 0.25), ('D5', 0.25), ('E5', 0.5), ('G5', 0.5), ('E5', 0.5),
        ('D5', 0.25), ('C5', 0.25), ('D5', 0.5), ('E5', 1),
        ('C5', 0.25), ('D5', 0.25), ('E5', 0.5), ('A5', 0.5), ('G5', 0.5),
        ('E5', 0.5), ('D5', 0.5), ('C5', 1),
        ('G4', 0.5), ('A4', 0.5), ('B4', 0.5), ('C5', 0.5),
        ('D5', 0.5), ('E5', 0.5), ('F5', 0.5), ('G5', 0.5),
        ('E5', 1), ('C5', 1), ('G4', 1), ('C5', 1),
    ]
    melody, dur1 = sequence_notes(melody_pattern, bpm, square_wave, volume=0.22, duty=0.5,
                                   attack=0.005, decay=0.03, sustain=0.6, release=0.02)

    # Sparkle arpeggios
    sparkle_pattern = [
        ('C4', 0.125), ('E4', 0.125), ('G4', 0.125), ('C5', 0.125),
        ('E5', 0.125), ('C5', 0.125), ('G4', 0.125), ('E4', 0.125),
    ] * 12
    sparkle, dur2 = sequence_notes(sparkle_pattern, bpm, square_wave, volume=0.1, duty=0.125,
                                    attack=0.003, decay=0.01, sustain=0.3, release=0.005)

    bass_pattern = [
        ('C2', 1), ('E2', 1), ('G2', 1), ('C3', 1),
    ] * 4
    bass, dur3 = sequence_notes(bass_pattern, bpm, triangle_wave, volume=0.18,
                                 attack=0.01, decay=0.02, sustain=0.7, release=0.02)

    drums_pat = [
        ('kick', 0.5), ('hat', 0.25), ('hat', 0.25), ('snare', 0.5), ('hat', 0.25), ('hat', 0.25),
    ] * 8
    drums, dur4 = drum_pattern(drums_pat, bpm, volume=0.1)

    total = max(dur1, dur2, dur3, dur4)
    samples = render_samples(total, mix(melody, sparkle, bass, drums))
    return samples

def generate_victory():
    """Short triumphant victory fanfare."""
    bpm = 140

    melody_pattern = [
        ('C4', 0.25), ('E4', 0.25), ('G4', 0.25), ('C5', 0.75),
        ('REST', 0.25),
        ('C5', 0.25), ('D5', 0.25), ('E5', 0.5), ('E5', 0.5),
        ('D5', 0.25), ('E5', 0.25), ('F5', 0.5), ('F5', 0.5),
        ('E5', 0.25), ('F5', 0.25), ('G5', 1.5),
        ('REST', 0.5),
        ('G5', 0.5), ('E5', 0.5), ('C5', 0.5), ('E5', 0.5),
        ('G5', 2),
    ]
    melody, dur1 = sequence_notes(melody_pattern, bpm, square_wave, volume=0.25, duty=0.5,
                                   attack=0.01, decay=0.03, sustain=0.7, release=0.05)

    # Triumphal harmony
    harm_pattern = [
        ('C3', 0.25), ('E3', 0.25), ('G3', 0.25), ('E3', 0.75),
        ('REST', 0.25),
        ('G3', 0.25), ('B3', 0.25), ('C4', 0.5), ('C4', 0.5),
        ('B3', 0.25), ('C4', 0.25), ('D4', 0.5), ('D4', 0.5),
        ('C4', 0.25), ('D4', 0.25), ('E4', 1.5),
        ('REST', 0.5),
        ('E4', 0.5), ('C4', 0.5), ('G3', 0.5), ('C4', 0.5),
        ('E4', 2),
    ]
    harmony, dur2 = sequence_notes(harm_pattern, bpm, triangle_wave, volume=0.18,
                                    attack=0.01, decay=0.03, sustain=0.6, release=0.05)

    bass_pattern = [
        ('C2', 1.75), ('REST', 0.25),
        ('C2', 1), ('G2', 1),
        ('F2', 1), ('G2', 1),
        ('C2', 1.5), ('REST', 0.5),
        ('C2', 1), ('C2', 1),
        ('C2', 2),
    ]
    bass, dur3 = sequence_notes(bass_pattern, bpm, triangle_wave, volume=0.2,
                                 attack=0.01, decay=0.02, sustain=0.8, release=0.02)

    total = max(dur1, dur2, dur3)
    samples = render_samples(total, mix(melody, harmony, bass))
    return samples

def generate_game_over():
    """Somber but gentle game over theme (kid-friendly)."""
    bpm = 70

    melody_pattern = [
        ('E4', 2), ('D4', 1), ('C4', 1),
        ('D4', 1.5), ('C4', 0.5), ('B3', 2),
        ('C4', 2), ('A3', 1), ('G3', 1),
        ('A3', 1), ('B3', 1), ('C4', 2),
        ('E4', 1), ('D4', 1), ('C4', 2),
        ('B3', 1), ('A3', 1), ('G3', 2),
        ('A3', 1), ('B3', 0.5), ('C4', 0.5), ('D4', 2),
        ('C4', 4),
    ]
    melody, dur1 = sequence_notes(melody_pattern, bpm, triangle_wave, volume=0.2,
                                   attack=0.05, decay=0.1, sustain=0.5, release=0.1)

    # Gentle accompaniment
    acc_pattern = [
        ('C3', 0.5), ('E3', 0.5), ('G3', 0.5), ('E3', 0.5),
        ('G2', 0.5), ('B2', 0.5), ('D3', 0.5), ('B2', 0.5),
        ('A2', 0.5), ('C3', 0.5), ('E3', 0.5), ('C3', 0.5),
        ('G2', 0.5), ('B2', 0.5), ('D3', 0.5), ('B2', 0.5),
    ] * 4
    acc, dur2 = sequence_notes(acc_pattern, bpm, sine_wave, volume=0.1,
                                attack=0.03, decay=0.05, sustain=0.3, release=0.03)

    bass_pattern = [
        ('C2', 4), ('G1', 4), ('A1', 4), ('G1', 4),
    ] * 2
    bass, dur3 = sequence_notes(bass_pattern, bpm, triangle_wave, volume=0.15,
                                 attack=0.05, decay=0.1, sustain=0.6, release=0.1)

    total = max(dur1, dur2, dur3)
    samples = render_samples(total, mix(melody, acc, bass))
    return samples

# ============================================================
# SOUND EFFECTS
# ============================================================

def generate_sfx_attack():
    """Quick attack hit sound."""
    duration = 0.15
    def gen(t):
        freq = 200 * math.exp(-t * 40)
        env = math.exp(-t * 25)
        return (square_wave(freq, t, 0.5) * 0.3 + noise(t) * 0.2) * env
    samples = render_samples(duration, gen)
    return samples

def generate_sfx_level_up():
    """Ascending chime for level up."""
    duration = 0.8
    notes_seq = [('C5', 0.15), ('E5', 0.15), ('G5', 0.15), ('C6', 0.35)]
    current_t = 0.0
    events = []
    for n, d in notes_seq:
        events.append((current_t, d, note(n)))
        current_t += d

    def gen(t):
        for start, dur, freq in events:
            if start <= t < start + dur:
                local_t = t - start
                env = adsr_envelope(local_t, dur, 0.005, 0.02, 0.7, 0.05)
                return (square_wave(freq, t, 0.25) * 0.25 + sine_wave(freq, t) * 0.15) * env
        return 0.0
    samples = render_samples(duration, gen)
    return samples

def generate_sfx_gold():
    """Coin clink sound."""
    duration = 0.25
    def gen(t):
        freq1 = 1200
        freq2 = 1800
        env1 = math.exp(-t * 20) if t < 0.1 else 0
        env2 = math.exp(-(t - 0.05) * 25) if t >= 0.05 else 0
        return (sine_wave(freq1, t) * env1 + sine_wave(freq2, t) * env2) * 0.3
    samples = render_samples(duration, gen)
    return samples

def generate_sfx_menu_select():
    """Quick blip for menu selection."""
    duration = 0.08
    def gen(t):
        freq = 800
        env = math.exp(-t * 30)
        return square_wave(freq, t, 0.25) * env * 0.25
    samples = render_samples(duration, gen)
    return samples

# ============================================================
# MAIN
# ============================================================

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    music_dir = os.path.join(base_dir, 'assets', 'audio', 'music')
    sfx_dir = os.path.join(base_dir, 'assets', 'audio', 'sfx')

    os.makedirs(music_dir, exist_ok=True)
    os.makedirs(sfx_dir, exist_ok=True)

    print("Generating 8-bit music for Asher's Adventure...")
    print()

    tracks = [
        ('title_theme', generate_title_theme),
        ('exploration', generate_exploration),
        ('battle', generate_battle),
        ('boss_battle', generate_boss_battle),
        ('shop', generate_shop),
        ('rest', generate_rest),
        ('event', generate_event),
        ('treasure', generate_treasure),
        ('victory', generate_victory),
        ('game_over', generate_game_over),
    ]

    print("=== Music Tracks ===")
    for name, func in tracks:
        print(f"  Composing {name}...")
        samples = func()
        write_wav(os.path.join(music_dir, f'{name}.wav'), samples)

    print()
    print("=== Sound Effects ===")
    sfx = [
        ('attack_hit', generate_sfx_attack),
        ('level_up', generate_sfx_level_up),
        ('gold_pickup', generate_sfx_gold),
        ('menu_select', generate_sfx_menu_select),
    ]

    for name, func in sfx:
        print(f"  Generating {name}...")
        samples = func()
        write_wav(os.path.join(sfx_dir, f'{name}.wav'), samples)

    print()
    print("Done! All audio files generated.")

if __name__ == '__main__':
    main()
