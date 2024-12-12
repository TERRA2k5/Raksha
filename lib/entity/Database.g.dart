// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $DetailsDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $DetailsDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $DetailsDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<DetailsDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorDetailsDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $DetailsDatabaseBuilderContract databaseBuilder(String name) =>
      _$DetailsDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $DetailsDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$DetailsDatabaseBuilder(null);
}

class _$DetailsDatabaseBuilder implements $DetailsDatabaseBuilderContract {
  _$DetailsDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $DetailsDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $DetailsDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<DetailsDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$DetailsDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$DetailsDatabase extends DetailsDatabase {
  _$DetailsDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  DetailsDAO? _userDetailsDaoInstance;

  EmergencyContactsDao? _emergencyContactsDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UserDetails` (`id` INTEGER NOT NULL, `age` INTEGER, `height` INTEGER, `weight` INTEGER, `medicalnotes` TEXT, `allergies` TEXT, `medicines` TEXT, `name` TEXT, `DOB` TEXT, `address` TEXT, `bloodgrp` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `EmergencyContacts` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `contactName` TEXT NOT NULL, `phoneNumber` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  DetailsDAO get userDetailsDao {
    return _userDetailsDaoInstance ??= _$DetailsDAO(database, changeListener);
  }

  @override
  EmergencyContactsDao get emergencyContactsDao {
    return _emergencyContactsDaoInstance ??=
        _$EmergencyContactsDao(database, changeListener);
  }
}

class _$DetailsDAO extends DetailsDAO {
  _$DetailsDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _personalDetailsInsertionAdapter = InsertionAdapter(
            database,
            'UserDetails',
            (PersonalDetails item) => <String, Object?>{
                  'id': item.id,
                  'age': item.age,
                  'height': item.height,
                  'weight': item.weight,
                  'medicalnotes': item.medicalnotes,
                  'allergies': item.allergies,
                  'medicines': item.medicines,
                  'name': item.name,
                  'DOB': item.DOB,
                  'address': item.address,
                  'bloodgrp': item.bloodgrp
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PersonalDetails> _personalDetailsInsertionAdapter;

  @override
  Future<PersonalDetails?> getUserDetails(int id) async {
    return _queryAdapter.query('SELECT * FROM UserDetails WHERE id = ?1',
        mapper: (Map<String, Object?> row) => PersonalDetails(
            row['id'] as int,
            row['name'] as String?,
            row['age'] as int?,
            row['DOB'] as String?,
            row['height'] as int?,
            row['weight'] as int?,
            row['address'] as String?,
            row['allergies'] as String?,
            row['medicalnotes'] as String?,
            row['medicines'] as String?,
            row['bloodgrp'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> deleteUser(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM UserDetails WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> insertOrUpdateUser(PersonalDetails userDetails) async {
    await _personalDetailsInsertionAdapter.insert(
        userDetails, OnConflictStrategy.replace);
  }
}

class _$EmergencyContactsDao extends EmergencyContactsDao {
  _$EmergencyContactsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _emergencyContactInsertionAdapter = InsertionAdapter(
            database,
            'EmergencyContacts',
            (EmergencyContact item) => <String, Object?>{
                  'id': item.id,
                  'contactName': item.contactName,
                  'phoneNumber': item.phoneNumber
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<EmergencyContact> _emergencyContactInsertionAdapter;

  @override
  Future<void> deleteContact(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM EmergencyContacts WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<List<EmergencyContact>> getAllEmergencyContacts() async {
    return _queryAdapter.queryList('SELECT * FROM EmergencyContacts',
        mapper: (Map<String, Object?> row) => EmergencyContact(
            row['id'] as int?,
            row['contactName'] as String,
            row['phoneNumber'] as String));
  }

  @override
  Future<void> insertEmergencyContact(EmergencyContact contact) async {
    await _emergencyContactInsertionAdapter.insert(
        contact, OnConflictStrategy.replace);
  }
}
