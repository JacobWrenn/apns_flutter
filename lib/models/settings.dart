/// Represents the iOS notification settings.
class ApnsSettings {

  /// Are alerts allowed
  final bool alert;
  /// Is the badge number allowed
  final bool badge;
  /// Are sounds allowed
  final bool sound;

  ApnsSettings({this.alert, this.badge, this.sound});

  factory ApnsSettings.fromJSON(Map json) {
    return ApnsSettings(
      alert: json["alert"],
      badge: json["badge"],
      sound: json["sound"],
    );
  }

}