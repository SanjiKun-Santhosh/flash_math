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

  Future deleteUser() async {
    return await mathCollections.doc(uid).delete();
  }

  Future isUserExists() async {
    final snapshot = await mathCollections.doc(uid).get();
    if (snapshot.exists){
      return true;
    } else {
      return false;
    }

  }

  UserRecord? _userDataFromSnapshot(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      return null;
    }
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    return UserRecord.fromMap(uid, data ?? {});
  }

  Stream<UserRecord?> get userData {
    return mathCollections.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}
