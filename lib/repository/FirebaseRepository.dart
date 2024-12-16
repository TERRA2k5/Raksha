import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
}