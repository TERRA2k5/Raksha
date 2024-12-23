import 'package:Raksha/Contacts.dart';
import 'package:Raksha/Details.dart';
import 'package:Raksha/Profile.dart';
import 'package:Raksha/repository/FirebaseRepository.dart';
import 'package:Raksha/services/background_task.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'HomePage.dart';
import 'Login.dart';
import 'SignUp.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  if (FirebaseAuth.instance.currentUser != null) {
    bool isEnable = await FirebaseRepository().getFirebaseStatus();
    bool permission = await Permission.locationAlways.isGranted;
    Future.delayed(Duration.zero, () {
      if(FirebaseAuth.instance.currentUser != null && isEnable && permission){
        Background_task().runCrisisAlert(FirebaseAuth.instance.currentUser!.uid.toString());
      }
    });
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Raksha',
      home: AuthHandler(),
    );
  }
}

class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return HomePage();
        }
        return const Login();
        // return Profile();
      },
    );
  }
}

