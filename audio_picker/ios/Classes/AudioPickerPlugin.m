#import "AudioPickerPlugin.h"
#import <audio_picker/audio_picker-Swift.h>

@implementation AudioPickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAudioPickerPlugin registerWithRegistrar:registrar];
}
@end
