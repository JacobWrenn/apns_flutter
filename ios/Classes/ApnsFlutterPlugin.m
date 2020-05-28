#import <UserNotifications/UserNotifications.h>

#import "ApnsFlutterPlugin.h"

static FlutterError *getFlutterError(NSError *error) {
    if (error == nil) return nil;
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", (long)error.code]
                               message:error.domain
                               details:error.localizedDescription];
}

static NSObject<FlutterPluginRegistrar> *_registrar;

@implementation ApnsFlutterPlugin {
    FlutterMethodChannel *_channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    _registrar = registrar;
    FlutterMethodChannel *channel =
    [FlutterMethodChannel methodChannelWithName:@"apns_flutter"
                                binaryMessenger:[registrar messenger]];
    ApnsFlutterPlugin *instance =
    [[ApnsFlutterPlugin alloc] initWithChannel:channel];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = call.method;
    if ([@"requestNotificationPermissions" isEqualToString:method]) {
        NSDictionary *arguments = call.arguments;
        if (@available(iOS 10.0, *)) {
            UNAuthorizationOptions authOptions = 0;
            NSNumber *provisional = arguments[@"provisional"];
            if ([arguments[@"sound"] boolValue]) {
                authOptions |= UNAuthorizationOptionSound;
            }
            if ([arguments[@"alert"] boolValue]) {
                authOptions |= UNAuthorizationOptionAlert;
            }
            if ([arguments[@"badge"] boolValue]) {
                authOptions |= UNAuthorizationOptionBadge;
            }
            
            NSNumber *isAtLeastVersion12;
            if (@available(iOS 12, *)) {
                isAtLeastVersion12 = [NSNumber numberWithBool:YES];
                if ([provisional boolValue]) authOptions |= UNAuthorizationOptionProvisional;
            } else {
                isAtLeastVersion12 = [NSNumber numberWithBool:NO];
            }
            
            [[UNUserNotificationCenter currentNotificationCenter]
             requestAuthorizationWithOptions:authOptions
             completionHandler:^(BOOL granted, NSError *_Nullable error) {
                if (error) {
                    result(getFlutterError(error));
                    return;
                }
                // This works for iOS >= 10. See
                // [UIApplication:didRegisterUserNotificationSettings:notificationSettings]
                // for ios < 10.
                [[UNUserNotificationCenter currentNotificationCenter]
                 getNotificationSettingsWithCompletionHandler:^(
                                                                UNNotificationSettings *_Nonnull settings) {
                    NSDictionary *settingsDictionary = @{
                        @"sound" : [NSNumber numberWithBool:settings.soundSetting ==
                                    UNNotificationSettingEnabled],
                        @"badge" : [NSNumber numberWithBool:settings.badgeSetting ==
                                    UNNotificationSettingEnabled],
                        @"alert" : [NSNumber numberWithBool:settings.alertSetting ==
                                    UNNotificationSettingEnabled],
                        @"provisional" :
                            [NSNumber numberWithBool:granted && [provisional boolValue] &&
                             isAtLeastVersion12],
                    };
                    [self->_channel invokeMethod:@"onIosSettingsRegistered"
                                       arguments:settingsDictionary];
                }];
                result([NSNumber numberWithBool:granted]);
            }];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
            UIUserNotificationType notificationTypes = 0;
            if ([arguments[@"sound"] boolValue]) {
                notificationTypes |= UIUserNotificationTypeSound;
            }
            if ([arguments[@"alert"] boolValue]) {
                notificationTypes |= UIUserNotificationTypeAlert;
            }
            if ([arguments[@"badge"] boolValue]) {
                notificationTypes |= UIUserNotificationTypeBadge;
            }
            
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            result([NSNumber numberWithBool:YES]);
        }
    } else if ([@"configure" isEqualToString:method]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - AppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                         ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                         ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                         ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    [_channel invokeMethod:@"onToken" arguments:hexToken];
}

// This will only be called for iOS < 10. For iOS >= 10, we make this call when we request
// permissions.
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSDictionary *settingsDictionary = @{
        @"sound" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeSound],
        @"badge" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeBadge],
        @"alert" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeAlert],
        @"provisional" : [NSNumber numberWithBool:NO],
    };
    [_channel invokeMethod:@"onIosSettingsRegistered" arguments:settingsDictionary];
}

@end
