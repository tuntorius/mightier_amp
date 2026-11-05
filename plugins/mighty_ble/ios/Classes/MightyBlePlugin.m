#import "MightyBlePlugin.h"
#if __has_include(<mighty_ble/mighty_ble-Swift.h>)
#import <mighty_ble/mighty_ble-Swift.h>
#else
#import "mighty_ble-Swift.h"
#endif

@implementation MightyBlePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMightyBlePlugin registerWithRegistrar:registrar];
}
@end