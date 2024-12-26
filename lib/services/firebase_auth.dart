import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../UI/Details.dart';
import '../MainContainer.dart';

class AuthService{

  void createUser(BuildContext context , String emailAddress,String password,String confPassword, String name) async{
    if(confPassword != password){
      Fluttertoast.showToast(msg: 'Password do not match.');
      return;
    }
    else if(name == '' || emailAddress == '' || password == '' || confPassword == ''){
      Fluttertoast.showToast(msg: 'All fields are Required.');
    }
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(msg: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(msg: 'The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Details()),
        );
        user.updateDisplayName(name);
      }
    });
  }

  Future<void> loginUser(BuildContext context , String emailAddress , String password) async {
    if(emailAddress == "" || password == ""){
      Fluttertoast.showToast(msg: 'All fields are Required.');
    }
    else{
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailAddress,
            password: password
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainContainer()), (route) => false
        );
      }
    });
  }
}