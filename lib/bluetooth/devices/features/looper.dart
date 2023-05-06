abstract class Looper {
  int get loopState;
  int get loopUndoState;
  int get loopRecordMode;
  double get loopLevel;

  void looperRecordPlay();
  void looperStop();
  void looperClear();
  void looperUndoRedo();
  void looperLevel(int vol);
  void looperNrAr(bool auto);
  void requestLooperSettings();
  Stream<LooperData> getLooperDataStream();
}

class LooperData {
  int loopState = 0;
  int loopUndoState = 0;
  int loopRecordMode = 0;
  bool loopHasAudio = false;
  double loopLevel = 50;
}
