import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mlco/services/sessionCheckService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mlco/config/api_config.dart';

final String url = ApiConfig.baseUrl;

Future<http.Response> getInvoiceListService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Invoice/Search'; // Replace with your actual login API URL
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

Future<http.Response> createInvoiceService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Invoice/Create'; // Replace with your actual login API URL
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

Future<http.Response> createDealerEnqService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Dealer/Create'; // Replace with your actual login API URL
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

Future<http.Response> updateInvoiceService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Invoice/Update'; // Replace with your actual login API URL
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

Future<http.Response> createBillNo(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Invoice/LastBillNoCreated'; // Replace with your actual login API URL
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

Future<http.Response> getInvoiceService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Invoice/GetById'; // Replace with your actual login API URL
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

Future<http.Response> getSetupInfoService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Invoice/SetupInfo'; // Replace with your actual login API URL
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

Future<http.Response> getPrintingTemplatesService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/PrintingTemplate/Search'; // Replace with your actual login API URL
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

Future<http.Response> uploadInvoiceDocService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Invoice/UploadDocument'; // Replace with your actual login API URL
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

Future<http.Response> deleteInvoiceDocService(
    Map<String, dynamic> jsonBody) async {
  //isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Invoice/DeleteDocument'; // Replace with your actual login API URL
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

Future<http.Response> checkStockService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Inventory/CheckItemsStock'; // Replace with your actual login API URL
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

Future<http.Response> checkPendingService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Inventory/CheckPendingItems'; // Replace with your actual login API URL
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

Future<http.Response> checkPendingDetailsService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Inventory/CheckPendingItemsDetails'; // Replace with your actual login API URL
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

Future<http.Response> dropdownService(Map<String, dynamic> jsonBody) async {
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

Future<http.Response> distinctService(Map<String, dynamic> jsonBody) async {
  await isValidSession();
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

Future<http.Response> getInvoicePrintCode(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      '${ApiConfig.baseUrl}/api/Invoice/PrintCode'; // Replace with your actual login API URL
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

Future<http.Response> getInvoicePdfService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url = 'https://print.baawanerp.com/api/Print/PrintInvoice';
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

Future<http.Response> shortenUrlString(Map<String, dynamic> jsonBody) async {
  // isValidSession();
  var url =
      'http://tinyurl.com/api-create.php'; // Replace with your actual login API URL
  var client = http.Client();
  var response;
  Uri uri = Uri.parse(url);
  final finalUri = uri.replace(queryParameters: jsonBody);
  try {
    response = await client.get(
      Uri.parse(finalUri.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'responseType': 'text',
      },
    ).timeout(const Duration(seconds: 2));
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }

  return response!;
}
