#import "MightyBlePlugin.h"
#if __has_include(<mighty_ble/mighty_ble-Swift.h>)
#import <mighty_ble/mighty_ble-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mighty_ble-Swift.h"
#endif

@implementation MightyBlePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMightyBlePlugin registerWithRegistrar:registrar];
}
@end
