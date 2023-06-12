import 'dart:async';

enum TunerMode {
  chromatic(0),
  guitarStandard(2),
  guitarCompensated(1),
  bass(3);

  const TunerMode(this.mode);
  final int mode;

  static TunerMode? getByMode(int mode) {
    for (TunerMode m in TunerMode.values) {
      if (m.mode == mode) return m;
    }
    return null;
  }
}

abstract class Tuner {
  static const List<String> modesString = [
    "Chromatic",
    "Guitar Standard",
    "Guitar Compensated",
    "Bass"
  ];

  bool get tunerAvailable;
  void tunerEnable(bool enable);
  void tunerRequestSettings();
  void tunerSetMode(TunerMode mode);
  void tunerSetReferencePitch(int refPitch);
  void tunerMute(bool enable);
  Stream<TunerData> getTunerDataStream();
  void notifyTunerListeners();
}

class TunerData {
  bool enabled = false;
  bool muted = false;
  int note = 0;
  int stringNumber = 0;
  int cents = 0;
  int referencePitch = 10;
  TunerMode mode = TunerMode.guitarStandard;

  void clear() {
    note = 0;
    stringNumber = 0;
    cents = 0;
  }
}
