import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../entity/DetailsDatabase.dart';
import '../entity/PersonalDetails.dart';

class FloorRepository{

  void insertPerson(
      String? name,
      String? age,
      String? DOB,
      String? height,
      String? weight,
      String? address,
      String? allergies,
      String? medicalnotes,
      String? medicines,
      String? bloodgrp
      ) async {
    try{
      final database = await $FloorDetailsDatabase.databaseBuilder('app_database.db').build();
      final personDao = database.userDetailsDao;
      final person = PersonalDetails(1, name, age.hashCode, DOB, height.hashCode, weight.hashCode, address, allergies, medicalnotes, medicines, bloodgrp);
      await personDao.insertOrUpdateUser(person);
    }
    catch(e){
      Fluttertoast.showToast(msg: 'Something went wrong');
    }
  }

  Future<PersonalDetails?> getPerson() async {
    final PersonalDetails? personData;
    try {
      final database = await $FloorDetailsDatabase.databaseBuilder('app_database.db').build();
      final personDao = database.userDetailsDao;
      personData = await personDao.getUserDetails(1);  // Await the future
      return personData;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong');
      return null;
    }
  }

}