#import "AudioWaveformPlugin.h"
#if __has_include(<audio_waveform/audio_waveform-Swift.h>)
#import <audio_waveform/audio_waveform-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "audio_waveform-Swift.h"
#endif

@implementation AudioWaveformPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAudioWaveformPlugin registerWithRegistrar:registrar];
}
@end
 