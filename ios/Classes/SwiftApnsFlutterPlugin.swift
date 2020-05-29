import Flutter
import UIKit
import UserNotifications

public class SwiftApnsFlutterPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    
    let channel: FlutterMethodChannel
    let center: UNUserNotificationCenter
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        self.center = UNUserNotificationCenter.current()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "apns_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftApnsFlutterPlugin(channel: channel)
        UNUserNotificationCenter.current().delegate = instance
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "requestNotificationPermissions") {
            var options: UNAuthorizationOptions = []
            if let args = call.arguments as? [String:Bool] {
                if (args["badge"]!) {
                    options.update(with: .badge)
                }
                if (args["alert"]!) {
                    options.update(with: .alert)
                }
                if (args["sound"]!) {
                    options.update(with: .sound)
                }
                center.requestAuthorization(options: options) { granted, error in
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                    self.center.getNotificationSettings { settings in
                        self.channel.invokeMethod("onSettings", arguments: [
                            "badge": settings.badgeSetting == .enabled,
                            "alert": settings.alertSetting == .enabled,
                            "sound": settings.soundSetting == .enabled
                        ])
                    }
                    result(granted)
                }
            }
        } else if (call.method == "setBadge") {
            UIApplication.shared.applicationIconBadgeNumber = call.arguments as! Int
            result(call.arguments as! Int)
        } else if (call.method == "getBadge") {
            result(UIApplication.shared.applicationIconBadgeNumber)
        } else if (call.method == "getNotifications") {
            center.getDeliveredNotifications { notifications in
                var response: [[String:Any]] = []
                for notification in notifications {
                    response.append([
                        "id": notification.request.identifier,
                        "body": notification.request.content.body,
                        "title": notification.request.content.title,
                        "subtitle": notification.request.content.subtitle,
                        "userInfo": notification.request.content.userInfo
                    ])
                }
                result(response)
            }
        } else if (call.method == "deleteNotifications") {
            center.removeDeliveredNotifications(withIdentifiers: call.arguments as! [String])
            result(true)
        }
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        channel.invokeMethod("onToken", arguments: token)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        channel.invokeMethod("notificationTapped", arguments: [
            "id": notification.request.identifier,
            "body": notification.request.content.body,
            "title": notification.request.content.title,
            "subtitle": notification.request.content.subtitle,
            "userInfo": notification.request.content.userInfo
        ])
        completionHandler()
    }
}
