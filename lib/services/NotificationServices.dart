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
  static String firebaseMessagingScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(

      // json is from project details -> firebase admin sdk
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "raksha-301e5",
          "private_key_id": "639646796d2b282cd5c2840bd7989df3ebf80e32",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDHYhCOOrwpaiFI\nR5IZil1mZS1d7jsa++6KyC/JWgjf0SLgi6w3V1sSB3ZmS8yAfZPl4PlHVjw0z0B8\nW8QdW/gbxLIBdyxCDL8x3LW/saVGInjsrfgRhmYW9OE10uJbZMQNigzo+K7/zg8B\n2BNfY7pBa8s7J+yOJgtMTmoIFcg0c2VMJCNqBXaihLXuqwP3zU+eOxN4Lc2uiLAT\nOnHvxLqB8EqvTncCwCzW3TlwkcIPtUITy6yI5f6om5hfwvr+xvofnwSwWs5WljWw\nSy6Nkd6agGweQEvhDw04ebpmi/33qlC6HXEEGSMQCltWM6SsPdnHLRgVBcZCKwGp\ntzFC+xd7AgMBAAECggEAWvKuF5rOMtwBA432JGVbtnYHjDW7y1LJHJA1UBUcQDAP\nRzsfGv1jguVZik8gISpnOPB29SXuf65cPX3EhxnpIo2GHyoDy7sxyaZiV2dKuyPF\nYjz3D9NtJSKdymYAL+1WitCClBDADtqpOM+eAqCkmOv5P+o1ux+6fpu0PSzmbpm4\nckx+zPvqgYML5/4EZAZzWkl7IntjDRXJpYOInHqtruz343JQBzRF2giSe4ayPumX\n32bVnHH6UW5orrQFVNxeDEtBIXTQfU0LHbdbVe8NW4x/84tQ5zUyGy7/l7hQlZia\nT2cSTeHn5AhyaalvVlQ+Ocv8ICVLh6kuUVu9l+T1vQKBgQDsiT3uLaQicpFewmxn\nM0ht4QyngkoOSKw0OrwzIIsTz0tH0IOewUQDGoJVgq0lBluVWIQnmqtxjhcag1xe\nVtTLExPC8VntE9mJic1LYIyRs9OG4Pz+420kPrEOR47Rd+7lF8+wkhW7SXPULY1Y\ns+eT37v2ROdbjyOMXpgvh/dXtQKBgQDXyiylT2brvmuRWBB8gj92l1HI/5eC4nB8\n9wQZezYE1KT6gkEHc/5yZNzpz7+G7u71eUvVyvazYyNO8fQKkItx0RtVTIcZfvEp\nrxrLhoFi9JM3zJQWuVaOvmMMK8z4yyp58G7wB0+ZwKaQQJKpKNb1thj3v4lQFIoQ\nVH5J0zXQbwKBgCUvgkPyeu5Lcp0iFaa3wjg7/CBNdFUAicoAPdwPzq2DlkMo/bg0\ni/us7DaDP7MlZ7p32vba8v78JpetdRUDs5plWmL4THnf+AAOYO7rs82oJqX6sutj\nV6IuFOm4yDQYFb+AWc9Zd/8kkggWTTVXux1dPBCATprvSthjeqtmRbVNAoGBAJFV\ndipERxIhZrs2L6xb4LhTg9623ell7tMLXvR2elRYj2C0121YnxeWfP7wT5NmWwRz\nFDNChlMdQwuJg46V+YTHi/wwFZGDYJNtfsNyrLPj+z8KhvajDvwGmBj7awppcws7\ndswscF0iVkwzYVOS0OweH8TEeIu5uZ7z+TZpjQX7AoGAP+fLgPdZYvAzZrh/4xph\nET5V13i8ZtGgGexO/ID5JNtGyzcukFD8wXABf605gJkvQs+iwKl5cPN3zdTwUaEb\nuFNRwXJ4vjwBgAggdSWHP/oNMNFPawkc1DeBAWPsnMrS0N1FXb7WxwAZH9JszypV\nol7yx33vEwBPJ+oR2+7TWI4=\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-vfr3k@raksha-301e5.iam.gserviceaccount.com",
          "client_id": "102504041591626523250",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-vfr3k%40raksha-301e5.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [firebaseMessagingScope]);

    final accessToken = client.credentials.accessToken.data;

    return accessToken;
  }

  Future<void> sendNotification(Position myPosition , String coordinate)async {
    String accessToken = await NotificationServices().getAccessToken();
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
