// This code is licensed under MIT license (see LICENSE.md for details)

import '../../../../utilities/MathEx.dart';
import '../../value_formatters/GP5Formatters.dart';
import '../../value_formatters/SwitchFormatters.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

/// Parameter definition used to build Valeton GP5 effects.
/// Values are sent to the device as float32, so they are stored
/// as-is (0-100, Hz, ms, etc).
class GP5Param {
  final String name;
  final String handle;
  final double def;
  final double min;
  final double max;

  //number of decimal digits displayed in the slider label
  final int decimals;

  //optional suffix in the slider label, e.g. " ms"
  final String suffix;

  //0/1 toggle parameters are rendered as a switch
  final bool isSwitch;

  //this parameter tracks the master (patch) volume
  final bool masterVolume;

  //the byte the GP-5's change-parameter command addresses for this parameter.
  //Left null for parameters whose position in the effect's parameter list is
  //the device's address (the normal case). The rvb and dly blocks declare it
  //explicitly: the pedal numbers those parameters with the "algId" from the
  //official metadata, which is sparse per algorithm, so the slot order is not
  //the address there. A parameter of those blocks without a declared byte
  //cannot be written over RAM at all - its slot is an alias of a neighbouring
  //cell - and sendParameter skips it.
  final int? wireAddress;

  GP5Param({
    required this.name,
    required this.handle,
    required this.def,
    required this.min,
    required this.max,
    this.decimals = 0,
    this.suffix = "",
    this.isSwitch = false,
    this.masterVolume = false,
    this.wireAddress,
  });
}

/// Base class for all Valeton GP5 effects.
///
/// The GP5 has 10 fixed blocks (nr, pre, dst, amp, cab, eq, mod, dly, rvb,
/// ns) each containing at least one effect. Effects are referenced by a
/// 4 byte id which is stored in [effectIdHex] (8 hex chars).
class Gp5Processor extends Processor {
  final int blockId;
  final String _effectIdHex;
  final String _name;
  final int _nuxIndex;
  final List<GP5Param> _parameters = [];
  late final List<Parameter> _processedParameters;

  Gp5Processor(this.blockId, this._effectIdHex, this._nuxIndex, this._name,
      List<GP5Param> params) {
    _processedParameters = [];
    for (int i = 0; i < params.length; i++) {
      var p = params[i];
      _parameters.add(p);
      _processedParameters.add(Parameter(
        name: p.name,
        handle: p.handle,
        value: p.def,
        formatter: _cachedFormatter(p),
        midiCC: 100 + blockId * 8 + i,
        devicePresetIndex: 20 + blockId * 12 + i,
        masterVolume: p.masterVolume,
        wireAddress: p.wireAddress,
      ));
    }
  }

  //share formatter instances between all effect instances to save memory
  static final Map<String, ValueFormatter> _fmtCache = {};

  static ValueFormatter _cachedFormatter(GP5Param p) {
    if (p.isSwitch) {
      final key = "s${p.name}";
      return _fmtCache.putIfAbsent(
          key, () => GP5SwitchFormatter("${p.name}:", _switchLabels(p)));
    }
    final key = "f${p.min}|${p.max}|${p.decimals}|${p.suffix}";
    return _fmtCache.putIfAbsent(
        key,
        () => GP5FloatFormatter(p.min, p.max,
            decimals: p.decimals, suffix: p.suffix));
  }

  static List<String> _switchLabels(GP5Param p) {
    //0/1 toggles. Special case the auto wah "Mode (Guitar/Bass)"
    if (p.name.toLowerCase().contains("guitar")) {
      return ["Guitar", "Bass"];
    }
    return ["Off", "On"];
  }

  ///the 8 hex character effect id used by the device
  String get effectIdHex => _effectIdHex;

  @override
  String get name => _name;

  @override
  int get nuxIndex => _nuxIndex;

  //the QR/nux data layout - one byte per block for the effect type
  @override
  int? get nuxEffectTypeIndex => blockId;

  //one byte per block for the enable state
  @override
  int? get nuxEnableIndex => 10 + blockId;

  @override
  int get midiCCEnableValue => blockId;

  @override
  int get midiCCSelectionValue => (MidiCCValuesGP5.none + 1) + blockId;

  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;

  @override
  List<Parameter> get parameters => _processedParameters;

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
  void setupFromNuxPayload(List<int> nuxData) {
    for (int i = 0; i < _processedParameters.length; i++) {
      var param = _processedParameters[i];
      if (nuxData.length <= param.devicePresetIndex) continue;
      if (param.formatter is SwitchFormatter) {
        param.value = nuxData[param.devicePresetIndex].toDouble();
      } else {
        param.value = MathEx.map(
            nuxData[param.devicePresetIndex].toDouble(),
            0,
            100,
            param.formatter.min.toDouble(),
            param.formatter.max.toDouble());
      }
    }
  }

  @override
  void getNuxPayload(List<int> nuxData, bool enabled) {
    if (nuxEffectTypeIndex != null) nuxData[nuxEffectTypeIndex!] = _nuxIndex;
    for (int i = 0; i < _processedParameters.length; i++) {
      var param = _processedParameters[i];
      if (param.formatter is SwitchFormatter) {
        nuxData[param.devicePresetIndex] =
            param.formatter.valueToMidi7Bit(param.value);
      } else {
        nuxData[param.devicePresetIndex] = MathEx
            .map(param.value,
                param.formatter.min.toDouble(),
                param.formatter.max.toDouble(),
                0,
                100)
            .round()
            .clamp(0, 100);
      }
    }
    if (nuxEnableIndex != null) {
      int value = (enabled != nuxEnableInverted ? 0xff : 0) & nuxEnableMask;
      nuxData[nuxEnableIndex!] |= value;
    }
  }
}

/// Amplifier block (block 3) effects
class Gp5Amplifier extends Gp5Processor implements Amplifier {
  Gp5Amplifier(super.blockId, super.effectIdHex, super.nuxIndex, super.name,
      super.params);

  @override
  int get defaultCab => 0;
}

/// Cabinet block (block 4) effects
class Gp5Cabinet extends Gp5Processor implements Cabinet {
  Gp5Cabinet(super.blockId, super.effectIdHex, super.nuxIndex, super.name,
      super.params);

  @override
  String get cabName => name;
}

class MidiCCValuesGP5 {
  //used for the block enable/selection "CC" numbers
  //the GP5 does not have CC commands, these values are placeholder
  //identifiers that keep the generic effect select code working
  static const none = 100;
}