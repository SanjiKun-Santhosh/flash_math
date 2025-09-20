import 'package:flash_math/models/game_record.dart';

class UserRecord {
  late String uid;
  late Map<String, GameRecord>? gameRecord;
  late String name;

  UserRecord({required this.uid, required this.name, required this.gameRecord});
}