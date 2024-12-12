import 'dart:async';

import 'package:floor/floor.dart';
import 'Model.dart';
import 'DAO.dart';
import 'package:sqflite/sqflite.dart' as sqflite;


part 'Database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [PersonalDetails , EmergencyContact])
abstract class DetailsDatabase extends FloorDatabase {
  DetailsDAO get userDetailsDao;
  EmergencyContactsDao get emergencyContactsDao;
}
