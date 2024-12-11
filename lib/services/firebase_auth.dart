import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService{

  void createUser(String emailAddress,String password,String confPassword, String name) async{
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
        Fluttertoast.showToast(msg: 'Welcome!');
        user.updateDisplayName(name);
      }
    });
  }
}