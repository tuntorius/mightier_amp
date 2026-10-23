/// Decoder for the GP-5's parameter cells in the patch data frames.
///
/// The device does not store parameter values in their own units. Most
/// parameters are normalised to a position between 0 and 100 and quantised to
/// 101 whole-percent states, each state being a distinct 4-byte cell followed
/// by 4 bytes of padding, so consecutive parameters of an effect are 8 bytes
/// apart.
///
/// The 4 bytes are not all part of the value: the third and fourth bytes are
/// derived from the position rather than independent of it. Position 0 is
/// tagged `0000`, position 1 `030f`, positions 2 to 7 `0400`, positions 8 to
/// 31 `0401` and positions 32 to 100 `0402`, with the first two bytes
/// carrying the position within that band. [gp5ParamCellToPercent] therefore
/// lists all 101 cells of the plain percentage encoding, and between them they
/// account for every plain percentage the device produces.
///
/// Four encodings are in use and the device reuses the same byte tags across
/// them, so which one a cell uses follows from the parameter's declared range
/// rather than from the cell itself - see [gp5CellFamily]. A parameter with a
/// negative minimum is bipolar: the eq bands (dB), the pitch shifter's detune
/// (cents) and the smart harmony's low interval (semitones) all reuse the
/// percentage magnitudes and mark the negative half with a sign bit, so
/// [gp5DecodeBipolarCell] yields the value in its own unit rather than a 0-100
/// position. A rate runs from 0.10 to 10.00 Hz on the grid in
/// [gp5CellToRateHz] and a delay time from 20 to 1000 ms on the grid in
/// [gp5CellToDelayTimeMs]. Both grids are shared between the blocks and
/// effects that use them.
///
/// A fifth case, [Gp5CellFamily.rawCount], looks like a plain percentage but is
/// not one: the smart harmony's high interval runs 0 to 24 semitones and the
/// device stores the semitone count in the state itself, so the state is the
/// value and must not be mapped onto 0-100. See [gp5DecodeRawCountCell].
///
/// Derived empirically from the device: every parameter of every effect in the
/// mapped blocks was driven to a distinct position and the cell that moved was
/// recorded, then a sweep across each full range confirmed the resulting
/// states, each stable across repeated reads. The two new grids were then
/// re-checked on an effect in a different block, and on an effect whose range
/// is a subrange of the one the grid was measured against.
library gp5_param_cell;

/// Where each block's parameter area starts, as the index of the 212-byte
/// patch-data part that carries it plus the offset of the first cell inside
/// that part. A block's parameter with index `i` lives at
/// `offset + 8 * i`; every cell is 4 bytes wide with 4 bytes of padding.
///
/// Measured against the device by isolating one parameter at a time: every
/// parameter of an effect is first driven to its minimum, then exactly one is
/// driven to its maximum, so the bytes that move belong to that parameter
/// alone. Blocks 6 and 7 were re-measured as controls and reproduced the
/// values already recorded here, which validates the method for the rest.
///
/// Block 8 (rvb) is on the same 8-byte stride as the others. Its cells do not
/// all use the plain percentage encoding, so [gp5DecodeParamCell] returns null
/// for the ones that do not and the caller leaves those parameters at their
/// default. Block 9 (ns) is carried entirely by the separate 148-byte
/// end-of-patch frame, so its base names part 4 directly.
const Map<int, List<int>> gp5ParamCellBase = <int, List<int>>{
  0: <int>[1, 87], // nr
  1: <int>[1, 151], // pre
  2: <int>[2, 15], // dst
  3: <int>[2, 79], // amp
  4: <int>[2, 143], // cab
  5: <int>[3, 7], // eq
  6: <int>[3, 71], // mod
  7: <int>[3, 135], // dly
  8: <int>[3, 199], // rvb
  // Block 9 (ns). Measured on device by writing NAM 1's Gain and reading the
  // patch back: the value landed in the cell at offset 63 while offset 55 held
  // an all-zero field that never moved, so offset 55 is a block level field and
  // Gain's own cell - the first parameter of the effect - is at 63.
  9: <int>[4, 63], // ns
};

