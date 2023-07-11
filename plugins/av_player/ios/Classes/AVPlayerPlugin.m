#import "AVPlayerPlugin.h"
#import <audio_picker/audio_picker-Swift.h>

@implementation AVPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAVPlayerPlugin registerWithRegistrar:registrar];
}
@end
