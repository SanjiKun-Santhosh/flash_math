import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_math/models/user_record.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  final CollectionReference mathCollections = FirebaseFirestore.instance
      .collection("math_users");

  Future addUserData(String name, Map<String, String> gameRecord) async {
    return await mathCollections.doc(uid).set({
      "name": name,
      "gameRecord": gameRecord,
    });
  }

  Future updateUserRecord(Map<String, String> gameRecord) async {
    return await mathCollections.doc(uid).set({"gameRecord": gameRecord});
  }

  Future updateName(String name) async {
    return await mathCollections.doc(uid).set({"name": name});
  }

  Future <UserRecord?> userDataForProfile() async {
    final snapshot=await mathCollections.doc(uid).get();
    if (snapshot.exists) {
      return _userDataFromSnapshots(snapshot);
    } else {
      return null;
    }
  }

  UserRecord _userDataFromSnapshots(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    Map<String, String>? gameRecordMap;
    if (data != null && data["gameRecord"] != null) {
      gameRecordMap = Map<String, String>.from(data["gameRecord"] as Map);
    }
    return UserRecord(
      uid: uid,
      name: data?["name"] ?? "",
      gameRecord: gameRecordMap,
    );
  }

  Stream<UserRecord> get userData {
    return mathCollections.doc(uid).snapshots().map(_userDataFromSnapshots);
  }
}