/// Whether a block's parameter is an eq gain band in dB rather than a plain
/// 0-100 percentage. Every eq effect is built the same way - five gain bands
/// followed by an optional volume knob - so the band is identified by the
/// block and the parameter's index alone.
bool gp5IsDbBand(int block, int paramIndex) => block == 5 && paramIndex < 5;


/// Length of a patch-data part. Parts 0-3 are 212 bytes; the final
/// "end of patch data" frame is 148 bytes and carries the overflow of the
/// block 8 parameters plus all of block 9.
int gp5PatchPartLength(int part) => part == 4 ? 148 : 212;

/// Some blocks run out of room in their own 212-byte part and continue at
/// the start of the 148-byte final frame. Block 8 keeps two cells in part 3
/// (offsets 199 and 207) and continues at part 4 offset 15; every block is a
/// 64-byte window of eight cells, so 199 and 207 are its first two slots and
/// the remaining six spill into the final frame.
///
/// Block 9 is based in the final frame rather than continuing into it, so it has
/// no tail entry: its own base in [gp5ParamCellBase] already points at part 4.
const Map<int, List<int>> gp5ParamCellBaseTail = <int, List<int>>{
  8: [4, 15],
};

/// The index of a parameter's cell inside its block's cell area.
///
/// This is always the parameter's wire address (`algId`), never its list
/// position. Block 6 Bias Trem was measured with an untouched hole at algId 3
/// and Bias at algId 4, so the storage is algId-indexed even where the ids are
/// sparse, and block 8 follows the same rule across the part boundary:
/// algId 0 is `3:199`, algId 1 is `3:207`, and algId 2 and up continue at
/// `4:15` (so Decay algId 2 is `4:15`, Trail algId 3 is `4:23`, Trail algId 6
/// is `4:47`).
///
/// A device sweep on every reverb measured exactly this: driving a parameter by
/// its `algId` moved the cell at `8 * algId - 1` in the final frame (or
/// `3:199`/`3:207` for algIds 0/1), independent of the parameter's list
/// position. Reading by list position instead shifted Damp and Trail of the
/// four-parameter reverbs one slot early, so Damp read an unused zero and Trail
/// read Damp's value and snapped to On. An invalid `algId` (a sparse hole) is
/// aliased by the pedal onto Mix's cell `3:199`; that is a device quirk of the
/// write, not a second storage location.
int gp5ParamCellIndex(int block, int listIndex, int wireAddress) =>
    wireAddress;

/// Number of parameter cells that still fit inside the block's own part.
int gp5ParamCellsInOwnPart(int block) {
  final base = gp5ParamCellBase[block];
  if (base == null) return 0;
  final length = gp5PatchPartLength(base[0]);
  final offset = base[1];
  var n = 0;
  while (offset + 8 * n + 4 <= length) {
    n++;
  }
  return n;
}

/// Resolves the [part, offset] holding a block's parameter cell, following the
/// block into the 148-byte final frame when its cells run past its own part.
/// Returns null when the cell is outside every part.
List<int>? gp5ParamCellPosition(int block, int paramIndex) {
  final base = gp5ParamCellBase[block];
  if (base == null) return null;
  final inOwnPart = gp5ParamCellsInOwnPart(block);
  if (paramIndex < inOwnPart) {
    return <int>[base[0], base[1] + 8 * paramIndex];
  }
  final tail = gp5ParamCellBaseTail[block];
  if (tail == null) return null;
  final offset = tail[1] + 8 * (paramIndex - inOwnPart);
  if (offset + 4 > gp5PatchPartLength(tail[0])) return null;
  return <int>[tail[0], offset];
}

