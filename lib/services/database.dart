import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_math/models/game_record.dart';
import 'package:flash_math/models/user_record.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  final CollectionReference mathCollections = FirebaseFirestore.instance
      .collection("math_users");

  Future addUserData(String name, Map<String, GameRecord> gameRecord) async {
    final dataToWrite = gameRecord.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    return await mathCollections.doc(uid).set({
      "name": name,
      "gameRecord": dataToWrite,
    });
  }

  Future updateUserRecord(Map<String, GameRecord> gameRecord) async {
    final dataToUpdate = gameRecord.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    return await mathCollections.doc(uid).update({"gameRecord": dataToUpdate});
  }

  Future updateName(String name) async {
    return await mathCollections.doc(uid).update({"name": name});
  }

  Future<UserRecord?> userDataForProfile() async {
    final snapshot = await mathCollections.doc(uid).get();
    if (snapshot.exists) {
      return _userDataFromSnapshots(snapshot);
    } else {
      return null;
    }
  }

  UserRecord _userDataFromSnapshots(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    Map<String, GameRecord>? gameRecordMap = {};
    if (data != null && data["gameRecord"] != null) {
      final rawData = Map<String, dynamic>.from(data["gameRecord"] as Map);
      gameRecordMap = rawData.map(
        (key, value) =>
            MapEntry(key, GameRecord.fromJson(value as Map<String, dynamic>)),
      );
    }
    return UserRecord(
      uid: uid,
      name: data?["name"] ?? "Player",
      gameRecord: gameRecordMap,
    );
  }

  Stream<UserRecord> get userData {
    return mathCollections.doc(uid).snapshots().map(_userDataFromSnapshots);
  }
}
