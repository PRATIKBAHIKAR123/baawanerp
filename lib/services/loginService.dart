import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String apiUrl = 'https://api.baawanerp.com/api/Auth/Login';

Future<http.Response> loginService(Map<String, dynamic> jsonBody) async {
  var url =
      'https://api.baawanerp.com/api/Auth/Login'; // Replace with your actual login API URL
  var client = http.Client();
  var response;

  try {
    response = await client
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(jsonBody),
        )
        .timeout(const Duration(seconds: 50));
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }

  return response!;
}

Future<http.Response> dealerLoginService(Map<String, dynamic> jsonBody) async {
  var url =
      'https://api.baawanerp.com/api/Auth/Dealer/Login'; // Replace with your actual login API URL
  var client = http.Client();
  var response;

  try {
    response = await client
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(jsonBody),
        )
        .timeout(const Duration(seconds: 50));
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }

  return response!;
}
