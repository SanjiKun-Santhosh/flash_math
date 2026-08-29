import 'package:hive/hive.dart';

part 'storage_hive_model.g.dart';

@HiveType(typeId: 0)
class UserHiveStorage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int score;

  @HiveField(3)
  String profilePicture;

  @HiveField(4)
  Map<String, String>? gameRecord;

  UserHiveStorage({
    required this.id,
    this.name = 'User',
    this.score = 0,
    this.profilePicture = '',
    this.gameRecord,
  });
}