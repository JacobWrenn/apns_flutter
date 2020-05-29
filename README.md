# Apns Flutter

Use Flutter to interact with the native push notifications system on iOS.

*Requires iOS 10 or later*

## Example

```dart
final apns = ApnsFlutter();
apns.onToken((token) {
  print(token);
});
apns.onSettings((settings) {
  print(settings);
});
apns.register(badge: true, alert: true, sound: true);
```
