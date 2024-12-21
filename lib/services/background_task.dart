import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

import '../repository/FirebaseRepository.dart';

String taskName = "emergencyAlertTask";
final firebaseRepo = FirebaseRepository();

Future<void> callbackDispatcher() async {
  // Fluttertoast.showToast(msg: 'position.latitude.toString()');
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  Workmanager().executeTask((task, inputData) async {
    if (task == "emergencyAlertTask") {
      print("Background Task Triggered!");

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      await firebaseRepo.firebaseUpdateLocation(position);
    }
    return Future.value(true);
  });
}


class Background_task {
  Future<void> runCrisisAlert(String uid) async {
    Workmanager().cancelByUniqueName("emergencyAlertTask");
    await Workmanager().registerPeriodicTask(
      "emergencyAlertTask",
      "emergencyAlertTask",
      frequency: const Duration(minutes: 15),
    );
    print('Task Registered');
  }
}
