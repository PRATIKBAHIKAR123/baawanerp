import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class City {
  final String name;
  City({required this.name});
}

class StateModel {
  final int id;
  final String name;
  final String code;
  final List<String> cities;

  StateModel({
    required this.id,
    required this.name,
    required this.code,
    required this.cities,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      cities: List<String>.from(json['cities'] ?? []),
    );
  }
}

class Country {
  final int id;
  final String name;
  final String code;
  final List<StateModel> states;

  Country({
    required this.id,
    required this.name,
    required this.code,
    required this.states,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      states: (json['states'] as List<dynamic>?)
              ?.map((s) => StateModel.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class CountryDataService {
  static List<Country> _countries = [];
  static String _companyCountry = "";

  static final StreamController<bool> _countriesLoadedController =
      StreamController<bool>.broadcast();

  static Stream<bool> get countriesLoadedStream =>
      _countriesLoadedController.stream;

  /// ========= Load Countries Data From JSON =========
  static Future<void> loadCountriesData() async {
    try {
      final String response = await rootBundle
          .loadString('assets/data/countries-states-cities.json');

      final data = json.decode(response);
      _countries = (data["countries"] as List<dynamic>)
          .map((c) => Country.fromJson(c))
          .toList();
      print('Countries loaded: ${_countries}');

      _countriesLoadedController.add(true);
    } catch (e) {
      print("Error loading countries: $e");
      _countriesLoadedController.add(false);
    }
  }

  /// ========= Load Company Country from SharedPreferences =========
  static Future<void> loadCompanyCountry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _companyCountry = prefs.getString("company_country") ?? "";
  }

  /// ========= Get Company Country =========
  static Future<String> getCompanyCountry() async {
    await loadCompanyCountry();
    return _companyCountry;
  }

  /// ========= Get States for given Country =========
  static List<StateModel> getStatesForCountry(String countryName) {
    final country = _countries.firstWhere(
      (c) => c.name.toLowerCase() == countryName.toLowerCase(),
      orElse: () => Country(id: 0, name: "", code: "", states: []),
    );

    return country.states;
  }

  /// ========= Get States for Company Country =========
  static Future<List<StateModel>> getStatesForCompanyCountry() async {
    final companyCountry = await getCompanyCountry();
    if (companyCountry.isEmpty) return [];
    return getStatesForCountry(companyCountry);
  }

  /// ========= Get Cities for State in a Country =========
  static List<City> getCitiesForState(String countryName, String stateName) {
    final country = _countries.firstWhere(
      (c) => c.name.toLowerCase() == countryName.toLowerCase(),
      orElse: () => Country(id: 0, name: "", code: "", states: []),
    );

    final state = country.states.firstWhere(
      (s) => s.name.toLowerCase() == stateName.toLowerCase(),
      orElse: () => StateModel(id: 0, name: "", code: "", cities: []),
    );

    return state.cities.map((c) => City(name: c)).toList();
  }

  /// ========= Get Cities for Company's Country =========
  static Future<List<City>> getCitiesForStateInCompanyCountry(
      String stateName) async {
    final companyCountry = await getCompanyCountry();
    if (companyCountry.isEmpty) return [];
    return getCitiesForState(companyCountry, stateName);
  }

  /// ========= Check if Company Country matches =========
  static Future<bool> isCompanyCountry(dynamic countryName) async {
    final companyCountry = await getCompanyCountry();
    if (companyCountry.isEmpty) return false;

    List<String> countries =
        countryName is List<String> ? countryName : [countryName.toString()];

    return countries
        .any((c) => c.toLowerCase() == companyCountry.toLowerCase());
  }
}
