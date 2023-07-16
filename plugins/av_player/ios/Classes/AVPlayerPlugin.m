#import "AVPlayerPlugin.h"
#import <av_player/av_player-Swift.h>

@implementation AVPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAVPlayerPlugin registerWithRegistrar:registrar];
}
@end