/// Reverse map of the pedal's 4-byte parameter cells to their normalised
/// 0-100 position. The device quantises every parameter to 101 whole-percent
/// states; each entry is keyed by the cell's bytes read as a little-endian
/// 32-bit value. Generated from a 201-step sweep of the device, in which every
/// step was confirmed stable across repeated reads.
/// The encoding a parameter's cells use, which is also the unit they decode to.
enum Gp5CellFamily {
  /// A plain 0-100 percentage, [gp5ParamCellToPercent].
  percent,

  /// A value from a negative minimum to a positive maximum, stored as the
  /// percentage state of its magnitude plus a sign bit, [gp5DecodeBipolarCell].
  bipolar,

  /// A rate from 0.10 to 10.00 Hz, [gp5CellToRateHz].
  rateHz,

  /// A delay time from 20 to 1000 ms, [gp5CellToDelayTimeMs].
  delayTimeMs,

  /// A small non-negative integer count - the smart harmony's high interval in
  /// semitones - stored on the plain percentage state grid, where the state is
  /// the value rather than a position on a 0-100 scale.
  /// [gp5DecodeRawCountCell].
  rawCount,
}

/// The family a parameter is encoded in, from the range it declares.
///
/// Cell tags overlap between families, so the family cannot be read off a cell
/// and has to come from the parameter. The ranges declared by the effect model
/// are the only ones the device produces, and they partition cleanly: a
/// negative minimum is bipolar, 0.10-10.00 is a rate and a minimum of 20 ms is
/// a delay time, leaving percentages and switches on [Gp5CellFamily.percent].
Gp5CellFamily gp5CellFamily(double minVal, double maxVal,
    {bool isSwitch = false}) {
  if (isSwitch) return Gp5CellFamily.percent;
  if (minVal < 0) return Gp5CellFamily.bipolar;
  if (minVal == 0.1 && maxVal == 10) return Gp5CellFamily.rateHz;
  if (minVal == 20 && maxVal >= 300) return Gp5CellFamily.delayTimeMs;
  if (minVal == 0 && maxVal == 24) return Gp5CellFamily.rawCount;
  return Gp5CellFamily.percent;
}

/// Decodes a [rawCount] cell, or null when the bytes are not a state the device
/// produces for one.
///
/// The cell is one of the plain percentage states, but the state is the count
/// itself rather than a position on a 0-100 scale, so the lookup result is the
/// value and must not be rescaled onto the parameter's range. Measured on
/// device by sweeping the smart harmony's MHigh across its whole range: the
/// pedal reported states 0, 2, 3, 7, 9, 12, 14, 15, 16, 17 and 19 while the
/// parameter ran from 0 to 24 semitones, reaching ~19 at the top rather than
/// the ~100 a normalised percentage would give.
double? gp5DecodeRawCountCell(int cell) => gp5ParamCellToPercent[cell]?.toDouble();

