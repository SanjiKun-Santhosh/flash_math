import 'dart:collection';
import 'dart:io';
import 'dart:convert';

import 'package:flash_math/models/storage_hive_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:flash_math/models/user_record.dart';

import '../models/game_record.dart';
import '../shared/constants.dart';


class HiveService extends ChangeNotifier {
  final List<UserHiveStorage> _userHiveStorage = [];

  UnmodifiableListView<UserHiveStorage> get userHiveStorage =>
      UnmodifiableListView(_userHiveStorage);
  final Box<UserHiveStorage> _hiveStorage = Hive.box<UserHiveStorage>(
    userHiveBox,
  );
  File? _profileImage;

  File? get profileImage => _profileImage;

  Future<void> loadProfileImage(String userId) async {
    final UserHiveStorage? userFromHive = _hiveStorage.get(userId);
    if (userFromHive != null && userFromHive.profilePicture.isNotEmpty) {
      _profileImage = File(userFromHive.profilePicture);
    } else {
      _profileImage = null;
    }
    notifyListeners();
  }

  Future<void> saveProfileImage(String userId, String path) async {
    final UserHiveStorage? userFromHive = _hiveStorage.get(userId);
    if (userFromHive != null) {
      userFromHive.profilePicture = path;
      await userFromHive.save();
    } else {
      // When creating a new entry, we might not have other data.
      // The UserDataRepository will fill it in later with a call to saveUserRecord.
      await _hiveStorage.put(
        userId,
        UserHiveStorage(id: userId, profilePicture: path, name: 'User', score: 0),
      );
    }
    _profileImage = File(path);
    notifyListeners();
  }

  /// Fetches a user record from the local Hive cache.
  Future<UserRecord?> getUserRecord(String uid) async {
    final UserHiveStorage? userFromHive = _hiveStorage.get(uid);

    if (userFromHive == null) {
      return null;
    }

    Map<String, GameRecord>? gameRecordMap;
    if (userFromHive.gameRecord != null) {
      gameRecordMap = userFromHive.gameRecord!.map(
        (key, value) => MapEntry(
          key,
          GameRecord.fromJson(json.decode(value) as Map<String, dynamic>),
        ),
      );
    }

    // Convert from Hive model to the app's UserRecord model.
    return UserRecord(
      uid: userFromHive.id,
      name: userFromHive.name,
      score: userFromHive.score,
      profilePicturePath: userFromHive.profilePicture,
      gameRecord: gameRecordMap,
    );
  }

  /// Saves a user record to the local Hive cache.
  Future<void> saveUserRecord(UserRecord record) async {
    final UserHiveStorage? userFromHive = _hiveStorage.get(record.uid);

    Map<String, String>? gameRecordJson;
    if (record.gameRecord != null) {
      gameRecordJson = record.gameRecord!.map(
        (key, value) => MapEntry(key, json.encode(value.toJson())),
      );
    }

    if (userFromHive != null) {
      // Update existing record
      userFromHive.name = record.name;
      userFromHive.score = record.score;
      userFromHive.profilePicture = record.profilePicturePath;
      userFromHive.gameRecord = gameRecordJson;
      await userFromHive.save();
    } else {
      // Create a new record in the cache
      final newHiveRecord = UserHiveStorage(
        id: record.uid,
        name: record.name,
        score: record.score,
        profilePicture: record.profilePicturePath,
        gameRecord: gameRecordJson,
      );
      await _hiveStorage.put(record.uid, newHiveRecord);
    }
  }
}
