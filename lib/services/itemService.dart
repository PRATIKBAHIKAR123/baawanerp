import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mlco/services/sessionCheckService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mlco/config/api_config.dart';

final String url = 'https://demoapi.mlco.in/api/Auth/Login';

Future<http.Response> itemFilterService(Map<String, dynamic> jsonBody) async {
  isValidSession();

  var url = '${ApiConfig.baseUrl}/api/Common/Distinct';
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

Future<http.Response> itemListService(Map<String, dynamic> jsonBody) async {
  isValidSession();

  var url = '${ApiConfig.baseUrl}/api/Item/Search';
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

Future<http.Response> createitemService(Map<String, dynamic> jsonBody) async {
  isValidSession();

  var url = '${ApiConfig.baseUrl}/api/item/Create';
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

Future<http.Response> itemPriceCatListService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();

  var url = '${ApiConfig.baseUrl}/api/item/PriceCategories';
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

Future<http.Response> getItemInfoService(Map<String, dynamic> jsonBody) async {
  isValidSession();

  var url = '${ApiConfig.baseUrl}/api/item/GetById';
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

Future<http.Response> itemStockPlaceService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();

  var url = '${ApiConfig.baseUrl}/api/Common/Dropdown';
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
