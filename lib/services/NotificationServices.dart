import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../repository/FirebaseRepository.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final firebaseRepo = FirebaseRepository();


  Future<void> sendNotification(Position myPosition , String coordinate)async {
    String accessToken = await FirebaseAccessToken().getAccessToken();
    print("token is $accessToken");
    List<String> users = await firebaseRepo.getNearbyUsers(myPosition,coordinate);

    try{
      for(var token in users){
        final Map<String, dynamic> body = {
          "message": {
            "token": token,
            "notification": {
              "title": "Emergency Alert!",
              "body": "Someone nearby needs your help !",
            },
            "data": {
              "url": coordinate,
              "click_action": "FLUTTER_NOTIFICATION_CLICK"
            }
          }
        };

        final Uri url = Uri.parse('https://fcm.googleapis.com/v1/projects/raksha-301e5/messages:send');

        final Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        };

        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          print("Notification sent successfully!");
        } else {
          print("Failed to send notification: ${response.body}");
        }

      }
    }catch(e){
      print('Sending notification failed $e');
    }
  }

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitialization =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialization = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  void firebaseNotificationInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification!.body.toString());
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(message);
      }
    });
  }

  Future<String> getToken() async {
    String? token = await messaging.getToken();
    print(token.toString());
    return token!;
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(), 'Notification FCM');
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: 'Emergency Nearby.',
            priority: Priority.high,
            importance: Importance.high,
            ticker: 'ticker');

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          1,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
      );
    });
  }

  Future<void> handleMessage(
      BuildContext context, RemoteMessage message) async {
    try {
      String? url = message.data['url'];

      if (url == null || url.isEmpty) {
        print('No URL found in the message');
        return;
      }
      print("url is $url");
      Uri? uri = Uri.tryParse(url);
      if (uri == null) {
        print('Invalid or unlaunchable URL: $url');
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print('URL launched successfully: $url');
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    //terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(context, message);
    });
  }
}
