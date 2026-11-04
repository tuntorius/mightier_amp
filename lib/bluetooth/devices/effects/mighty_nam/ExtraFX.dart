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
  int get max => 100; // UI Slider is always normalized 0-100

  @override
  int valueToMidi7Bit(double value) {
    if (index == 3) {
      // Pitch: Firmware strictly expects 0-24 absolute value
      return ((value / 100) * 24).round().clamp(0, 24);
    }
    return value.round().clamp(0, 100);
  }

  @override
  double midi7BitToValue(int midi7bit) {
    if (index == 3) {
      // Pitch: Restore the 0-24 hardware value back to the 0-100 UI slider range
      return (midi7bit / 24) * 100;
    }
    return midi7bit.clamp(0, 100).toDouble();
  }

  @override
  String toLabel(double value) {
    if (index == 3) {
      final semitones = ((value / 100) * 24).round() - 12;
      final sign = semitones > 0 ? '+' : '';
      return '$sign$semitones semitones';
    } else if (index == 5) {
      final hz = 0.05 + 7.95 * (value / 100);
      return '${hz.toStringAsFixed(2)} Hz';
    }
    return '${value.round()}%';
  }
}

abstract class NamExtraFX extends Processor {
  @override
  final int nuxIndex;

  final bool isFxB;

  @override
  String get name =>
      nuxIndex <= extraFxNames.length ? extraFxNames[nuxIndex - 1] : "Extra FX";

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
  MidiControllerHandle? get midiControlOff =>
      isFxB ? MidiControllerHandles.fxBOff : MidiControllerHandles.fxAOff;

  @override
  MidiControllerHandle? get midiControlOn =>
      isFxB ? MidiControllerHandles.fxBOn : MidiControllerHandles.fxAOn;

  @override
  MidiControllerHandle? get midiControlToggle =>
      isFxB ? MidiControllerHandles.fxBToggle : MidiControllerHandles.fxAToggle;

  @override
  MidiControllerHandle? get midiControlPrev =>
      isFxB ? MidiControllerHandles.fxBPrev : MidiControllerHandles.fxAPrev;

  @override
  MidiControllerHandle? get midiControlNext =>
      isFxB ? MidiControllerHandles.fxBNext : MidiControllerHandles.fxANext;

  @override
  final List<Parameter> parameters;

  NamExtraFX(this.nuxIndex, {this.isFxB = false})
      : parameters = [
          if (nuxIndex == 1) _createParam('Pitch', 3, 50, isFxB),
          if (nuxIndex >= 3 && nuxIndex <= 7) ...[
            _createParam('Rate', 5, 30, isFxB),
            _createParam('Depth', 6, 50, isFxB),
          ],
          if (nuxIndex == 4 || nuxIndex == 5)
            _createParam('Feedback', 7, 0, isFxB),
          // Map Daisy Wah (103) parameters securely
          if (nuxIndex == 2 || nuxIndex == 103) ...[
            _createParam('Sensitivity', 8, 50, isFxB),
            _createParam('Resonance', 9, 50, isFxB),
          ],
          _createParam('Mix', 4, 100, isFxB),
        ];

  static Parameter _createParam(
      String name, int offset, double value, bool isFxB) {
    // ROOT CAUSE FIX: The delta-checker uses the `handle` as a Map key. 
    // We MUST differentiate the handles for FX A and FX B, otherwise they overwrite each other in memory
    // and cause the UI to desync while spamming the Bluetooth connection with false delta updates!
    String safeHandle = isFxB ? 'fxb_$offset' : 'fxa_$offset';

    return Parameter(
      name: name,
      handle: safeHandle,
      value: value,
      formatter: FxValueFormatter(offset),
      devicePresetIndex: offset, // Kept relative (0..9) for generateNfPayload() targeting
      midiCC: -1, 
      midiControllerHandle: _resolveHandle(offset, isFxB),
    );
  }

  static MidiControllerHandle? _resolveHandle(int paramIndex, bool isFxB) {
    if (isFxB) {
      switch (paramIndex) {
        case 3:
          return MidiControllerHandles.fxBPitch;
        case 4:
          return MidiControllerHandles.fxBMix;
        case 5:
          return MidiControllerHandles.fxBRate;
        case 6:
          return MidiControllerHandles.fxBDepth;
        case 7:
          return MidiControllerHandles.fxBFeedback;
        case 8:
          return MidiControllerHandles.fxBSensitivity;
        case 9:
          return MidiControllerHandles.fxBResonance;
      }
    } else {
      switch (paramIndex) {
        case 3:
          return MidiControllerHandles.fxAPitch;
        case 4:
          return MidiControllerHandles.fxAMix;
        case 5:
          return MidiControllerHandles.fxARate;
        case 6:
          return MidiControllerHandles.fxADepth;
        case 7:
          return MidiControllerHandles.fxAFeedback;
        case 8:
          return MidiControllerHandles.fxASensitivity;
        case 9:
          return MidiControllerHandles.fxAResonance;
      }
    }
    return null;
  }

  @override
  void setupFromNuxPayload(List<int> nuxData) {}

  @override
  void getNuxPayload(List<int> nuxData, bool enabled) {}

  void setupFromNfPayload(List<int> slice) {
    for (var param in parameters) {
      if (param.devicePresetIndex < slice.length) {
        param.value = param.formatter.midi7BitToValue(slice[param.devicePresetIndex]);
      }
    }
  }

  void getNfPayload(List<int> slice) {
    for (var param in parameters) {
      if (param.devicePresetIndex < slice.length) {
        slice[param.devicePresetIndex] = param.midiValue;
      }
    }
  }
}

class NamPitch extends NamExtraFX {
  NamPitch({bool isFxB = false}) : super(1, isFxB: isFxB);
}

class NamAutoWah extends NamExtraFX {
  NamAutoWah({bool isFxB = false}) : super(2, isFxB: isFxB);
}

class NamChorus extends NamExtraFX {
  NamChorus({bool isFxB = false}) : super(3, isFxB: isFxB);
}

class NamFlanger extends NamExtraFX {
  NamFlanger({bool isFxB = false}) : super(4, isFxB: isFxB);
}

class NamPhaser extends NamExtraFX {
  NamPhaser({bool isFxB = false}) : super(5, isFxB: isFxB);
}

class NamTremolo extends NamExtraFX {
  NamTremolo({bool isFxB = false}) : super(6, isFxB: isFxB);
}

class NamVibrato extends NamExtraFX {
  NamVibrato({bool isFxB = false}) : super(7, isFxB: isFxB);
}

class NamDaisyWah extends NamExtraFX {
  @override
  final String name = "Daisy Wah";

  NamDaisyWah({bool isFxB = false}) : super(103, isFxB: isFxB);
}