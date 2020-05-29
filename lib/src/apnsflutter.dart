import 'package:apns_flutter/apns_flutter.dart';
import 'package:flutter/services.dart';

/// Contains all the methods for interacting with the iOS notifications system.
class ApnsFlutter {
  final MethodChannel _channel = const MethodChannel('apns_flutter');

  Function _onTokenFn;
  Function _onSettingsFn;

  /// Creates an instance that can communicate with iOS.
  ApnsFlutter() {
    _channel.setMethodCallHandler((call) {
      if (call.method == "onToken" && _onTokenFn != null) {
        _onTokenFn(call.arguments);
      } else if (call.method == "onSettings" && _onSettingsFn != null) {
        _onSettingsFn(ApnsSettings.fromJSON(call.arguments));
      } else if (call.method == "notificationTapped") {
        print(call.arguments);
      }
      return;
    });
  }

  /// Gets all current notifications.
  Future<List<ApnsNotification>> getNotifications() async {
    List notifications = await _channel.invokeMethod("getNotifications");
    List<ApnsNotification> results = [...notifications.map((json) => ApnsNotification.fromJSON(json))];
    return results;
  }

  /// Deletes the notifications with the identifiers [identifiers].
  void deleteNotifications(List<String> identifiers) async {
    await _channel.invokeMethod("deleteNotifications", identifiers);
  }

  /// Sets a callback function to receive APNS tokens as strings.
  void onToken(Function onToken) {
    this._onTokenFn = onToken;
  }

  /// Sets a callback function to receive the notification settings as [ApnsSettings].
  void onSettings(Function onSettings) {
    this._onSettingsFn = onSettings;
  }

  /// Requests notification permissions and a token.
  Future<void> register(
      {bool alert = true, bool sound = true, bool badge = true}) async {
    await _channel.invokeMethod('requestNotificationPermissions',
        {"alert": alert, "sound": sound, "badge": badge});
  }

  /// Gets the current badge number.
  Future<int> getBadge() async {
    return await _channel.invokeMethod('getBadge');
  }

  /// Sets the badge number to [badge].
  void setBadge(int badge) async {
    await _channel.invokeMethod('setBadge', badge);
  }
}