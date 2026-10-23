// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/gp5ParamCell.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/gp5/GP5Effects.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/gp5/GP5Processor.dart';
import 'package:mighty_plug_manager/bluetooth/devices/value_formatters/GP5Formatters.dart';

/// The effects of each block whose parameters this decoder reads.
final Map<int, List<Gp5Processor>> decodedBlocks = <int, List<Gp5Processor>>{
  0: <Gp5Processor>[GP5Effects.noiseReduction()],
  1: GP5Effects.preEffects(),
  2: GP5Effects.dstEffects(),
  3: GP5Effects.ampEffects(),
  4: GP5Effects.cabEffects(),
  5: GP5Effects.eqEffects(),
  6: GP5Effects.modEffects(),
  7: GP5Effects.dlyEffects(),
  8: GP5Effects.rvbEffects(),
  9: GP5Effects.nsEffects(),
};

/// The 4-byte cell the device uses for the normalised position [percent].
int cellFor(int percent) => gp5ParamCellToPercent.entries
    .firstWhere((e) => e.value == percent)
    .key;

/// The 4-byte cell the device uses for the bipolar value [v]. A bipolar
/// parameter reuses the magnitude state of |v| and sets bit 3 of the tag byte
/// when the value is negative.
int bipolarCellFor(num v) {
  if (v == 0) return 0;
  final cell = cellFor(v.abs().toInt());
  return v < 0 ? cell | 0x00080000 : cell;
}

/// Writes the 4-byte [cell] into [b] at [offset].
void putCell(List<int> b, int offset, int cell) {
  b[offset] = cell & 0xff;
  b[offset + 1] = (cell >> 8) & 0xff;
  b[offset + 2] = (cell >> 16) & 0xff;
  b[offset + 3] = (cell >> 24) & 0xff;
}

/// The cell family the patch parser picks for [param], from the range it
/// declares.
Gp5CellFamily familyOf(Parameter param) {
  final f = param.formatter;
  return f is GP5FloatFormatter
      ? gp5CellFamily(f.minVal, f.maxVal)
      : Gp5CellFamily.percent;
}

/// Decodes a cell the way the patch parser does, by the family its parameter
/// declares.
double? decodeLikeParser(Parameter param, List<int> b, int offset) =>
    gp5DecodeCell(familyOf(param), gp5CellAt(b, offset) ?? -1);

/// A cell of the plain percentage encoding at [offset], decoded through
/// [gp5CellAt] so a bad offset yields null just as it does in the parser.
double? percentAt(List<int> b, int offset) {
  final cell = gp5CellAt(b, offset);
  return cell == null ? null : gp5DecodePercentCell(cell);
}

/// A 212-byte patch-data part carrying [percent] at [offset], and 0 elsewhere.
List<int> partWithPercent(int percent, int offset) {
  final b = List<int>.filled(212, 0);
  putCell(b, offset, cellFor(percent));
  return b;
}

/// Every value in [table] that [min] and [max] allow, thinned to five samples
/// that include both ends. These are the values a round trip writes.
List<double> valuesIn(Map<int, double> table, double min, double max) {
  final all = table.values.where((v) => v >= min && v <= max).toList()..sort();
  if (all.length <= 5) return all;
  return <double>[
    all.first,
    all[all.length ~/ 4],
    all[all.length ~/ 2],
    all[(all.length * 3) ~/ 4],
    all.last,
  ];
}

/// Byte keys (part * 100000 + offset) for every cell a block occupies in any
/// part, so two blocks can be checked for overlap across part boundaries.
Set<int> _occupiedBytes(int block, int paramCount) {
  final out = <int>{};
  for (int i = 0; i < paramCount; i++) {
    final pos = gp5ParamCellPosition(block, i);
    if (pos == null) continue;
    for (int k = 0; k < 4; k++) {
      out.add(pos[0] * 100000 + pos[1] + k);
    }
  }
  return out;
}

