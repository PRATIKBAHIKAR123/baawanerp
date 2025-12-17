import 'dart:convert';
import 'dart:math';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mlco/global/appCommon.dart';
import 'package:mlco/services/companyFetch.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:shared_preferences/shared_preferences.dart';

Object formatAmount(amount) {
  try {
    final NumberFormat numberFormat = NumberFormat("#,##,##0.00", "en_IN");
    return numberFormat.format(amount);
  } catch (e) {
    return amount ?? 00.0; // Return the original value if parsing fails
  }
}

String formatDate(String isoDate) {
  DateTime parsedDate = DateTime.parse(isoDate);

  String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);

  return formattedDate;
}

String formatDateTime(String isoDateTime) {
  // Parse the ISO datetime string
  DateTime dateTime = DateTime.parse(isoDateTime);

  // Define the format you want
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

  // Format the datetime
  String formattedDate = formatter.format(dateTime);

  return formattedDate;
}

Future<String> getLedgerNameById(int ledgerID) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? ledgerList = prefs.getStringList('ledger-list');
  String ledgerName = '';

  if (ledgerList != null) {
    var ledgers = ledgerList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
    var ledger =
        ledgers.firstWhere((o) => o['id'] == ledgerID, orElse: () => {});
    if (ledger.isNotEmpty) {
      ledgerName = ledger['name'];
    }
  }

  return ledgerName;
}

getStateNameById(int stateID) {
  List<Map<String, dynamic>>? stateList = enStateCode;
  String stateName = '';

  var state = stateList.firstWhere((o) => o['id'] == stateID, orElse: () => {});
  if (state.isNotEmpty) {
    stateName = state['text'];
  }
  return stateName;
}

List<Map<String, dynamic>>? groupBy(
    List<Map<String, dynamic>> collection, String property) {
  if (collection == null) {
    return null;
  }

  Map<dynamic, List<Map<String, dynamic>>> groupedCollection = {};

  for (var element in collection) {
    var key = element[property];
    if (groupedCollection[key] == null) {
      groupedCollection[key] = [element];
    } else {
      groupedCollection[key]!.add(element);
    }
  }

  return groupedCollection.entries
      .map((entry) => {'key': entry.key, 'value': entry.value})
      .toList();
}

Future<String> getSalespersonNameById(int salespersonID, sessionId) async {
  // Define the request body for the API call
  Map<String, dynamic> requestBody = {"table": 18, "sessionId": sessionId};

  // Call the dropdown service API
  final response = await dropdownService(requestBody);

  if (response.statusCode == 200) {
    List<dynamic> salespersonList = jsonDecode(response.body);

    var salesperson = salespersonList.firstWhere(
        (person) => person['id'] == salespersonID,
        orElse: () => null);

    if (salesperson != null) {
      return salesperson['name'] ?? '';
    }
  } else {
    // Handle error response
    print('Failed to load salesperson data');
    return '';
  }

  return '';
}

double round(double value, double precision) {
  num mod = pow(10.0, precision);
  return ((value * mod).round().toDouble() / mod);
}

Map<String, double> invoiceGridCalculations({
  required int gstType,
  required double qty,
  required double rate,
  required double disc1,
  required double disc2,
  required double disc3,
  required double ratedisc,
  required double vat,
  required double conversions,
  required double basecurrency,
  required double precision,
}) {
  // Initialize result map
  var result = {
    'amount': 0.0,
    'stdqty': 0.0,
    'stdrate': 0.0,
    'landing': 0.0,
    'cgstPer': 0.0,
    'cgstAmt': 0.0,
    'sgstPer': 0.0,
    'sgstAmt': 0.0,
    'igstPer': 0.0,
    'igstAmt': 0.0,
    'rateAfterVat': 0.0,
    'expectedMargin': 0.0,
  };

  // Process discount on rate
  double landing =
      processDiscountOnRate(rate, disc1, disc2, disc3, ratedisc, basecurrency);

  double grossAmount = qty * landing;

  // Calculate amount
  result['amount'] = round(grossAmount, precision);

  // Calculate tax amount
  var taxval = getTaxValue(gstType, vat, result['amount']!, precision);
  result['cgstPer'] = taxval['cgstPer']!;
  result['cgstAmt'] = taxval['cgstAmt']!;
  result['sgstPer'] = taxval['sgstPer']!;
  result['sgstAmt'] = taxval['sgstAmt']!;
  result['igstPer'] = taxval['igstPer']!;
  result['igstAmt'] = taxval['igstAmt']!;

  // Calculate standard quantity
  double stdqty = qty * conversions;
  result['stdqty'] = stdqty;

  // Calculate standard rate
  if (qty > 0) {
    result['stdrate'] = (qty * rate) / stdqty;
  } else {
    result['stdrate'] = 0.0;
  }

  // Calculate landing cost
  result['landing'] = landing;

  return result;
}

double processDiscountOnRate(double rate, double disc1, double disc2,
    double disc3, double ratedisc, double basecurrency) {
  double d1 = rate * (1 - (disc1 / 100));
  double d2 = d1 * (1 - (disc2 / 100));
  double d3 = d2 - disc3;
  double d4 = d3 - ratedisc;

  // Convert rate if other than base currency
  d4 = d4 * (basecurrency != 0 ? basecurrency : 1);

  return d4;
}

