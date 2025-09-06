import 'dart:collection';
import 'dart:io';

import 'package:flash_math/models/storage_hive_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

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
      print("Saved");
    } else {
      await _hiveStorage.put(
        userId,
        UserHiveStorage(id: userId, profilePicture: path),
      );
    }
    notifyListeners();
  }
}
