import 'package:flutter/services.dart';

class ApnsFlutter {
  static const MethodChannel _channel = const MethodChannel('apns_flutter');

  static void onToken(Function cb) {
    _channel.setMethodCallHandler((call) {
      if (call.method == "onToken") {
        cb(call.arguments);
      }
      return;
    });
  }

  static Future<void> requestPermissions({bool alert = true, bool sound = true, bool badge = true}) async {
    await _channel.invokeMethod('requestNotificationPermissions', {"alert": alert, "sound": sound, "badge": badge});
  }

  static Future<void> configure() async {
    await _channel.invokeMethod('configure');
  }
}