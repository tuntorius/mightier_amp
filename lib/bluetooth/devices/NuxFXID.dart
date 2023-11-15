import "NuxConstants.dart";

class NuxFXID {
  final int value;
  const NuxFXID._internal(this.value);
  @override
  toString() => '$value';
  toInt() => value;
  static fromInt(int val) => NuxFXID._internal(val);

  @override
  bool operator ==(covariant NuxFXID other) => other.value == value;
}

class PlugAirFXID extends NuxFXID {
  const PlugAirFXID._internal(int value) : super._internal(value);
  static const gate = PlugAirFXID._internal(0);
  static const efx = PlugAirFXID._internal(1);
  static const amp = PlugAirFXID._internal(2);
  static const cab = PlugAirFXID._internal(3);
  static const mod = PlugAirFXID._internal(4);
  static const delay = PlugAirFXID._internal(5);
  static const reverb = PlugAirFXID._internal(6);
}

class PlugProFXID extends NuxFXID {
  const PlugProFXID._internal(int value) : super._internal(value);

  static const wah = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iWAH);
  static const comp = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iCMP);
  static const efx = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iEFX);
  static const amp = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iAMP);
  static const eq = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iEQ);
  static const gate = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iNG);
  static const mod = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iMOD);
  static const delay = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iDLY);
  static const reverb = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iRVB);
  static const cab = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iCAB);
  static const sr = PlugProFXID._internal(PresetDataIndexPlugPro.Head_iSR);

  //@override
  //bool operator ==(covariant NuxFXID other) => other.value == value;
}

class PlugBTFXID extends NuxFXID {
  const PlugBTFXID._internal(int value) : super._internal(value);
  static const gate = PlugBTFXID._internal(0);
  static const amp = PlugBTFXID._internal(1);
  static const mod = PlugBTFXID._internal(2);
  static const delay = PlugBTFXID._internal(3);
  static const reverb = PlugBTFXID._internal(4);
}

class LiteFXID extends NuxFXID {
  const LiteFXID._internal(int value) : super._internal(value);
  static const gate = LiteFXID._internal(0);
  static const amp = LiteFXID._internal(1);
  static const mod = LiteFXID._internal(2);
  static const ambience = LiteFXID._internal(3);
}

class LiteMK2FXID extends NuxFXID {
  const LiteMK2FXID._internal(int value) : super._internal(value);
  static const gate = LiteFXID._internal(0);
  static const efx = LiteFXID._internal(1);
  static const amp = LiteFXID._internal(2);
  static const cab = LiteFXID._internal(3);
  static const mod = LiteFXID._internal(4);
  static const delay = LiteFXID._internal(5);
  static const reverb = LiteFXID._internal(6);
}

class Bass50BTFXID extends NuxFXID {
  const Bass50BTFXID._internal(int value) : super._internal(value);
  static const gate = PlugAirFXID._internal(0);
  static const efx = PlugAirFXID._internal(1);
  static const amp = PlugAirFXID._internal(2);
  static const cab = PlugAirFXID._internal(3);
  static const mod = PlugAirFXID._internal(4);
  static const reverb = PlugAirFXID._internal(5);
}
