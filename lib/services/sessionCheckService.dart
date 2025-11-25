import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mlco/main.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/login/login.dart';
import 'package:mlco/services/api_client.dart';
import 'package:mlco/services/navigationservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<bool> checkSessionService() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userDataString = prefs.getString('userData');

  if (userDataString == null) {
    print('No user data found in shared preferences.');
    return false;
  }

  Map<String, dynamic> userData;
  try {
    userData = jsonDecode(userDataString);
  } catch (e) {
    print('Error decoding user data: $e');
    return false;
  }

  String? currentSessionId = userData['user']['currentSessionId'];
  if (currentSessionId == null) {
    print('No current session ID found in user data.');
    return false;
  }

  var url = 'https://api.baawanerp.com/api/Auth/CheckSession';
  final client = ApiClient(currentSessionId);
  var response;

  try {
    response = await client.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      //body: jsonEncode({"sessionId": currentSessionId}),
    ).timeout(const Duration(seconds: 50));

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody == true) {
        return true;
      } else {
        print('Invalid session response: $responseBody');
      }
    } else {
      print('Failed to check session. Status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }

  return false;
}

Future<void> isValidSession() async {
  bool isValid = await checkSessionService();
  if (isValid) {
    // navigatorKey.currentState?.pushReplacement(
    //   MaterialPageRoute(builder: (context) => MainDashboardScreen()),
    // );
  } else {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