const Map<int, int> gp5ParamCellToPercent = <int, int>{
    0x00000000: 0,
    0x0f030008: 1,
    0x00040000: 2,
    0x00040004: 3,
    0x00040008: 4,
    0x0004000a: 5,
    0x0004000c: 6,
    0x0004000e: 7,
    0x01040000: 8,
    0x01040001: 9,
    0x01040002: 10,
    0x01040003: 11,
    0x01040004: 12,
    0x01040005: 13,
    0x01040006: 14,
    0x01040007: 15,
    0x01040008: 16,
    0x01040808: 17,
    0x01040009: 18,
    0x01040809: 19,
    0x0104000a: 20,
    0x0104080a: 21,
    0x0104000b: 22,
    0x0104080b: 23,
    0x0104000c: 24,
    0x0104080c: 25,
    0x0104000d: 26,
    0x0104080d: 27,
    0x0104000e: 28,
    0x0104080e: 29,
    0x0104000f: 30,
    0x0104080f: 31,
    0x02040000: 32,
    0x02040400: 33,
    0x02040800: 34,
    0x02040c00: 35,
    0x02040001: 36,
    0x02040401: 37,
    0x02040801: 38,
    0x02040c01: 39,
    0x02040002: 40,
    0x02040402: 41,
    0x02040802: 42,
    0x02040c02: 43,
    0x02040003: 44,
    0x02040403: 45,
    0x02040803: 46,
    0x02040c03: 47,
    0x02040004: 48,
    0x02040404: 49,
    0x02040804: 50,
    0x02040c04: 51,
    0x02040005: 52,
    0x02040405: 53,
    0x02040805: 54,
    0x02040c05: 55,
    0x02040006: 56,
    0x02040406: 57,
    0x02040806: 58,
    0x02040c06: 59,
    0x02040007: 60,
    0x02040407: 61,
    0x02040807: 62,
    0x02040c07: 63,
    0x02040008: 64,
    0x02040208: 65,
    0x02040408: 66,
    0x02040608: 67,
    0x02040808: 68,
    0x02040a08: 69,
    0x02040c08: 70,
    0x02040e08: 71,
    0x02040009: 72,
    0x02040209: 73,
    0x02040409: 74,
    0x02040609: 75,
    0x02040809: 76,
    0x02040a09: 77,
    0x02040c09: 78,
    0x02040e09: 79,
    0x0204000a: 80,
    0x0204020a: 81,
    0x0204040a: 82,
    0x0204060a: 83,
    0x0204080a: 84,
    0x02040a0a: 85,
    0x02040c0a: 86,
    0x02040e0a: 87,
    0x0204000b: 88,
    0x0204020b: 89,
    0x0204040b: 90,
    0x0204060b: 91,
    0x0204080b: 92,
    0x02040a0b: 93,
    0x02040c0b: 94,
    0x02040e0b: 95,
    0x0204000c: 96,
    0x0204020c: 97,
    0x0204040c: 98,
    0x0204060c: 99,
    0x0204080c: 100,
};

/// The device's rate-in-Hz encoding, as the cell each rate produces.
///
/// A modulation rate is not a percentage: it runs from 0.10 Hz to 10.00 Hz, on
/// a logarithmic grid that the device quantises into 100 states of 0.1 Hz. The
/// states are not spaced evenly, so the mapping is tabulated rather than
/// computed. The grid is shared: writing 0.5 Hz produced the same cell in the
/// touch wah (block 1) as it did in the chorus (block 6).

