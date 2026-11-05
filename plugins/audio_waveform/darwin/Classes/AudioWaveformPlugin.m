#import "AudioWaveformPlugin.h"
#if __has_include(<audio_waveform/audio_waveform-Swift.h>)
#import <audio_waveform/audio_waveform-Swift.h>
#else
#import "audio_waveform-Swift.h"
#endif

@implementation AudioWaveformPlugin
+ (void)registerWithRegistrar:(id<FlutterPluginRegistrar>)registrar {
  [SwiftAudioWaveformPlugin registerWithRegistrar:registrar];
}
@end