import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mlco/services/sessionCheckService.dart';
import 'package:mlco/config/api_config.dart';

Future<http.Response> ledgerBalService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url = '${ApiConfig.baseUrl}/api/Ledger/LedgerBalance';
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

Future<http.Response> ledgerInfoService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url = '${ApiConfig.baseUrl}/api/Ledger/GetById';
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

Future<http.Response> ledgerListService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url = '${ApiConfig.baseUrl}/api/Ledger/Search';
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

Future<http.Response> multiledgerService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url = '${ApiConfig.baseUrl}/api/Ledger/MultiLedgerInfo';
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

Future<http.Response> createledgerService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url = '${ApiConfig.baseUrl}/api/Ledger/Create';
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

Future<http.Response> ledgerPriceCatListService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url = '${ApiConfig.baseUrl}/api/Ledger/PriceCategories';
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
