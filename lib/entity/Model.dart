import 'package:floor/floor.dart';


@Entity(tableName: 'UserDetails')
class PersonalDetails {
  @primaryKey
  final int id;
  final int? age,height,weight;
  final String? medicalnotes,allergies,medicines,name,DOB,address,bloodgrp;

  PersonalDetails(this.id, this.name , this.age , this.DOB , this.height, this.weight , this.address , this.allergies, this.medicalnotes, this.medicines, this.bloodgrp);
}

@Entity(tableName: 'EmergencyContacts')
class EmergencyContact {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String contactName;
  final String phoneNumber;
  final bool isPrimary;

  EmergencyContact(this.id, this.contactName, this.phoneNumber, this.isPrimary);
}
