import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

@entity
class PersonalDetails {
  @primaryKey
  final int id;
  final int? age,height,weight;
  final String? medicalnotes,allergies,medicines,name,DOB,address,bloodgrp;

  PersonalDetails(this.id, this.name , this.age , this.DOB , this.height, this.weight , this.address , this.allergies, this.medicalnotes, this.medicines, this.bloodgrp);
}