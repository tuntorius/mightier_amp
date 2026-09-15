#import "AudioWaveformPlugin.h"

// macOS registration stub.
// The macOS plugin entry historically symlinked to darwin/Classes, which was
// wrapped in #if 0 and produced no Objective-C symbols — breaking the link.
// iOS keeps its own Classes implementation; full waveform extraction on macOS
// can be ported later from the iOS Swift extractor.
@implementation AudioWaveformPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"com.tuntori.audio_waveform"
            binaryMessenger:[registrar messenger]];
  AudioWaveformPlugin* instance = [[AudioWaveformPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

@end
