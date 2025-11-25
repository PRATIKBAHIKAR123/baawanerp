import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/services/itemService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemRegisterFilterPopup extends StatefulWidget {
  final Function(String, String, int, bool, bool) onSubmit;
  final String initialFromDate;
  final String initialToDate;
  final int? stockPlace;
  final bool isAllSPs;
  final bool isStockBalDetail;

  ItemRegisterFilterPopup({
    required this.onSubmit,
    this.initialFromDate = '',
    this.initialToDate = '',
    this.stockPlace = 001,
    this.isAllSPs = false,
    this.isStockBalDetail = false,
  });

  @override
  _ItemRegisterFilterPopupState createState() =>
      _ItemRegisterFilterPopupState();
}

class _ItemRegisterFilterPopupState extends State<ItemRegisterFilterPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  late bool isAllSPs;
  late bool isStockBalDetail;
  late int stockPlace;
  List<Map<String, dynamic>> stockPlaceList = [];
  late String currentSessionId;

  String? stockPlaceName;

  @override
  void initState() {
    super.initState();
    fromDate.text = DateFormat('dd/MM/yyyy').format(
        DateFormat('dd/MM/yyyy HH:mm:ss').parse(widget.initialFromDate!));
    toDate.text = DateFormat('dd/MM/yyyy')
        .format(DateFormat('dd/MM/yyyy HH:mm:ss').parse(widget.initialToDate!));
    loadUserData();
    isAllSPs = widget.isAllSPs;
    isStockBalDetail = widget.isStockBalDetail;
    stockPlace = widget.stockPlace ?? 001;

    // Set stockPlaceName to empty if stockPlace is 0
    stockPlaceName = (stockPlace != null)
        ? stockPlaceList.firstWhere(
            (sp) => sp['id'] == stockPlace,
            orElse: () => {'name': ''},
          )['name']
        : '';

    print('stockPlace $stockPlace');
    print('isAllSPs $isAllSPs');
    print('isStockBalDetail $isStockBalDetail');
  }

  @override
  void dispose() {
    fromDate.dispose();
    toDate.dispose();
    super.dispose();
  }

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

          getStockPlaceList();
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

  Future<void> getStockPlaceList() async {
    try {
      var requestBody = {"table": 4, "sessionId": currentSessionId};

      var response = await itemStockPlaceService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          stockPlaceList = List<Map<String, dynamic>>.from(decodedData);
          stockPlaceName = stockPlaceList.firstWhere(
            (sp) => sp['id'] == stockPlace,
            orElse: () => {'name': null},
          )['name'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No details found'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
  }

  Future<void> onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime(2100),
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    setState(() {
      fromDate.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  Future<void> onTapToDateFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (pickedDate == null) return;

    setState(() {
      toDate.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  void submitDate() {
    String formattedFromDate =
        fromDate.text.isNotEmpty ? '${fromDate.text} 00:00:00' : '';
    String formattedToDate =
        toDate.text.isNotEmpty ? '${toDate.text} 23:59:59' : '';

    widget.onSubmit(formattedFromDate, formattedToDate, stockPlace, isAllSPs,
        isStockBalDetail);
    Navigator.of(context).pop();

    print('fromDate: $formattedFromDate');
    print('toDate: $formattedToDate');
    print('stockPlace-: $stockPlace');
    print('isAllSPs: $isAllSPs');
    print('isStockBalDetail: $isStockBalDetail');
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> nameToIdMap = {
      for (var sp in stockPlaceList) sp['name']: sp['id'],
    };
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Container(
        width: 400,
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: fromDate,
                      decoration: InputDecoration(
                        hintText: 'From',
                        border: borderStyle,
                      ),
                      onTap: () => onTapFunction(context: context),
                    ),
                  ),
                  SizedBox(width: 16), // Add spacing between the text fields
                  Expanded(
                    child: TextFormField(
                      controller: toDate,
                      decoration: InputDecoration(
                        hintText: 'To',
                        border: borderStyle,
                      ),
                      onTap: () => onTapToDateFunction(context: context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      labelText: 'Stock Place',
                      border: borderStyle,
                      enabledBorder: borderStyle,
                      focusedBorder: borderStyle),
                  value: stockPlace == 001 ? '' : stockPlaceName,
                  items: [
                    DropdownMenuItem<String>(
                      child: Text('Select Stock Place'), // Empty option
                      value: '', // Default value when stockPlace is 0
                    ),
                    ...stockPlaceList.map((sp) => DropdownMenuItem<String>(
                          child: Text(sp['name']),
                          value: sp['name'],
                        ))
                  ].toList(),
                  onChanged: (value) {
                    if (value != null && value.isNotEmpty) {
                      stockPlace = nameToIdMap[value]!;
                      stockPlaceName = value;
                      print('stockPlace$stockPlace');
                    } else {
                      stockPlace =
                          001; // Reset to default value when 'Select Stock Place' is chosen
                      stockPlaceName = ''; // Reset stockPlaceName to empty
                    }
                    setState(() {}); // Update the UI
                  },
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isAllSPs = !isAllSPs;
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: isAllSPs,
                      onChanged: (bool? value) {
                        setState(() {
                          isAllSPs = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'All Stock Places',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isStockBalDetail = !isStockBalDetail;
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: isStockBalDetail,
                      onChanged: (bool? value) {
                        setState(() {
                          isStockBalDetail = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Stock Balance In Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 42,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: mlcoGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: () {
                    submitDate();
                  },
                  child: Text(
                    "Apply Filter",
                    style: GoogleFonts.poppins(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
