#import "FlutterMidiCommandPlugin.h"
#if __has_include(<flutter_midi_command/flutter_midi_command-Swift.h>)
#import <flutter_midi_command/flutter_midi_command-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_midi_command-Swift.h"
#endif



@implementation FlutterMidiCommandPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMidiCommandPlugin registerWithRegistrar:registrar];
}
@end
