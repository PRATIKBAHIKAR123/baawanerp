import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/styles.dart';

class SearchItemSalesPerson extends StatefulWidget {
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  final Function(String) onTextChanged;
  final Function(Map<String, dynamic>)? onitemSelects;

  SearchItemSalesPerson({required this.onTextChanged, this.onitemSelects});

  @override
  State<SearchItemSalesPerson> createState() => _SearchItemSalesPersonState();
}

class _SearchItemSalesPersonState extends State<SearchItemSalesPerson> {
  TextEditingController _textEditingController = TextEditingController();
  bool _showClearIcon = false;

  final borderColor = Colors.grey.shade300;
  final TextStyle hintStyle = GoogleFonts.plusJakartaSans(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );

  List<dynamic> salesPersons = [];
  late String currentSessionId;
  late ScrollController _scrollController;

  String? selectedSalesPerson;

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        String? currentSessionId = userData['user']['currentSessionId'];

        if (currentSessionId != null) {
          setState(() {
            this.currentSessionId = currentSessionId;
          });
          print('Loaded currentSessionId: $currentSessionId');
          getSalesPersons();
        } else {
          print('currentSessionId is null or not found in userData');
        }
      } catch (e) {
        print('Error parsing userData JSON: $e');
      }
    } else {
      print('No userData found in SharedPreferences');
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    loadUserData();
    _textEditingController.addListener(() {
      setState(() {
        _showClearIcon = _textEditingController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  getSalesPersons() async {
    try {
      var requestBody = {"table": 18, "sessionId": currentSessionId};

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          salesPersons = decodedData;
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  onClearItem() {
    _textEditingController.clear();
    widget.onitemSelects?.call({});
    setState(() {
      _showClearIcon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> nameToIdMap = {
      for (var sp in salesPersons) sp['name']: sp['id'],
    };

    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedSalesPerson = value;
                print('value: $value');
                var salesPersonId = nameToIdMap[value]!;
                print('salesPersonId: $salesPersonId');
                widget.onitemSelects
                    ?.call({'id': salesPersonId, 'name': value});
              });
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  enabled: false,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the popup
                      },
                      child: Icon(
                        Icons.close,
                      ),
                    ),
                  ),
                ),
                ...salesPersons.map((sp) {
                  return PopupMenuItem<String>(
                    value: sp['name'],
                    child: ListTile(
                      title: Text(sp['name']),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 50,
                      ),
                      minTileHeight: 0,
                    ),
                  );
                }).toList(),
              ];
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedSalesPerson ?? 'Select Sales Person',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
