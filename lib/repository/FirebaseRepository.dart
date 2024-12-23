import 'dart:ffi';
import 'dart:math';

import 'package:Raksha/services/NotificationServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

final currentUser = FirebaseAuth.instance.currentUser;

class FirebaseRepository{

  Future<void> firebaseChangeStatus(bool state)async {
    if(currentUser != null){
      DatabaseReference ref = FirebaseDatabase.instance.ref("users").child(currentUser!.uid);
      await ref.update({
        "status": state,
      });
    }
  }

  Future<bool> getFirebaseStatus() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users").child(currentUser!.uid);
    bool result = false;
    final snapshot = await ref.child('status').get();
    // Fluttertoast.showToast(msg: snapshot.value.toString());
    if(snapshot.value.toString() == "true"){
      result = true;
    }
    return result;
  }


  Future<void> firebaseUpdateLocation(Position position)async {
    if(currentUser != null){
      DatabaseReference ref = FirebaseDatabase.instance.ref("users").child(currentUser!.uid);
      String token = await NotificationServices().getToken();
      print(token);
      await ref.update({
        "token": token,
        "time": ServerValue.timestamp,
        "latitude": position.latitude.toString(),
        "longitude": position.longitude.toString(),
      });
    }
  }

  Future<List<String>> getNearbyUsers(Position myPosition) async {
    List<String> fcmTokens = [];
    String myToken = await NotificationServices().getToken();
    DatabaseReference ref = FirebaseDatabase.instance.ref("users");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

      users.forEach((key, value) {
        String lat = value['latitude'];
        String lon = value['longitude'];
        String token = value['token'];
        bool isEnable = value['status'];
        print("lat is $lat");
        // Calculate distance
        if(isEnable){
          double distance = calculateDistance(
              myPosition.latitude, myPosition.longitude, double.tryParse(lat)!, double.tryParse(lon)!);

          if (distance <= 5 && myToken != token) {
            fcmTokens.add(token);
            print(token);
          }
        }
      });
    }

    return fcmTokens;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    double dLat = (lat2 - lat1) * pi / 180.0;
    double dLon = (lon2 - lon1) * pi / 180.0;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) *
            cos(lat2 * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }
}