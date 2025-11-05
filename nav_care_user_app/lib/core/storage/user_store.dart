import 'dart:convert';

import 'package:nav_care_user_app/data/authentication/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserStore {
  Future<User?> getUser();
  Future<void> saveUser(User user);
  Future<void> clearUser();
}

class SharedPrefsUserStore implements UserStore {
  static const _key = 'user_data';

  @override
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_key);
    if (userData == null) {
      return null;
    }
    return User.fromJson(json.decode(userData));
  }

  @override
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(user.toJson()));
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}