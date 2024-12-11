import 'dart:async';

import 'package:floor/floor.dart';
import 'PersonalDetails.dart';
import 'DetailsDAO.dart';
import 'package:sqflite/sqflite.dart' as sqflite;


part 'DetailsDatabase.g.dart'; // the generated code will be there

@Database(version: 1, entities: [PersonalDetails])
abstract class DetailsDatabase extends FloorDatabase {
  DetailsDAO get userDetailsDao;
}
