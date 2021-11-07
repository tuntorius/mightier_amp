#import "QrUtilsPlugin.h"
#if __has_include(<qr_utils/qr_utils-Swift.h>)
#import <qr_utils/qr_utils-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "qr_utils-Swift.h"
#endif

@implementation QrUtilsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftQrUtilsPlugin registerWithRegistrar:registrar];
}
@end