const Map<int, double> gp5CellToRateHz = <int, double>{
  0x0d030c0c: 0.1,
  0x0e030c04: 0.2,
  0x0e030909: 0.3,
  0x0e030c0c: 0.4,
  0x0f030000: 0.5,
  0x0f030901: 0.6,
  0x0f030303: 0.7,
  0x0f030c04: 0.8,
  0x0f030606: 0.9,
  0x0f030008: 1,
  0x0f030c08: 1.1,
  0x0f030909: 1.2,
  0x0f03060a: 1.3,
  0x0f03030b: 1.4,
  0x0f03000c: 1.5,
  0x0f030c0c: 1.6,
  0x0f03090d: 1.7,
  0x0f03060e: 1.8,
  0x0f03030f: 1.9,
  0x00040000: 2,
  0x00040600: 2.1,
  0x00040c00: 2.2,
  0x00040301: 2.3,
  0x00040901: 2.4,
  0x00040002: 2.5,
  0x00040602: 2.6,
  0x00040c02: 2.7,
  0x00040303: 2.8,
  0x00040903: 2.9,
  0x00040004: 3,
  0x00040604: 3.1,
  0x00040c04: 3.2,
  0x00040305: 3.3,
  0x00040905: 3.4,
  0x00040006: 3.5,
  0x00040606: 3.6,
  0x00040c06: 3.7,
  0x00040307: 3.8,
  0x00040907: 3.9,
  0x00040008: 4,
  0x00040308: 4.1,
  0x00040608: 4.2,
  0x00040908: 4.3,
  0x00040c08: 4.4,
  0x00040009: 4.5,
  0x00040309: 4.6,
  0x00040609: 4.7,
  0x00040909: 4.8,
  0x00040c09: 4.9,
  0x0004000a: 5,
  0x0004030a: 5.1,
  0x0004060a: 5.2,
  0x0004090a: 5.3,
  0x00040c0a: 5.4,
  0x0004000b: 5.5,
  0x0004030b: 5.6,
  0x0004060b: 5.7,
  0x0004090b: 5.8,
  0x00040c0b: 5.9,
  0x0004000c: 6,
  0x0004030c: 6.1,
  0x0004060c: 6.2,
  0x0004090c: 6.3,
  0x00040c0c: 6.4,
  0x0004000d: 6.5,
  0x0004030d: 6.6,
  0x0004060d: 6.7,
  0x0004090d: 6.8,
  0x00040c0d: 6.9,
  0x0004000e: 7,
  0x0004030e: 7.1,
  0x0004060e: 7.2,
  0x0004090e: 7.3,
  0x00040c0e: 7.4,
  0x0004000f: 7.5,
  0x0004030f: 7.6,
  0x0004060f: 7.7,
  0x0004090f: 7.8,
  0x00040c0f: 7.9,
  0x01040000: 8,
  0x01040100: 8.1,
  0x01040300: 8.2,
  0x01040400: 8.3,
  0x01040600: 8.4,
  0x01040800: 8.5,
  0x01040900: 8.6,
  0x01040b00: 8.7,
  0x01040c00: 8.8,
  0x01040e00: 8.9,
  0x01040001: 9,
  0x01040101: 9.1,
  0x01040301: 9.2,
  0x01040401: 9.3,
  0x01040601: 9.4,
  0x01040801: 9.5,
  0x01040901: 9.6,
  0x01040b01: 9.7,
  0x01040c01: 9.8,
  0x01040e01: 9.9,
  0x01040002: 10,
};
/// The device's delay-time-in-ms encoding, as the cell each time produces.
///
/// A delay time runs from 20 ms to 1000 ms, quantised into 99 states of 10 ms,
/// on a grid that is not evenly spaced. The grid is absolute rather than
/// per-effect: writing 20, 150 and 300 ms produced the same cells in the slap
/// delay, whose range stops at 300 ms, as they did in the analog delay.

