/// Represents an iOS notification.
class ApnsNotification {

  /// The unique identifier used for deleting
  final String id;
  /// The title of the notification.
  final String title;
  /// The subtitle of the notification.
  final String subtitle;
  /// The body of the notification.
  final String body;
  /// The userInfo supplied with the notification.
  final Map userInfo;

  ApnsNotification({this.id, this.title, this.subtitle, this.body, this.userInfo});

  factory ApnsNotification.fromJSON(Map json) {
    return ApnsNotification(
      id: json["id"],
      title: json["title"],
      subtitle: json["subtitle"],
      body: json["body"],
      userInfo: json["userInfo"]
    );
  }

}