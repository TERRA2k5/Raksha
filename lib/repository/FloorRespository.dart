import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../entity/Database.dart';
import '../entity/Model.dart';

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
      final person = PersonalDetails(1, name, int.parse(age!), DOB, int.parse(height!), int.parse(weight!), address, allergies, medicalnotes, medicines, bloodgrp);
      await personDao.insertOrUpdateUser(person);
    }
    catch(e){
      Fluttertoast.showToast(msg: 'Saving Details Failed $e');
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
      Fluttertoast.showToast(msg: 'Fetching Details Failed $e');
      return null;
    }
  }

  Future<void> insertContact(
      String name,
      String phone,
      bool isPrimary,
      ) async {
    try {
      final database = await $FloorDetailsDatabase.databaseBuilder(
          'app_database.db').build();
      final contactDAO = database.emergencyContactsDao;
      final contact = EmergencyContact(null, name, phone , isPrimary);
      await contactDAO.insertEmergencyContact(contact);
    }
    catch (e) {
      Fluttertoast.showToast(msg: 'Saving Contact Failed $e');
    }
  }

  Future<List<EmergencyContact>?> getContacts() async {
    final List<EmergencyContact>? contacts;
    try {
      final database = await $FloorDetailsDatabase.databaseBuilder('app_database.db').build();
      final contactDAO = database.emergencyContactsDao;
      contacts = await contactDAO.getAllEmergencyContacts();
      return contacts;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Fetching Details Failed $e');
      return [];
    }
  }

  Future<EmergencyContact?> getPrimary() async {
    try{
      final database = await $FloorDetailsDatabase.databaseBuilder('app_database.db').build();
      final contactDAO = database.emergencyContactsDao;
      EmergencyContact? primaryContact = await contactDAO.getPrimaryContact();
      return primaryContact;
    }
    catch(e){
      Fluttertoast.showToast(msg: 'Fetching Primary Failed $e');
      return null;
    }
  }

  Future<void> deleteContact(int? id) async {
    try {
      final database =
      await $FloorDetailsDatabase.databaseBuilder('app_database.db').build();
      final contactDao = database.emergencyContactsDao;

      await contactDao.deleteContact(id!);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting contact $e');
    }
  }
}