import 'package:flutter/material.dart';
import 'package:apns_flutter/apns_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String token;

  void register() async {
    await ApnsFlutter.requestPermissions(badge: true, alert: true, sound: true);
    ApnsFlutter.onToken((token) {
      setState(() {
        this.token = token;
      });
    });
    ApnsFlutter.configure();
  }

  @override
  Widget build(BuildContext context) {
    if (token == null) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter APNS Example'),
            actions: <Widget>[
              FlatButton(
                child: Text("Get Token"),
                onPressed: () {
                  register();
                },
              ),
            ],
          ),
          body: Center(
            child: Text("Token not received.", style: TextStyle(fontSize: 20)),
          ),
        ),
      );
    } else {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter APNS Example'),
          ),
          body: Center(
            child: Text(token, style: TextStyle(fontSize: 20)),
          ),
        ),
      );
    }
  }
}
