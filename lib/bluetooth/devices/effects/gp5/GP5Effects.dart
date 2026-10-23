// This code is licensed under MIT license (see LICENSE.md for details)

import 'GP5Processor.dart';

/// Effect and parameter definitions for the Valeton GP5.
///
/// The GP5 has 10 fixed blocks:
/// 0 - nr   (Noise Reduction)
/// 1 - pre  (Pre-Effects)
/// 2 - dst  (Distortion)
/// 3 - amp  (Amplifier)
/// 4 - cab  (Cabinet)
/// 5 - eq   (Equalizer)
/// 6 - mod  (Modulation)
/// 7 - dly  (Delay)
/// 8 - rvb  (Reverb)
/// 9 - ns   (NAM snaptones)
class GP5Effects {
  static GP5Param _slider(String name, String handle, double def, double min,
      double max,
      {int decimals = 0,
      String suffix = "",
      bool masterVolume = false,
      int? wireAddress}) {
    return GP5Param(
        name: name,
        handle: handle,
        def: def,
        min: min,
        max: max,
        decimals: decimals,
        suffix: suffix,
        masterVolume: masterVolume,
        wireAddress: wireAddress);
  }

  static GP5Param _switch(String name, String handle,
      {double def = 0, int? wireAddress}) {
    return GP5Param(
        name: name,
        handle: handle,
        def: def,
        min: 0,
        max: 1,
        isSwitch: true,
        wireAddress: wireAddress);
  }

  /// The wire byte a parameter of [block] at list position [paramIndex] is
  /// written to, or null when it must not be written at all.
  ///
  /// The wire byte is the "algId" of the official metadata - the number the
  /// official Valeton app drops into the change-parameter frame unchanged - and
  /// those ids are 0-based, so a dense algorithm numbers its parameters
  /// 0, 1, 2, ... A declared [wireAddress] always wins: it is the id of an
  /// algorithm whose ids are sparse, e.g. the reverbs and delays, where the
  /// pedal leaves holes in the block's parameter space.
  ///
  /// This app used to write [paramIndex] + 1, i.e. every parameter of every
  /// block one byte too high. Confirmed on the pedal: on a delay, Mix (written
  /// to byte 1) changed Time instead.
  static int? resolveWireParam(int block, int paramIndex, int? wireAddress) =>
      wireAddress ?? paramIndex;

  //============================= NR =============================
  static Gp5Processor noiseReduction() {
    return Gp5Processor(0, "00000000", 0, "Noise Reduction", [
      _slider("THRE", "thre", 20, 0, 100),
    ]);
  }

