enum DrumsToneControl { bass, middle, treble }

abstract class DrumsTone {
  double get drumsBass;
  double get drumsMiddle;
  double get drumsTreble;

  void setDrumsTone(double value, DrumsToneControl control, bool send);
}
