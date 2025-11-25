import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataUtil {
  static Future<String?> getSessionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        return userData['user']['currentSessionId'];
      } catch (e) {
        print('Error parsing userData JSON: $e');
        return null;
      }
    } else {
      print('No userData found in SharedPreferences');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        return userData['user'];
      } catch (e) {
        print('Error parsing userData JSON: $e');
        return null;
      }
    } else {
      print('No userData found in SharedPreferences');
      return null;
    }
  }
}
