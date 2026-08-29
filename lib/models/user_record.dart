import 'package:flash_math/models/game_record.dart';
import 'package:collection/collection.dart';

class UserRecord {
  final String uid;
  final String name;
  final int score;
  final String profilePicturePath;
  final Map<String, GameRecord>? gameRecord;

  const UserRecord({
    required this.uid,
    this.name = 'User',
    this.score = 0,
    this.profilePicturePath = '',
    this.gameRecord,
  });

  // A factory constructor to create a UserRecord from a map (e.g., from Firestore)
  // This will be useful in your DatabaseService.
  factory UserRecord.fromMap(String uid, Map<String, dynamic> data) {
    Map<String, GameRecord>? gameRecordMap;
    if (data['gameRecord'] != null && data['gameRecord'] is Map) {
      final rawData = Map<String, dynamic>.from(data["gameRecord"] as Map);
      gameRecordMap = rawData.map(
        (key, value) =>
            MapEntry(key, GameRecord.fromJson(value as Map<String, dynamic>)),
      );
    }

    return UserRecord(
      uid: uid,
      name: data['name'] ?? 'User',
      score: data['score'] ?? 0,
      profilePicturePath: data['profilePicturePath'] ?? '',
      gameRecord: gameRecordMap,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserRecord &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          name == other.name &&
          score == other.score &&
          profilePicturePath == other.profilePicturePath &&
          const MapEquality().equals(gameRecord, other.gameRecord));

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        score.hashCode ^
        profilePicturePath.hashCode ^
        const MapEquality().hash(gameRecord);
  }
}