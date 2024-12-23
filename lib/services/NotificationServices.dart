import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
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
          handleMessage(context , message);
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

    DarwinNotificationDetails darwinNotificationDetails =  const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
    
    Future.delayed(Duration.zero, (){
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  Future<void> handleMessage(BuildContext context, RemoteMessage message) async {
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

  Future<void> setupInteractMessage(BuildContext context) async{

    //terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null){
      handleMessage(context, initialMessage);
    }

    //background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      handleMessage(context, message);
    });
  }
}
