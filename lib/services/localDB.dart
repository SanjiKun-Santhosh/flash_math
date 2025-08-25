import 'package:hive/hive.dart';

import '../shared/constants.dart';

class HiveFunctions {
  static final userBox = Hive.box(userHiveBox);

  static createUser(Map data) {
    userBox.add(data);
  }

  static addAllUser(List<Map<String, dynamic>> data) {
    userBox.addAll(data);
  }

  // Get All data  stored in hive
  static List getAllUsers() {
    final data = userBox.keys.map((key) {
      final value = userBox.get(key);
      return {"key": key, "name": value["name"], "email": value['email']};
    }).toList();

    return data.reversed.toList();
  }

  // Get data for particular user in hive
  static Map getUser(int key) {
    return userBox.get(key);
  }

  // update data for particular user in hive
  static updateUser(int key, Map data) {
    userBox.put(key, data);
  }

  // delete data for particular user in hive
  static deleteUser(int key) {
    return userBox.delete(key);
  }

  // delete data for particular user in hive
  static deleteAllUser(int key) {
    return userBox.deleteAll(userBox.keys);
  }
}
