# just_waveform

This plugin extracts waveform data from an audio file that can be used to render waveform visualisations.

<img src="https://user-images.githubusercontent.com/19899190/138703227-6263c233-945c-4b60-8f0a-f652fbba9a3f.png" alt="waveform screenshot" width="350" />

## Usage

```dart
final progressStream = AudiotWaveform.extract(
  audioInFile: '/path/to/audio.mp3',
  zoom: const WaveformZoom.pixelsPerSecond(100),
);
progressStream.listen((waveformProgress) {
  print('Progress: %${(100 * waveformProgress.progress).toInt()}');
  if (waveformProgress.waveform != null) {
    // Use the waveform.
  }
});
```