Map<String, double> getTaxValue(
    int gstType, double vat, double amount, double precision) {
  Map<String, double> result = {
    'cgstPer': 0.0,
    'cgstAmt': 0.0,
    'sgstPer': 0.0,
    'sgstAmt': 0.0,
    'igstPer': 0.0,
    'igstAmt': 0.0,
  };

  if (gstType == 1) {
    double gstPer = round(vat / 2, precision);
    double gstAmount = round(amount * (gstPer / 100), precision);

    result['cgstPer'] = gstPer;
    result['cgstAmt'] = gstAmount;
    result['sgstPer'] = gstPer;
    result['sgstAmt'] = gstAmount;
  } else {
    double gstAmount = round(amount * (vat / 100), precision);

    result['igstPer'] = vat;
    result['igstAmt'] = gstAmount;
  }

  return result;
}

double sumOfArrayProperty(List<Map<String, dynamic>> items, String attrs) {
  double total = items.fold(0, (sum, item) => sum + (item[attrs] ?? 0));

  return total;
}

class Params {
  final double openingBal;
  final double debit;
  final double credit;
  final bool isCr;

  Params(
      {required this.openingBal,
      required this.debit,
      required this.credit,
      required this.isCr});

  factory Params.fromMap(Map<String, dynamic> map) {
    return Params(
      openingBal: map['OPENINGBAL']?.toDouble() ?? 0.0,
      debit: map['DEBIT']?.toDouble() ?? 0.0,
      credit: map['CREDIT']?.toDouble() ?? 0.0,
      isCr: map['IsCr'] ?? false,
    );
  }
}

String formatClosingNumberVal(Map<String, dynamic> paramsMap) {
  Params params = Params.fromMap(paramsMap);
  double val = params.openingBal +
      params.debit * (!params.isCr ? 1 : -1) +
      params.credit * (params.isCr ? 1 : -1);

  return formatValueBasedOnPrecision(val.abs());
}

String formatValueBasedOnPrecision(double num, {bool isCurrency = true}) {
  int precision = 2;
  NumberFormat numberFormat;

  if (isCurrency) {
    numberFormat = NumberFormat.currency(
        locale: 'en_IN', symbol: '₹', decimalDigits: precision);
  } else {
    numberFormat = NumberFormat.decimalPattern('en_IN');
    numberFormat.minimumFractionDigits = precision;
    numberFormat.maximumFractionDigits = precision;
  }

  return numberFormat.format(num);
}

class CurrencyFormatter {
  static List<Map<String, dynamic>> _currencyList = [];
  static int _currencyId = 1; // default INR
  static bool _initialized = false;
  static int _precision = 2;

  /// Initialize locales & currency list
  static Future<void> init() async {
    // Initialize locales (so they're bundled in release build)
    if (!_initialized) {
      for (final locale in ['en_IN', 'ar_AE', 'en_US', 'en_GB', 'en_IE']) {
        try {
          await initializeDateFormatting(locale, null);
        } catch (_) {}
      }
      _initialized = true;
    }

    _currencyList = await getCurrencyList();
    final company = await CompanyDataUtil.getCompanyFromLocalStorage();
    _currencyId = company?['baseCurrency'] ?? 1;
    _precision = company?['precision'] ?? 2;
  }

  static String format(num? amount) {
    init();
    if (amount == null) return '';

    // Default fallback
    String symbol = '₹';
    String locale = 'en_IN';
    String code = 'INR';

    // Find matching currency
    final matched = _currencyList.firstWhere(
      (c) => c['id'] == _currencyId,
      orElse: () => {},
    );

    if (matched.isNotEmpty) {
      symbol = matched['symbol'] ?? '₹';
      code = (matched['code'] ?? 'INR').toString().toUpperCase();

      switch (code) {
        case 'USD':
          locale = 'en_US';
          break;
        case 'AED':
          locale = 'ar_AE';
          break;
        case 'EUR':
          locale = 'en_IE';
          break;
        case 'GBP':
          locale = 'en_GB';
          break;
        default:
          locale = 'en_IN';
      }

      // Override with clean symbol map (avoids weird ones)
      symbol = _getCurrencySymbol(code);
    }

    // Ensure locale exists, fallback to en_US in release build
    final safeLocale = Intl.verifiedLocale(locale, NumberFormat.localeExists,
        onFailure: (_) => 'en_US');

    // Always prepend symbol (since some locales show it last)
    final formatted = NumberFormat.currency(
      locale: safeLocale,
      symbol: '',
      decimalDigits: _precision,
    ).format(amount);

    return '$symbol$formatted';
  }

  static String _getCurrencySymbol(String code) {
    switch (code) {
      case 'AED':
        return 'AED';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      default:
        return code;
    }
  }
}

Future<List<Map<String, dynamic>>> getCurrencyList() async {
  final prefs = await SharedPreferences.getInstance();

  dynamic stored = prefs.get('currency-list');
  List<Map<String, dynamic>>? currencyList = [];

  if (stored is String) {
    // JSON string stored
    final decoded = jsonDecode(stored);
    if (decoded is List) {
      currencyList = List<Map<String, dynamic>>.from(decoded);
    }
  } else if (stored is List) {
    // List stored via setStringList
    currencyList = stored
        .map((e) {
          if (e is String) return jsonDecode(e) as Map<String, dynamic>;
          return {};
        })
        .toList()
        .cast<Map<String, dynamic>>();
  }

  return currencyList;
}

String _getCurrencySymbol(String code) {
  switch (code) {
    case 'AED':
      return 'AED';
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'INR':
      return '₹';
    case 'GBP':
      return '£';
    default:
      return code;
  }
}
