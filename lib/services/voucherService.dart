import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mlco/services/sessionCheckService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mlco/config/api_config.dart';

final String url = ApiConfig.baseUrl;

Future<http.Response> getVoucherListService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  '${ApiConfig.baseUrl}/api/Voucher/Search'; // Replace with your actual login API URL
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