const Map<int, double> gp5CellToDelayTimeMs = <int, double>{
  0x0104000a: 20,
  0x0104000f: 30,
  0x02040002: 40,
  0x02040804: 50,
  0x02040007: 60,
  0x02040c08: 70,
  0x0204000a: 80,
  0x0204040b: 90,
  0x0204080c: 100,
  0x02040c0d: 110,
  0x0204000f: 120,
  0x03040200: 130,
  0x03040c00: 140,
  0x03040601: 150,
  0x03040002: 160,
  0x03040a02: 170,
  0x03040403: 180,
  0x03040e03: 190,
  0x03040804: 200,
  0x03040205: 210,
  0x03040c05: 220,
  0x03040606: 230,
  0x03040007: 240,
  0x03040a07: 250,
  0x03040208: 260,
  0x03040708: 270,
  0x03040c08: 280,
  0x03040109: 290,
  0x03040609: 300,
  0x03040b09: 310,
  0x0304000a: 320,
  0x0304050a: 330,
  0x03040a0a: 340,
  0x03040f0a: 350,
  0x0304040b: 360,
  0x0304090b: 370,
  0x03040e0b: 380,
  0x0304030c: 390,
  0x0304080c: 400,
  0x03040d0c: 410,
  0x0304020d: 420,
  0x0304070d: 430,
  0x03040c0d: 440,
  0x0304010e: 450,
  0x0304060e: 460,
  0x03040b0e: 470,
  0x0304000f: 480,
  0x0304050f: 490,
  0x03040a0f: 500,
  0x03040f0f: 510,
  0x04040200: 520,
  0x04040400: 530,
  0x04040700: 540,
  0x04040900: 550,
  0x04040c00: 560,
  0x04040e00: 570,
  0x04040101: 580,
  0x04040301: 590,
  0x04040601: 600,
  0x04040801: 610,
  0x04040b01: 620,
  0x04040d01: 630,
  0x04040002: 640,
  0x04040202: 650,
  0x04040502: 660,
  0x04040702: 670,
  0x04040a02: 680,
  0x04040c02: 690,
  0x04040f02: 700,
  0x04040103: 710,
  0x04040403: 720,
  0x04040603: 730,
  0x04040903: 740,
  0x04040b03: 750,
  0x04040e03: 760,
  0x04040004: 770,
  0x04040304: 780,
  0x04040504: 790,
  0x04040804: 800,
  0x04040a04: 810,
  0x04040d04: 820,
  0x04040f04: 830,
  0x04040205: 840,
  0x04040405: 850,
  0x04040705: 860,
  0x04040905: 870,
  0x04040c05: 880,
  0x04040e05: 890,
  0x04040106: 900,
  0x04040306: 910,
  0x04040606: 920,
  0x04040806: 930,
  0x04040b06: 940,
  0x04040d06: 950,
  0x04040007: 960,
  0x04040207: 970,
  0x04040507: 980,
  0x04040707: 990,
  0x04040a07: 1000,
};/// The little-endian 32-bit cell at [offset] of [b], or null when [offset] does
/// not fit inside [b].
///
/// The bytes are read in the order they appear on the wire.
int? gp5CellAt(List<int> b, int offset) {
  if (offset < 0 || offset + 4 > b.length) return null;
  return b[offset] |
      (b[offset + 1] << 8) |
      (b[offset + 2] << 16) |
      (b[offset + 3] << 24);
}

/// Decodes [cell] as a plain percentage position, or null when the bytes are
/// not a state the device produces.
double? gp5DecodePercentCell(int cell) => gp5ParamCellToPercent[cell]?.toDouble();

/// Decodes a bipolar cell into its value in its own unit - dB, cents or
/// semitones - or null when the bytes are not a state such a parameter
/// produces.
///
/// A bipolar parameter is stored as the plain percentage state of its
/// magnitude, so +10 and -10 share the magnitude state of 10 and the negative
/// half is marked by setting bit 3 of the tag byte, which is byte 2 of the
/// cell. Clearing that bit before the lookup recovers the magnitude, and the
/// cleared value is the magnitude itself rather than a 0-100 position.
///
/// Magnitudes above 50 are rejected: no bipolar parameter in the effect model
/// reaches that far, so a cell that decodes that high is not one of them.
double? gp5DecodeBipolarCell(int cell) {
  const signBit = 0x00080000;
  final magnitude = gp5ParamCellToPercent[cell & ~signBit];
  if (magnitude == null || magnitude > 50) return null;
  if (magnitude == 0) return 0;
  return (cell & signBit) == 0 ? magnitude.toDouble() : -magnitude.toDouble();
}

/// Decodes [cell] in [family]'s own unit, or null when the bytes are not a
/// state that family produces.
double? gp5DecodeCell(Gp5CellFamily family, int cell) {
  switch (family) {
    case Gp5CellFamily.percent:
      return gp5DecodePercentCell(cell);
    case Gp5CellFamily.bipolar:
      return gp5DecodeBipolarCell(cell);
    case Gp5CellFamily.rateHz:
      return gp5CellToRateHz[cell];
    case Gp5CellFamily.delayTimeMs:
      return gp5CellToDelayTimeMs[cell];
    case Gp5CellFamily.rawCount:
      return gp5DecodeRawCountCell(cell);
  }
}
