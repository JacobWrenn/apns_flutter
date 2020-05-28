# Apns Flutter

Use Flutter to interact with the native push notifications system on iOS.

## Example

```dart
await ApnsFlutter.requestPermissions(badge: true, alert: true, sound: true);
ApnsFlutter.onToken((token) {
  print(token);
});
ApnsFlutter.configure();
```
