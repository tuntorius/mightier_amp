import 'just_audio_adapter.dart';

enum AudioPlayerState { idle, reachedEnd }

abstract class AudioPlayerAdapter {
  Future<void> setAudioFile(String path);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  void setSpeed(double speed);
  void setPitch(double pitch);
  Future seek(Duration position);
  void setGain(double gain);
  Stream<Duration> createPositionStream();
  Duration get position;
  Duration get duration;
  Stream<AudioPlayerState> get playerStateStream;
  bool get playing;
  AudioPlayerState get playerState;
  Future<void> dispose();
}

class AudioPlayerAdapterFactory {
  static AudioPlayerAdapter create() {
    // Return the appropriate adapter instance based on the desired audio player library
    return JustAudioAdapter();
  }
}
