import 'package:hive/hive.dart';

part 'storage_hive_model.g.dart';

@HiveType(typeId: 1)
class UserHiveStorage extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String profilePicture;

  UserHiveStorage({required this.id, required this.profilePicture});
}
