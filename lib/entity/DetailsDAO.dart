import 'package:Raksha/entity/PersonalDetails.dart';
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