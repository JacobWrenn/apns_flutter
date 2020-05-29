#import "ApnsFlutterPlugin.h"
#if __has_include(<apns_flutter/apns_flutter-Swift.h>)
#import <apns_flutter/apns_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apns_flutter-Swift.h"
#endif

@implementation ApnsFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftApnsFlutterPlugin registerWithRegistrar:registrar];
}
@end