  //============================= PRE =============================
  static List<Gp5Processor> preEffects() => [
        Gp5Processor(1, "00000000", 0, "Compressor", [
          _slider("Sustain", "sustain", 20, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(1, "01000000", 1, "Compressor 2", [
          _slider("Sustain", "sustain", 20, 0, 100),
          _slider("Attack", "attack", 60, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
          _slider("Clip", "clip", 10, 0, 100),
        ]),
        Gp5Processor(1, "1a000000", 2, "Booster", [
          _slider("Gain", "gain", 20, 0, 100),
          _switch("+3DB", "3db", def: 1),
          _switch("Bright", "bright", def: 1),
        ]),
        Gp5Processor(1, "14000000", 3, "Volume", [
          _slider("Gain", "gain", 50, 0, 100),
        ]),
        Gp5Processor(1, "0b000000", 4, "EQ", [
          _slider("Gain", "gain", 20, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Processor(1, "0f000001", 5, "Auto Wah", [
          _slider("Sense", "sense", 50, 0, 100),
          _slider("Range", "range", 50, 0, 100),
          _slider("Q", "q", 50, 0, 100),
          _slider("Mix", "mix", 50, 0, 100),
          _switch("Mode", "mode"),
        ]),
        Gp5Processor(1, "15000001", 6, "Touch Wah", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
          _slider("Vol", "vol", 50, 0, 100),
          _slider("Low", "low", 25, 0, 100),
          _slider("Q", "q", 70, 0, 100),
          _slider("High", "high", 60, 0, 100),
        ]),
        Gp5Processor(1, "21000001", 7, "Octaver", [
          _slider("Low", "low", 50, 0, 100),
          _slider("High", "high", 50, 0, 100),
          _slider("Dry", "dry", 50, 0, 100),
        ]),
        Gp5Processor(1, "23000001", 8, "Smart Harmony", [
          _slider("MHigh", "mhigh", 12, 0, 24),
          _slider("MLow", "mlow", -12, -24, 0),
          _slider("MDry", "mdry", 50, 0, 100),
          _slider("MH-Vol", "mh_vol", 50, 0, 100),
          _slider("ML-Vol", "ml_vol", 50, 0, 100),
        ]),
        Gp5Processor(1, "29000001", 9, "Pitch Shifter", [
          _slider("Detune", "detune", -25, -50, 50),
          _slider("Wet", "wet", 50, 0, 100),
          _slider("Dry", "dry", 50, 0, 100),
        ]),
      ];

  //============================= DST =============================
  static List<Gp5Processor> dstEffects() => [
        Gp5Processor(2, "00000003", 0, "Overdrive", [
          _slider("Gain", "gain", 40, 0, 100),
          _slider("Tone", "tone", 70, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(2, "02000003", 1, "Distortion", [
          _slider("Gain", "gain", 40, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(2, "06000003", 2, "Metal", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Tone", "tone", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(2, "2a000003", 3, "Crunch", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Tone", "tone", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(2, "29000003", 4, "Blues", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(2, "30000003", 5, "Classic", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Tone", "tone", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(2, "2b000003", 6, "Bass Overdrive", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Filter", "filter", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(2, "22000003", 7, "Fuzz", [
          _slider("Fuzz", "fuzz", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(2, "24000003", 8, "Muff Fuzz", [
          _slider("Fuzz", "fuzz", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(2, "40000003", 9, "Bass Distortion", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Blend", "blend", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
      ];

  //============================= AMP =============================
  static List<Gp5Processor> ampEffects() => [
        Gp5Amplifier(3, "01000007", 0, "Tweedy", [
          _slider("Gain", "gain", 30, 0, 100),
          _slider("Tone", "tone", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
        ]),
        Gp5Amplifier(3, "03000007", 1, "Bellman", [
          _slider("Gain", "gain", 30, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "04000007", 2, "Dark Twin", [
          _slider("Gain", "gain", 35, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 40, 0, 100),
          _slider("Treble", "treble", 60, 0, 100),
          _switch("Bright", "bright", def: 1),
        ]),
        Gp5Amplifier(3, "11000007", 3, "Foxy", [
          _slider("Gain", "gain", 30, 0, 100),
          _slider("Tone Cut", "tone_cut", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _switch("Bright", "bright"),
        ]),
        Gp5Amplifier(3, "14000007", 4, "J-120", [
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
          _switch("Bright", "bright"),
        ]),
        Gp5Amplifier(3, "15000007", 5, "Match", [
          _slider("Gain", "gain", 25, 0, 100),
          _slider("PRES", "pres", 65, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 45, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 65, 0, 100),
        ]),
        Gp5Amplifier(3, "19000007", 6, "L-Star CL", [
          _slider("Gain", "gain", 25, 0, 100),
          _slider("PRES", "pres", 65, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 45, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 65, 0, 100),
        ]),
        Gp5Amplifier(3, "2a000007", 7, "UK 45", [
          _slider("Gain", "gain", 25, 0, 100),
          _slider("PRES", "pres", 65, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 45, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 65, 0, 100),
        ]),
        Gp5Amplifier(3, "2f000007", 8, "UK 50 JP", [
          _slider("Gain 1", "gain1", 40, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
          _slider("Gain 2", "gain2", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "35000007", 9, "UK 800", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "24000007", 10, "Bellman 59b", [
          _slider("Gain", "gain", 35, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "27000007", 11, "Foxy 30TB", [
          _slider("Gain", "gain", 30, 0, 100),
          _slider("Tone Cut", "tone_cut", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
          _switch("Char", "char", def: 0),
        ]),
        Gp5Amplifier(3, "28000007", 12, "SUPDual OD", [
          _slider("Gain 1", "gain1", 30, 0, 100),
          _slider("Tone 1", "tone1", 50, 0, 100),
          _slider("Gain 2", "gain2", 50, 0, 100),
          _slider("Tone 2", "tone2", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
        ]),
        Gp5Amplifier(3, "47000007", 13, "SOLO100 D", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "49000007", 14, "Z38 OD", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Tone Cut", "tone_cut", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "4b000007", 15, "Bad-KY OD", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Edge", "edge", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "53000007", 16, "Juice r100", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "65000007", 17, "Dizz VH", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "6a000007", 18, "Dizz VH+", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "5f000007", 19, "Eagle 120", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "5a000007", 20, "EV 51", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
          // module_data.json gives EV 51 algIds [0, 1, 2, 3, 4, 6]: PRES is the
          // sixth knob but its wire address is 6, not the list slot 5.
          _slider("PRES", "pres", 50, 0, 100, wireAddress: 6),
        ]),
        Gp5Amplifier(3, "59000007", 21, "Solo100 LD", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "68000007", 22, "Mess Dual V", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "69000007", 23, "Mess dual M", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "63000007", 24, "Power LD", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "5d000007", 25, "Flagman+", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "6d000007", 26, "Bog RedV", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("PRES", "pres", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "73000007", 27, "Classic Bass", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("MidFreq", "midfreq", 1, 0, 4),
          _slider("Treble", "treble", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
        ]),
        Gp5Amplifier(3, "75000007", 28, "Foxy Bass", [
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "77000007", 29, "Mess Bass", [
          _slider("Gain", "gain", 50, 0, 100),
          _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
          _slider("Bass", "bass", 50, 0, 100),
          _slider("Middle", "middle", 50, 0, 100),
          _slider("Treble", "treble", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "7a000008", 30, "AC Pre1", [
          _slider("Volume", "volume", 50, 0, 100),
          _slider("Tone", "tone", 50, 0, 100),
          _slider("Balance", "balance", 50, 0, 100),
          _slider("EQ Freq", "eq_freq", 50, 0, 100),
          _slider("EQ Q", "eq_q", 50, 0, 100),
          _slider("EQ Gain", "eq_gain", 50, 0, 100),
        ]),
        Gp5Amplifier(3, "7b000008", 31, "AC Pre2", [
          _slider("Volume", "volume", 50, 0, 100),
          _slider("Tone", "tone", 50, 0, 100),
          _slider("Balance", "balance", 50, 0, 100),
          _slider("EQ Freq", "eq_freq", 50, 0, 100),
          _slider("EQ Q", "eq_q", 50, 0, 100),
          _slider("EQ Gain", "eq_gain", 50, 0, 100),
        ]),
      ];

  //============================= CAB =============================
  static List<GP5Param> cabParams() => [_slider("Vol", "vol", 50, 0, 100)];

  static List<Gp5Processor> cabEffects() => [
        Gp5Cabinet(4, "0100000a", 0, "TWD CP 1x8", cabParams()),
        Gp5Cabinet(4, "0400000a", 1, "Dark VIT 1x12", cabParams()),
        Gp5Cabinet(4, "0800000a", 2, "Foxy 1x12", cabParams()),
        Gp5Cabinet(4, "0900000a", 3, "L-Star 1x12", cabParams()),
        Gp5Cabinet(4, "1b00000a", 4, "Dark CS 2x12", cabParams()),
        Gp5Cabinet(4, "1200000a", 5, "Dark Twin 2x12", cabParams()),
        Gp5Cabinet(4, "1900000a", 6, "SUP Star 2x12", cabParams()),
        Gp5Cabinet(4, "1100000a", 7, "J-120 2x12", cabParams()),
        Gp5Cabinet(4, "0f00000a", 8, "Foxy 2x12", cabParams()),
        Gp5Cabinet(4, "1300000a", 9, "UK GRN 2x12", cabParams()),
        Gp5Cabinet(4, "2200000a", 10, "UK GRN 4x12", cabParams()),
        Gp5Cabinet(4, "2500000a", 11, "Bog 4x12", cabParams()),
        Gp5Cabinet(4, "2e00000a", 12, "Dizz 4x12", cabParams()),
        Gp5Cabinet(4, "2000000a", 13, "EV 4x12", cabParams()),
        Gp5Cabinet(4, "2800000a", 14, "Solo 4x12", cabParams()),
        Gp5Cabinet(4, "2400000a", 15, "Mess 4x12", cabParams()),
        Gp5Cabinet(4, "2600000a", 16, "Eagle 4x12", cabParams()),
        Gp5Cabinet(4, "2900000a", 17, "Juice 4x12", cabParams()),
        Gp5Cabinet(4, "1600000a", 18, "Bellman 2x12", cabParams()),
        Gp5Cabinet(4, "3800000a", 19, "AMPG 4x10", cabParams()),
        for (int i = 0; i < 20; i++)
          Gp5Cabinet(4, "${i.toRadixString(16).padLeft(2, '0')}00100a",
              20 + i, "User IR ${i + 1}", cabParams()),
      ];

  //============================= EQ =============================
  static List<Gp5Processor> eqEffects() => [
        Gp5Processor(5, "35000001", 0, "EQ 1", [
          _slider("125Hz", "eq125", 0, -50, 50),
          _slider("400Hz", "eq400", 0, -50, 50),
          _slider("800Hz", "eq800", 0, -50, 50),
          _slider("1.6kHz", "eq1_6k", 0, -50, 50),
          _slider("4KHz", "eq4k", 0, -50, 50),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(5, "36000001", 1, "EQ 2", [
          _slider("100Hz", "eq100", 0, -50, 50),
          _slider("500Hz", "eq500", 0, -50, 50),
          _slider("1kHz", "eq1k", 0, -50, 50),
          _slider("3kHz", "eq3k", 0, -50, 50),
          _slider("6KHz", "eq6k", 0, -50, 50),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(5, "39000001", 2, "Bass EQ 1", [
          _slider("33Hz", "eq33", 0, -50, 50),
          _slider("150Hz", "eq150", 0, -50, 50),
          _slider("600Hz", "eq600", 0, -50, 50),
          _slider("2kHz", "eq2k", 0, -50, 50),
          _slider("8KHz", "eq8k", 0, -50, 50),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(5, "3a000001", 3, "Bass EQ 2", [
          _slider("50Hz", "eq50", 0, -50, 50),
          _slider("120Hz", "eq120", 0, -50, 50),
          _slider("400Hz", "eq400", 0, -50, 50),
          _slider("800Hz", "eq800", 0, -50, 50),
          _slider("4.5KHz", "eq4_5k", 0, -50, 50),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(5, "3c000001", 4, "Mesa EQ", [
          _slider("80Hz", "eq80", 0, -50, 50),
          _slider("240Hz", "eq240", 0, -50, 50),
          _slider("750Hz", "eq750", 0, -50, 50),
          _slider("2.2kHz", "eq2_2k", 0, -50, 50),
          _slider("6.6KHz", "eq6_6k", 0, -50, 50),
        ]),
      ];

  //============================= MOD =============================
  static List<Gp5Processor> modEffects() => [
        Gp5Processor(6, "00000004", 0, "Aozora Chorus", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
          _slider("Tone", "tone", 50, 0, 100),
        ]),
        Gp5Processor(6, "08000004", 1, "Choruium B", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(6, "11000004", 2, "Jetter", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
          _slider("P.Delay", "p_delay", 50, 0, 100),
          _slider("F.Back", "f_back", 50, 0, 100),
        ]),
        Gp5Processor(6, "13000004", 3, "Jetter N", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
          _slider("P.Delay", "p_delay", 50, 0, 100),
          _slider("F.Back", "f_back", 50, 0, 100),
        ]),
        Gp5Processor(6, "19000004", 4, "Phaser 90", [
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
        ]),
        Gp5Processor(6, "1f000004", 5, "Minivibe", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
        ]),
        Gp5Processor(6, "15000004", 6, "Pulser", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
        ]),
        Gp5Processor(6, "17000004", 7, "Shiver", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(6, "21000004", 8, "Helicopter", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
        ]),
        Gp5Processor(6, "26000004", 9, "Sine Trem", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
          _slider("Vol", "vol", 50, 0, 100),
        ]),
        Gp5Processor(6, "28000004", 10, "Bias Trem", [
          _slider("Depth", "depth", 50, 0, 100),
          _slider("Rate", "rate", 0.5, 0.1, 10, decimals: 1),
          _slider("Vol", "vol", 50, 0, 100),
          // Bias is algId 4 in module_data.json, not the list index 3; writing
          // 3 hit a slot the pedal does not use and the value snapped back.
          _slider("Bias", "bias", 50, 0, 100, wireAddress: 4),
        ]),
      ];

  //============================= DLY =============================
  //Same algId addressing as the rvb block: Mix 0, Time 1, F.Back 2, and Trail
  //at algId 4 on the plain delays and algId 7 on Ring and Sweep, which skip two
  //parameters. Confirmed on the pedal: writing Mix to byte 1 changed Time.
  static List<GP5Param> _delayParams(double time, double minMs, double maxMs,
          {int trailWire = 4, double fBack = 30}) =>
      [
        _slider("Mix", "mix", 20, 0, 100, wireAddress: 0),
        _slider("Time (ms)", "time_ms", time, minMs, maxMs,
            decimals: 0, suffix: " ms", wireAddress: 1),
        _slider("F.Back", "f_back", fBack, 0, 100, wireAddress: 2),
        _switch("Trail", "trail", wireAddress: trailWire),
      ];

  static List<Gp5Processor> dlyEffects() => [
        Gp5Processor(
            7, "0000000b", 0, "Analog Delay", _delayParams(500, 20, 1000)),
        Gp5Processor(
            7, "0100000b", 1, "Digital Delay", _delayParams(500, 20, 1000, fBack: 50)),
        Gp5Processor(
            7, "0500000b", 2, "Slap Delay", _delayParams(150, 20, 300)),
        Gp5Processor(7, "0d00000b", 3, "Tape Echo", _delayParams(500, 20, 1000)),
        Gp5Processor(7, "0200000b", 4, "Mod Delay", _delayParams(500, 20, 1000)),
        Gp5Processor(
            7, "0b00000b", 5, "Reverse Delay", _delayParams(500, 20, 1000)),
        Gp5Processor(
            7, "1300000b", 6, "Lo-Fi Delay", _delayParams(500, 20, 1000)),
        Gp5Processor(7, "0900000b", 7, "Filter Delay", [
          _slider("Mix", "mix", 20, 0, 100, wireAddress: 0),
          _slider("Time (ms)", "time_ms", 500, 20, 1000,
              decimals: 0, suffix: " ms", wireAddress: 1),
          _slider("F.Back", "f_back", 30, 0, 100, wireAddress: 2),
          _slider("R-Mix", "r_mix", 50, 0, 100, wireAddress: 3),
          _slider("Freq", "freq", 50, 0, 100, wireAddress: 4),
          _slider("Tone", "tone", 50, 0, 100, wireAddress: 5),
          _switch("Trail", "trail", wireAddress: 7),
        ]),
        Gp5Processor(7, "0600000b", 8, "Sweep Delay", [
          _slider("Mix", "mix", 20, 0, 100, wireAddress: 0),
          _slider("Time (ms)", "time_ms", 500, 20, 1000,
              decimals: 0, suffix: " ms", wireAddress: 1),
          _slider("F.Back", "f_back", 30, 0, 100, wireAddress: 2),
          _slider("S-Depth", "s_depth", 50, 0, 100, wireAddress: 3),
          _slider("S-Rate", "s_rate", 50, 0, 100, wireAddress: 4),
          _switch("Trail", "trail", wireAddress: 7),
        ]),
        Gp5Processor(
            7, "0400000b", 9, "Ping Pong Delay", _delayParams(500, 20, 500)),
      ];

  //============================= RVB =============================
  //The rvb block does not address its parameters by their position in this
  //list. The device uses the "algId" that the official Valeton app reads from
  //its own metadata for every parameter (module_data.json -> alg[].algId), and
  //the official app drops that number straight into the change-parameter frame
  //with no arithmetic on it. Those ids are sparse per algorithm: the pedal
  //keeps one parameter space per block and unused slots stay as holes, so
  //"third parameter" and "byte 3" are not the same thing.
  //
  //Per algorithm, official algId (= wire byte):
  //  0b00000c Studio/Air   Mix 0, Decay 2, Damp 4, Trail 6
  //  0000000c Room         Mix 0, Decay 2, Trail 3
  //  0100000c Hall         Mix 0, Decay 2, Trail 3
  //  0200000c Church       Mix 0, Decay 2, Trail 3
  //  1000000c Large Plate  Mix 0, Decay 2, Trail 6
  //  0f00000c Small Plate  Mix 0, Decay 2, Damp 4, Trail 6
  //  0400000c Spring       Mix 0, Decay 1, Trail 3
  //  0600000c Northstar    Mix 0, Decay 1, Trail 2
  //  0700000c Oceandeep    Mix 0, Decay 1, Trail 2
  //  1500000c Cloud        Mix 0, Decay 2, Damp 4, Mod 5, Trail 6
  //
  //Every parameter carries its own address and none of them collide: Spring,
  //Northstar and Oceandeep declare Decay with algId 1, which leaves their Trail
  //switch (algId 3 / 2 / 2) writable - it had to be left alone back when Mix
  //was written to byte 1 and took that Decay slot with it.
  //
  //Mix is byte 0. It was byte 1 for a while on the strength of a measurement
  //that the delay block has since explained: byte 1 there is Time, so the
  //addresses are the plain algIds with no +1, and on a reverb byte 1 is no
  //parameter at all (or Decay, on Spring and friends).
  static List<GP5Param> _rvbParams(
          {int decayWire = 2,
          bool damp = false,
          double dampDef = 0,
          int? modWire,
          int? trailWire}) =>
      [
        _slider("Mix", "mix", 30, 0, 100, wireAddress: 0),
        _slider("Decay", "decay", 50, 0, 100, wireAddress: decayWire),
        if (damp) _slider("Damp", "damp", dampDef, 0, 100, wireAddress: 4),
        if (modWire != null)
          _slider("Mod", "mod", 50, 0, 100, wireAddress: modWire),
        _switch("Trail", "trail", wireAddress: trailWire),
      ];

  static List<Gp5Processor> rvbEffects() => [
        Gp5Processor(
            8, "0b00000c", 0, "Studio", _rvbParams(damp: true, trailWire: 6)),
        Gp5Processor(8, "0000000c", 1, "Room", _rvbParams(trailWire: 3)),
        Gp5Processor(8, "0100000c", 2, "Hall", _rvbParams(trailWire: 3)),
        Gp5Processor(8, "0200000c", 3, "Church", _rvbParams(trailWire: 3)),
        Gp5Processor(8, "1000000c", 4, "Large Plate", _rvbParams(trailWire: 6)),
        Gp5Processor(
            8, "0f00000c", 5, "Small Plate",
            _rvbParams(damp: true, dampDef: 50, trailWire: 6)),
        Gp5Processor(8, "0400000c", 6, "Spring",
            _rvbParams(decayWire: 1, trailWire: 3)),
        Gp5Processor(8, "0600000c", 7, "Northstar",
            _rvbParams(decayWire: 1, trailWire: 2)),
        Gp5Processor(8, "0700000c", 8, "Oceandeep",
            _rvbParams(decayWire: 1, trailWire: 2)),
        Gp5Processor(8, "1500000c", 9, "Cloud",
            _rvbParams(damp: true, modWire: 5, trailWire: 6)),
      ];

  //============================= NS (NAM snaptones) =============================
  static List<Gp5Processor> nsEffects() => [
        for (int i = 0; i < 80; i++)
          Gp5Processor(
              9,
              //snaptone id bus: NS category is 0x0f, e.g. '0000000f',
              //'0100000f' ... '4f00000f'.
              "${i.toRadixString(16).padLeft(2, '0')}00000f",
              i,
              "NAM ${i + 1}",
              [
                _slider("Gain", "gain", 50, 0, 100),
                _slider("Vol", "vol", 50, 0, 100, masterVolume: true),
                _slider("Bass", "bass", 50, 0, 100),
                _slider("Middle", "middle", 50, 0, 100),
                _slider("Treble", "treble", 50, 0, 100),
              ]),
      ];
}