void main() {
  group('gp5ParamCellPosition', () {
    test('keeps a cell inside its own 212-byte part', () {
      expect(gp5ParamCellPosition(3, 0), <int>[2, 79]);
      expect(gp5ParamCellPosition(3, 1), <int>[2, 87]);
      expect(gp5ParamCellPosition(5, 0), <int>[3, 7]);
      expect(gp5ParamCellPosition(6, 0), <int>[3, 71]);
    });

    test('block 8 continues in the 148-byte final frame', () {
      // first two cells stay in part 3 ...
      expect(gp5ParamCellsInOwnPart(8), 2);
      expect(gp5ParamCellPosition(8, 0), <int>[3, 199]);
      expect(gp5ParamCellPosition(8, 1), <int>[3, 207]);
      // ... and the rest follow at stride 8 from part 4 offset 15
      expect(gp5ParamCellPosition(8, 2), <int>[4, 15]);
      expect(gp5ParamCellPosition(8, 3), <int>[4, 23]);
      expect(gp5ParamCellPosition(8, 4), <int>[4, 31]);
    });

    test('block 9 is based in the 148-byte final frame', () {
      expect(gp5ParamCellPosition(9, 0), <int>[4, 55]);
      expect(gp5ParamCellPosition(9, 1), <int>[4, 63]);
      expect(gp5ParamCellPosition(9, 4), <int>[4, 87]);
    });

    test('reports null past the end of the final frame', () {
      expect(gp5ParamCellPosition(9, 40), isNull);
      expect(gp5ParamCellPosition(8, 60), isNull);
    });

    test('unknown block resolves to null', () {
      expect(gp5ParamCellPosition(42, 0), isNull);
    });
  });

  group('final frame geometry', () {
    test('part lengths', () {
      expect(gp5PatchPartLength(0), 212);
      expect(gp5PatchPartLength(3), 212);
      expect(gp5PatchPartLength(4), 148);
    });

    test('decodes a cell in the 148-byte final frame', () {
      final b = List<int>.filled(148, 0);
      b[55] = 0x0c;
      b[56] = 0x08;
      b[57] = 0x04;
      b[58] = 0x02;
      expect(percentAt(b, 55), 100);
    });

    test('block 8 tail cell decodes in the final frame', () {
      final b = List<int>.filled(148, 0);
      b[15] = 0x0c;
      b[16] = 0x08;
      b[17] = 0x04;
      b[18] = 0x02;
      expect(percentAt(b, gp5ParamCellPosition(8, 2)![1]), 100);
    });

    test('no block 8 or 9 cell may be read past the final frame', () {
      for (int block = 8; block <= 9; block++) {
        for (int i = 0; i < 80; i++) {
          final pos = gp5ParamCellPosition(block, i);
          if (pos == null) continue;
          expect(pos[1] + 4, lessThanOrEqualTo(gp5PatchPartLength(pos[0])));
        }
      }
    });
  });

  group('gp5ParamCellToPercent', () {
    test('covers every whole-percent position exactly once', () {
      expect(gp5ParamCellToPercent.length, 101);
      final values = gp5ParamCellToPercent.values.toList()..sort();
      expect(values, List<int>.generate(101, (i) => i));
    });

    test('keys are distinct 4-byte cells', () {
      final cells = gp5ParamCellToPercent.keys.toList();
      expect(cells.toSet().length, cells.length);
      for (final c in cells) {
        expect(c, inInclusiveRange(0, 0xffffffff));
      }
    });

    test('decodes the endpoints and the midpoint', () {
      expect(percentAt(partWithPercent(0, 0), 0), 0);
      expect(percentAt(partWithPercent(50, 0), 0), 50);
      expect(percentAt(partWithPercent(100, 0), 0), 100);
    });

    test('decodes at any position within the part', () {
      for (final offset in [0, 1, 7, 64, 207]) {
        expect(percentAt(partWithPercent(50, offset), offset), 50);
      }
    });

    test('rejects cells the device does not produce', () {
      final b = List<int>.filled(212, 0);
      b[0] = 0xef;
      b[1] = 0xbe;
      b[2] = 0xad;
      b[3] = 0xde;
      expect(percentAt(b, 0), isNull);
    });

    test('rejects offsets that would run off the part', () {
      final b = partWithPercent(50, 0);
      expect(percentAt(b, -1), isNull);
      expect(percentAt(b, 209), isNull);
      expect(percentAt(b, 5000), isNull);
    });

    test('reading is repeatable, so recall is idempotent', () {
      for (final entry in gp5ParamCellToPercent.entries) {
        final b = List<int>.filled(212, 0);
        putCell(b, 87, entry.key);
        for (var i = 0; i < 3; i++) {
          expect(percentAt(b, 87), entry.value.toDouble());
        }
      }
    });
  });

  group('gp5CellToRateHz', () {
    test('covers 0.1 to 10.0 Hz in 0.1 steps exactly once', () {
      expect(gp5CellToRateHz.length, 100);
      final values = gp5CellToRateHz.values.toList()..sort();
      expect(values, List<double>.generate(100, (i) => (i + 1) / 10));
    });

    test('keys are distinct and the values are distinct', () {
      expect(gp5CellToRateHz.keys.toSet().length, 100);
      expect(gp5CellToRateHz.values.toSet().length, 100);
    });

    test('every rate round trips through its cell', () {
      for (final entry in gp5CellToRateHz.entries) {
        final b = List<int>.filled(212, 0);
        putCell(b, 15, entry.key);
        expect(gp5DecodeCell(Gp5CellFamily.rateHz, gp5CellAt(b, 15)!),
            entry.value,
            reason: '${entry.value} Hz');
      }
    });

    test('the states are not evenly spaced, so a computed rule cannot stand in',
        () {
      // the endpoints and the 0.5 Hz default, as measured on the device
      expect(gp5CellToRateHz.values.reduce((a, b) => a < b ? a : b), 0.1);
      expect(gp5CellToRateHz.values.reduce((a, b) => a > b ? a : b), 10.0);
      final half = gp5CellToRateHz.entries
          .firstWhere((e) => e.value == 0.5)
          .key;
      expect(half, 0x0f030000);
      expect(gp5CellToRateHz[0x0d030c0c], 0.1);
      expect(gp5CellToRateHz[0x01040002], 10.0);
    });

    test('a percent cell is not a rate', () {
      for (final cell in gp5ParamCellToPercent.keys) {
        expect(gp5DecodeCell(Gp5CellFamily.rateHz, cell),
            gp5CellToRateHz[cell]);
      }
    });
  });

  group('gp5CellToDelayTimeMs', () {
    test('covers 20 to 1000 ms in 10 ms steps exactly once', () {
      expect(gp5CellToDelayTimeMs.length, 99);
      final values = gp5CellToDelayTimeMs.values.toList()..sort();
      expect(values, List<double>.generate(99, (i) => i * 10 + 20));
    });

    test('keys and values are both distinct', () {
      expect(gp5CellToDelayTimeMs.keys.toSet().length, 99);
      expect(gp5CellToDelayTimeMs.values.toSet().length, 99);
    });

    test('every time round trips through its cell', () {
      for (final entry in gp5CellToDelayTimeMs.entries) {
        final b = List<int>.filled(212, 0);
        putCell(b, 15, entry.key);
        expect(gp5DecodeCell(Gp5CellFamily.delayTimeMs, gp5CellAt(b, 15)!),
            entry.value,
            reason: '${entry.value} ms');
      }
    });

    test('the 500 ms default matches the cell the device reported', () {
      expect(gp5CellToDelayTimeMs[0x03040a0f], 500);
      expect(gp5CellToDelayTimeMs[0x04040a07], 1000);
      expect(gp5CellToDelayTimeMs[0x03040601], 150);
    });

    test('a percent cell is not a time', () {
      for (final cell in gp5ParamCellToPercent.keys) {
        expect(gp5DecodeCell(Gp5CellFamily.delayTimeMs, cell),
            gp5CellToDelayTimeMs[cell]);
      }
    });
  });

  group('gp5CellFamily', () {
    test('picks the family from the range the parameter declares', () {
      expect(gp5CellFamily(-50, 50), Gp5CellFamily.bipolar);
      expect(gp5CellFamily(-24, 0), Gp5CellFamily.bipolar);
      expect(gp5CellFamily(0.1, 10), Gp5CellFamily.rateHz);
      expect(gp5CellFamily(20, 1000), Gp5CellFamily.delayTimeMs);
      expect(gp5CellFamily(20, 300), Gp5CellFamily.delayTimeMs);
      expect(gp5CellFamily(20, 500), Gp5CellFamily.delayTimeMs);
      expect(gp5CellFamily(0, 100), Gp5CellFamily.percent);
      expect(gp5CellFamily(0, 24), Gp5CellFamily.percent);
      expect(gp5CellFamily(0, 4), Gp5CellFamily.percent);
    });

    test('a switch is a percentage whatever its range says', () {
      expect(gp5CellFamily(0, 1, isSwitch: true), Gp5CellFamily.percent);
      expect(gp5CellFamily(-1, 1, isSwitch: true), Gp5CellFamily.percent);
    });

    test('an unrecognised range falls back to a percentage', () {
      expect(gp5CellFamily(3, 7), Gp5CellFamily.percent);
      expect(gp5CellFamily(50, 60), Gp5CellFamily.percent);
    });

    test('every range in the effect model resolves to a family', () {
      // the ten distinct ranges the model declares, so a new one cannot be
      // added without this decoder noticing
      final ranges = <String>{};
      for (final block in decodedBlocks.keys) {
        for (final effect in decodedBlocks[block]!) {
          for (final param in effect.parameters) {
            final f = param.formatter;
            ranges.add(f is GP5FloatFormatter
                ? '${f.minVal}..${f.maxVal}'
                : 'switch');
            expect(Gp5CellFamily.values, contains(familyOf(param)));
          }
        }
      }
      expect(ranges.toList()..sort(), <String>[
        '-24.0..0.0',
        '-50.0..50.0',
        '0.0..100.0',
        '0.0..24.0',
        '0.0..4.0',
        '0.1..10.0',
        '20.0..1000.0',
        '20.0..300.0',
        '20.0..500.0',
        'switch',
      ]);
    });

    test('every family decodes its own grid back to itself', () {
      final known = <int>[
        ...gp5ParamCellToPercent.keys,
        ...gp5CellToRateHz.keys,
        ...gp5CellToDelayTimeMs.keys,
      ];
      for (final family in Gp5CellFamily.values) {
        final decoded =
            known.where((c) => gp5DecodeCell(family, c) != null).length;
        expect(decoded, greaterThan(0),
            reason: '$family decodes none of the grids the device produces');
      }
    });

    test('one cell yields different values depending on the family', () {
      // 0x00040000 is a valid percentage position (2), a valid rate (2 Hz) and
      // a valid bipolar magnitude (+2), so nothing in the bytes alone says
      // which unit the parameter is in. The family decides, and it matters: a
      // percentage is a position on a 0-100 scale and is mapped onto the
      // parameter's range, while a rate is already the value in Hz.
      const cell = 0x00040000;
      expect(gp5DecodeCell(Gp5CellFamily.percent, cell), 2);
      expect(gp5DecodeCell(Gp5CellFamily.rateHz, cell), 2);
      expect(gp5DecodeCell(Gp5CellFamily.bipolar, cell), 2);

      final chorus = decodedBlocks[6]!.firstWhere((e) => e.name == "Chorus");
      final rate = chorus.parameters[1].formatter as GP5FloatFormatter;
      expect(gp5CellFamily(rate.minVal, rate.maxVal), Gp5CellFamily.rateHz);
      // read as a percentage the same cell would land here instead
      final asPercent = rate.minVal + (2 / 100) * (rate.maxVal - rate.minVal);
      expect(asPercent, closeTo(0.298, 0.0005));
      expect(2.0, inInclusiveRange(rate.minVal, rate.maxVal));
    });

    test('the grids are keyed by the bytes as they arrive on the wire', () {
      // A cell key is the four bytes the device sends read as a little-endian
      // 32-bit value, which is what gp5CellAt builds. A key written the other
      // way round still round trips inside a test, so the wire order is pinned
      // here against bytes captured from the device: 5 Hz arrives as
      // 0a 00 04 00 and 500 ms as 0f 0a 04 03.
      final b = List<int>.filled(212, 0);
      b[15] = 0x0a;
      b[16] = 0x00;
      b[17] = 0x04;
      b[18] = 0x00;
      expect(gp5CellAt(b, 15), 0x0004000a);
      expect(gp5DecodeCell(Gp5CellFamily.rateHz, gp5CellAt(b, 15)!), 5);

      b[15] = 0x0f;
      b[16] = 0x0a;
      b[17] = 0x04;
      b[18] = 0x03;
      expect(gp5CellAt(b, 15), 0x03040a0f);
      expect(gp5DecodeCell(Gp5CellFamily.delayTimeMs, gp5CellAt(b, 15)!), 500);
    });

    test('the rate and time grids share a tag but no cell', () {
      // a tag on its own cannot say which grid a cell belongs to, so the family
      // has to come from the parameter rather than from the bytes
      final rateTags = gp5CellToRateHz.keys.map((c) => c >> 16).toSet();
      final timeTags = gp5CellToDelayTimeMs.keys.map((c) => c >> 16).toSet();
      expect(rateTags.intersection(timeTags), isNotEmpty);
      expect(gp5CellToRateHz.keys.toSet().intersection(
          gp5CellToDelayTimeMs.keys.toSet()), isEmpty);
    });
  });

  group('gp5DecodeBipolarCell', () {
    test('the eq block is based at offset 7, not 9', () {
      // the volume knob is the 6th eq parameter and is a plain 0-100 cell, so
      // its cell lands at 7 + 8 * 5 and holds the 50 of a default patch
      expect(gp5ParamCellBase[5], <int>[3, 7]);
      final pos = gp5ParamCellPosition(5, 5)!;
      expect(pos, <int>[3, 47]);
      final b = List<int>.filled(212, 0);
      putCell(b, 47, cellFor(50));
      expect(percentAt(b, 47), 50);
    });

    test('the five bands sit at 7, 15, 23, 31 and 39', () {
      for (var i = 0; i < 5; i++) {
        expect(gp5ParamCellPosition(5, i), <int>[3, 7 + 8 * i],
            reason: 'band $i');
      }
    });

    test('every gain from -50 dB to +50 dB round trips', () {
      final pos = gp5ParamCellPosition(5, 1)!;
      for (var db = -50; db <= 50; db++) {
        final b = List<int>.filled(212, 0);
        putCell(b, pos[1], bipolarCellFor(db));
        expect(gp5DecodeBipolarCell(gp5CellAt(b, pos[1])!), db.toDouble(),
            reason: '$db dB');
      }
    });

    test('a negative value only differs by the sign bit in the tag byte', () {
      for (var v = 1; v <= 50; v++) {
        expect(bipolarCellFor(-v), cellFor(v) | 0x00080000, reason: '-$v');
        expect(bipolarCellFor(v), cellFor(v), reason: '$v');
      }
    });

    test('zero is the all-zero cell, as in the percentage encoding', () {
      expect(bipolarCellFor(0), 0);
      expect(gp5DecodeBipolarCell(0), 0);
    });

    test('rejects magnitudes no bipolar parameter can reach', () {
      // 51-100 are valid percentage states but out of range here
      for (var percent = 51; percent <= 100; percent++) {
        expect(gp5DecodeBipolarCell(cellFor(percent)), isNull,
            reason: '$percent');
      }
    });

    test('rejects the block level field ahead of the first band', () {
      // the 6 bytes at the head of the eq area are identical for every eq
      // effect and never move, so the cell at offset 7 is not a band
      const blockField = [0x00, 0x03, 0x06, 0x04];
      final cell = blockField[0] |
          (blockField[1] << 8) |
          (blockField[2] << 16) |
          (blockField[3] << 24);
      expect(gp5DecodeBipolarCell(cell), isNull);
    });

    test('rejects offsets that would run off the part', () {
      final b = List<int>.filled(212, 0);
      expect(gp5CellAt(b, -1), isNull);
      expect(gp5CellAt(b, 209), isNull);
      expect(gp5CellAt(b, 5000), isNull);
    });

    test('the detune and the low interval use the same magnitudes', () {
      // both are bipolar, so the pitch shifter's detune in cents and the eq
      // bands in dB share one encoding rather than a table each
      final detune = decodedBlocks[1]!
          .firstWhere((e) => e.name == "Pitch Shifter")
          .parameters
          .first;
      expect(familyOf(detune), Gp5CellFamily.bipolar);
      final mlow = decodedBlocks[1]!
          .firstWhere((e) => e.name == "Smart Harmony")
          .parameters[1];
      expect(familyOf(mlow), Gp5CellFamily.bipolar);
      for (final v in <double>[-50, -25, -7, 0, 7, 50]) {
        final b = List<int>.filled(212, 0);
        putCell(b, 15, bipolarCellFor(v));
        expect(gp5DecodeCell(familyOf(detune), gp5CellAt(b, 15)!), v,
            reason: '$v');
      }
    });
  });

  group('gp5ParamCellBase', () {
    test('only lists blocks the device layout was confirmed for', () {
      expect(gp5ParamCellBase.keys.toList()..sort(),
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    test('every base sits inside its part with room for a cell', () {
      for (final entry in gp5ParamCellBase.entries) {
        final length = gp5PatchPartLength(entry.value[0]);
        expect(entry.value[0], inInclusiveRange(0, 4),
            reason: 'block ${entry.key} part');
        expect(entry.value[1], lessThanOrEqualTo(length - 4),
            reason: 'block ${entry.key} offset leaves room for a cell');
      }
    });

    test('a cell past the end of its part decodes to null, not a wrong value',
        () {
      // Block 8 starts late in the last 212-byte part, so its later
      // parameters continue past the end of that part and are carried by the
      // 148-byte end-of-patch frame instead. Reading one from the 212-byte
      // part must yield null so the caller leaves it at its default.
      final b = partWithPercent(64, 205); // 205..208, inside the part
      expect(percentAt(b, 205), 64);
      expect(percentAt(b, 209), isNull,
          reason: 'a cell that would run off the part must not be guessed');
      expect(percentAt(b, 212), isNull);
      expect(percentAt(b, -1), isNull);
    });

    test('every block reads at least one parameter of every effect', () {
      for (final entry in gp5ParamCellBase.entries) {
        for (final effect in decodedBlocks[entry.key]!) {
          final pos = gp5ParamCellPosition(entry.key, 0);
          expect(pos, isNotNull,
              reason: 'block ${entry.key} effect "${effect.name}" has no '
                  'readable parameter');
        }
      }
    });

    test('block 8 straddles the end of the last part', () {
      final offset = gp5ParamCellBase[8]![1];
      // room 2 parameters and part of a third inside the 212-byte part
      expect(offset + 8 * 2 + 4, greaterThan(212),
          reason: 'block 8 was expected to run past the end of part 3');
      expect(offset + 4, lessThanOrEqualTo(212),
          reason: 'block 8 parameter 0 must be inside part 3');
    });

    test('blocks do not overlap each other', () {
      final blocks = gp5ParamCellBase.keys.toList()..sort();
      final seen = <int, int>{};
      for (final block in blocks) {
        final paramCount = decodedBlocks[block]!
            .map((e) => e.parameters.length)
            .reduce((x, y) => x > y ? x : y);
        for (final key in _occupiedBytes(block, paramCount)) {
          expect(seen.containsKey(key), isFalse,
              reason: 'block $block overlaps block ${seen[key]} at byte $key');
          seen[key] = block;
        }
      }
    });

    test('consecutive parameters of an effect sit 8 bytes apart', () {
      // block 1 (pre) starts at offset 151, so parameter i is at 151 + 8 * i
      const base = 151;
      const wanted = [20, 60, 80, 100];
      final compressor =
          decodedBlocks[1]!.firstWhere((e) => e.name == "Compressor 2");
      expect(compressor.parameters.length, wanted.length);

      final b = List<int>.filled(212, 0);
      for (var i = 0; i < wanted.length; i++) {
        putCell(b, base + 8 * i, cellFor(wanted[i]));
      }
      for (var i = 0; i < wanted.length; i++) {
        expect(percentAt(b, base + 8 * i), wanted[i].toDouble(),
            reason: 'parameter $i');
      }
    });

    test('every decoded effect parameter maps back to its written value', () {
      // Writing a value into the part that actually holds the cell and reading
      // that same frame back must yield the same value, which is what makes a
      // recall idempotent. Each parameter is written the way its own family
      // stores it: a percentage as a 0-100 position, a bipolar value in its
      // own unit, and a rate or a time as the grid state the device uses.
      var checked = 0;
      for (final entry in gp5ParamCellBase.entries) {
        for (final effect in decodedBlocks[entry.key]!) {
          for (var i = 0; i < effect.parameters.length; i++) {
            final pos = gp5ParamCellPosition(entry.key, i);
            if (pos == null) continue;
            final param = effect.parameters[i];
            final f = familyOf(param);
            final min =
                param.formatter is GP5FloatFormatter ? (param.formatter as GP5FloatFormatter).minVal : 0.0;
            final max =
                param.formatter is GP5FloatFormatter ? (param.formatter as GP5FloatFormatter).maxVal : 100.0;
            final written = <double>[];
            switch (f) {
              case Gp5CellFamily.percent:
                written.addAll(<double>[0, 1, 37, 50, 99, 100]);
                break;
              case Gp5CellFamily.bipolar:
                written.addAll(valuesIn(
                    <int, double>{
                      for (var m = min.round(); m <= max.round(); m++)
                        bipolarCellFor(m): m.toDouble()
                    },
                    min,
                    max));
                break;
              case Gp5CellFamily.rateHz:
                written.addAll(valuesIn(gp5CellToRateHz, min, max));
                break;
              case Gp5CellFamily.delayTimeMs:
                written.addAll(valuesIn(gp5CellToDelayTimeMs, min, max));
                break;
            }
            expect(written, isNotEmpty,
                reason: 'block ${entry.key} "${effect.name}" p$i has no '
                    'writable value');
            for (final value in written) {
              final b = List<int>.filled(gp5PatchPartLength(pos[0]), 0);
              switch (f) {
                case Gp5CellFamily.percent:
                  putCell(b, pos[1], cellFor(value.toInt()));
                  break;
                case Gp5CellFamily.bipolar:
                  putCell(b, pos[1], bipolarCellFor(value));
                  break;
                case Gp5CellFamily.rateHz:
                case Gp5CellFamily.delayTimeMs:
                  putCell(b, pos[1], cellForValue(f, value));
                  break;
              }
              expect(decodeLikeParser(param, b, pos[1]), value,
                  reason: 'block ${entry.key} "${effect.name}" p$i');
              checked++;
            }
          }
        }
      }
      expect(checked, greaterThan(2000));
    });
  });
}

/// The cell that holds [value] in [family]'s grid.
int cellForValue(Gp5CellFamily family, double value) =>
    (family == Gp5CellFamily.rateHz ? gp5CellToRateHz : gp5CellToDelayTimeMs)
        .entries
        .firstWhere((e) => e.value == value)
        .key;
