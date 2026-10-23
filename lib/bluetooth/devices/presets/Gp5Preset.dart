// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/painting.dart';

import '../NuxDevice.dart';
import '../NuxFXID.dart';
import '../effects/Processor.dart';
import '../effects/gp5/GP5Effects.dart';
import '../effects/gp5/GP5Processor.dart';
import 'Preset.dart';

/// Preset for the Valeton GP5.
///
/// The GP5 has a fixed chain of 10 data blocks:
/// 0 - nr, 1 - pre, 2 - dst, 3 - amp, 4 - cab, 5 - eq,
/// 6 - mod, 7 - dly, 8 - rvb, 9 - ns
///
/// The GP5's UI chain (as commonly presented by GP5 editors) is ordered:
/// NR, PRE, DST, N->S (NAM), AMP, CAB, EQ, MOD, DLY, RVB. The NAM (ns)
/// block is kept at data position 9 on the wire (see the IRS/NAM snap data
/// parsing), so only the UI chain order is remapped here via a slot <-> FXID
/// mapping. Protocol byte positions and block ids are untouched.
class Gp5Preset extends Preset {
  @override
  NuxDevice device;
  @override
  int channel;
  @override
  String channelName;

  @override
  int get qrDataLength => 160;

  //generated colors for the 100 GP5 channels
  static final List<Color> _channelColors = _generateChannelColors(100);

  //per block enable/selection state
  final List<bool> _enabled = List<bool>.filled(10, true);
  final List<int> _selected = List<int>.filled(10, 0);

  //UI chain order used by GP5 editors.
  //kept here so the slot <-> FXID mapping lives next to the effect lists.
  static const List<NuxFXID> _chainOrder = [
    GP5FXID.nr,
    GP5FXID.pre,
    GP5FXID.dst,
    GP5FXID.ns,
    GP5FXID.amp,
    GP5FXID.cab,
    GP5FXID.eq,
    GP5FXID.mod,
    GP5FXID.dly,
    GP5FXID.rvb,
  ];

  late final List<Gp5Processor> _nr;
  late final List<Gp5Processor> _pre;
  late final List<Gp5Processor> _dst;
  late final List<Gp5Amplifier> _amp;
  late final List<Gp5Cabinet> _cab;
  late final List<Gp5Processor> _eq;
  late final List<Gp5Processor> _mod;
  late final List<Gp5Processor> _dly;
  late final List<Gp5Processor> _rvb;
  late final List<Gp5Processor> _ns;

  Gp5Preset(
      {required this.device, required this.channel, required this.channelName})
      : super(channel: channel, channelName: channelName, device: device) {
    _nr = [GP5Effects.noiseReduction()];
    _pre = GP5Effects.preEffects();
    _dst = GP5Effects.dstEffects();
    _amp = GP5Effects.ampEffects().cast<Gp5Amplifier>();
    _cab = GP5Effects.cabEffects().cast<Gp5Cabinet>();
    _eq = GP5Effects.eqEffects();
    _mod = GP5Effects.modEffects();
    _dly = GP5Effects.dlyEffects();
    _rvb = GP5Effects.rvbEffects();
    _ns = GP5Effects.nsEffects();
  }

  @override
  List<Color> get channelColorsList => _channelColors;

  static List<Color> _generateChannelColors(int count) {
    final colors = <Color>[];
    for (int i = 0; i < count; i++) {
      colors.add(HSLColor.fromAHSL(
              1, (i * 137.508) % 360, 0.55, 0.60)
          .toColor());
    }
    return colors;
  }

  @override
  bool slotSwitchable(int index) => !slotBlocked(index);

  /// The NAM (neural amp model) block replaces the AMP and CAB(IR) blocks:
  /// while NAM is enabled those two blocks are locked out (rendered with a
  /// red cross through them) and can't be selected/edited.
  @override
  bool slotBlocked(int index) {
    if (!_enabled[getSlotFromFXID(GP5FXID.ns)!]) return false;
    var fxid = getFXIDFromSlot(index);
    return fxid == GP5FXID.amp || fxid == GP5FXID.cab;
  }

  @override
  bool slotEnabled(int index) => _enabled[index];

  @override
  void setSlotEnabled(int index, bool value, bool notifyBT) {
    _enabled[index] = value;
    super.setSlotEnabled(index, value, notifyBT);
  }

  @override
  NuxFXID getFXIDFromSlot(int slot) {
    if (slot >= 0 && slot < _chainOrder.length) return _chainOrder[slot];
    return NuxFXID.fromInt(slot);
  }

  @override
  int? getSlotFromFXID(NuxFXID fxid) {
    for (int i = 0; i < _chainOrder.length; i++) {
      if (_chainOrder[i] == fxid) return i;
    }
    return fxid.toInt();
  }

  @override
  List<Processor> getEffectsForSlot(int slot) {
    switch (getFXIDFromSlot(slot).toInt()) {
      case 0:
        return _nr;
      case 1:
        return _pre;
      case 2:
        return _dst;
      case 9:
        return _ns;
      case 3:
        return _amp;
      case 4:
        return _cab;
      case 5:
        return _eq;
      case 6:
        return _mod;
      case 7:
        return _dly;
      case 8:
        return _rvb;
    }
    return <Processor>[];
  }

  @override
  List<Amplifier> get amplifierList => _amp.cast<Amplifier>();

  @override
  List<Cabinet>? get cabinetList => _cab.cast<Cabinet>();

  @override
  int getSelectedEffectForSlot(int slot) => _selected[slot];

  @override
  void setSelectedEffectForSlot(int slot, int index, bool notifyBT) {
    var effects = getEffectsForSlot(slot);
    if (effects.isEmpty || index < 0 || index >= effects.length) return;
    _selected[slot] = index;
    super.setSelectedEffectForSlot(slot, index, notifyBT);
  }

  @override
  int getEffectArrayIndexFromNuxIndex(NuxFXID fxid, int nuxIndex) {
    var effects = getEffectsForSlot(getSlotFromFXID(fxid)!);
    for (int i = 0; i < effects.length; i++) {
      if (effects[i].nuxIndex == nuxIndex) return i;
    }
    return nuxIndex;
  }

  /// finds the index of the effect with the given 8 hex character id
  /// in the given block ([slot] is a data block id / FXID), or -1 if not found
  int findEffectIndexByHexId(int slot, String effectIdHex) {
    var effects = getEffectsForSlot(getSlotFromFXID(NuxFXID.fromInt(slot))!);
    for (int i = 0; i < effects.length; i++) {
      if ((effects[i] as Gp5Processor).effectIdHex == effectIdHex) return i;
    }
    return -1;
  }

  @override
  Color effectColor(int index) {
    var fxid = getFXIDFromSlot(index).toInt();
    if (fxid < device.processorList.length) {
      return device.processorList[fxid].color;
    }
    return channelColor;
  }

  @override
  void setFirmwareVersion(int ver) {}
}