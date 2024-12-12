import 'package:Raksha/entity/Model.dart';
import 'package:floor/floor.dart';

@dao
abstract class DetailsDAO {
  @Query('SELECT * FROM UserDetails WHERE id = :id')
  Future<PersonalDetails?> getUserDetails(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertOrUpdateUser(PersonalDetails userDetails);

  @Query('DELETE FROM UserDetails WHERE id = :id')
  Future<void> deleteUser(int id);
}


@dao
abstract class EmergencyContactsDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertEmergencyContact(EmergencyContact contact);

  @Query('DELETE FROM EmergencyContacts WHERE id = :id')
  Future<void> deleteContact(int id);

  @Query('SELECT * FROM EmergencyContacts')
  Future<List<EmergencyContact>> getAllEmergencyContacts();
}