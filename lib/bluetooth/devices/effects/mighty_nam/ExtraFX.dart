import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

const List<String> extraFxNames = [
  'Pitch',
  'Auto Wah',
  'Chorus',
  'Flanger',
  'Phaser',
  'Tremolo',
  'Vibrato'
];

/// Formats semitones (-12..+12 semitones), Hertz (0.05..8.00 Hz), and percentages.
class FxValueFormatter extends ValueFormatter {
  final int index;
  FxValueFormatter(this.index);

  @override
  InputType get inputType => InputType.SliderInput;

  @override
  int get min => 0;

  @override
  int get max => index == 3 ? 24 : 100;

  @override
  int valueToMidi7Bit(double value) => value.round();

  @override
  double midi7BitToValue(int midi7bit) => midi7bit.toDouble();

  @override
  String toLabel(double value) {
    if (index == 3) {
      final semitones = value.round() - 12;
      final sign = semitones > 0 ? '+' : '';
      return '$sign$semitones semitones';
    } else if (index == 5) {
      final hz = 0.05 + 7.95 * value / 100;
      return '${hz.toStringAsFixed(2)} Hz';
    }
    return '${value.round()}%';
  }
}

abstract class NamExtraFX extends Processor {
  @override
  final int nuxIndex;

  @override
  String get name => extraFxNames[nuxIndex - 1];

  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;

  @override
  int get midiCCEnableValue => -1;

  @override
  int get midiCCSelectionValue => -1;

  @override
  int? get nuxEffectTypeIndex => null;

  @override
  int? get nuxEnableIndex => null;

  @override
  MidiControllerHandle? get midiControlOff => null;
  @override
  MidiControllerHandle? get midiControlOn => null;
  @override
  MidiControllerHandle? get midiControlToggle => null;
  @override
  MidiControllerHandle? get midiControlPrev => null;
  @override
  MidiControllerHandle? get midiControlNext => null;

  @override
  final List<Parameter> parameters;

  NamExtraFX(this.nuxIndex)
      : parameters = [
          if (nuxIndex == 1) _createParam('Pitch', 3, 12),
          if (nuxIndex >= 3 && nuxIndex <= 7) ...[
            _createParam('Rate', 5, 30),
            _createParam('Depth', 6, 50),
          ],
          if (nuxIndex == 4 || nuxIndex == 5) _createParam('Feedback', 7, 0),
          // Map Daisy Wah (103) parameters securely
          if (nuxIndex == 2 || nuxIndex == 103) ...[
            _createParam('Sensitivity', 8, 50),
            _createParam('Resonance', 9, 50),
          ],
          _createParam('Mix', 4, 100),
        ];

  static Parameter _createParam(String name, int index, double value) =>
      Parameter(
        name: name,
        handle: 'fx_$index',
        value: value,
        formatter: FxValueFormatter(index),
        devicePresetIndex: index, // This matches the exact NF payload byte offset
        midiCC: -1, // -1 forces NamProPreset.dart to intercept the write via NF SysEx
      );

  @override
  void setupFromNuxPayload(List<int> nuxData) {}

  @override
  void getNuxPayload(List<int> nuxData, bool enabled) {}

  void setupFromNfPayload(List<int> slice) {
    for (var param in parameters) {
      if (param.devicePresetIndex < slice.length) {
        param.value = slice[param.devicePresetIndex].toDouble();
      }
    }
  }

  void getNfPayload(List<int> slice) {
    for (var param in parameters) {
      if (param.devicePresetIndex < slice.length) {
        slice[param.devicePresetIndex] = param.value.round();
      }
    }
  }
}

class NamPitch extends NamExtraFX {
  NamPitch() : super(1);
}

class NamAutoWah extends NamExtraFX {
  NamAutoWah() : super(2);
}

class NamChorus extends NamExtraFX {
  NamChorus() : super(3);
}

class NamFlanger extends NamExtraFX {
  NamFlanger() : super(4);
}

class NamPhaser extends NamExtraFX {
  NamPhaser() : super(5);
}

class NamTremolo extends NamExtraFX {
  NamTremolo() : super(6);
}

class NamVibrato extends NamExtraFX {
  NamVibrato() : super(7);
}

class NamDaisyWah extends NamExtraFX {
  @override
  final String name = "Daisy Wah";

  // Native app override for custom wah routing
  NamDaisyWah() : super(103);
}