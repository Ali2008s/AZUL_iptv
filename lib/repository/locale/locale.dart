part of '../api/api.dart';

class LocaleApi {
  static Future<bool> savePin(String pin) async {
    try {
      await locale.write("parental_pin", pin);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getPin() async {
    try {
      return await locale.read("parental_pin");
    } catch (e) {
      return null;
    }
  }


  static Future<bool> setAdultFilter(bool enabled) async {
    try {
      await locale.write("adult_filter", enabled);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool getAdultFilter() {
    return locale.read("adult_filter") ?? false;
  }

  static Future<bool> saveUser(UserModel user) async {
    try {
      await locale.write("user", user.toJson());
      return true;
    } catch (e) {
      debugPrint("Error save User: $e");
      return false;
    }
  }

  static Future<UserModel?> getUser() async {
    try {
      final user = await locale.read("user");

      if (user != null) {
        return UserModel.fromJson(user, user['server_info']['server_url']);
      }
      return null;
    } catch (e) {
      debugPrint("Error save User: $e");
      return null;
    }
  }

  static Future<bool> logOut() async {
    try {
      await locale.remove("user");

      return true;
    } catch (e) {
      debugPrint("Error LogOut User: $e");
      return false;
    }
  }
}
