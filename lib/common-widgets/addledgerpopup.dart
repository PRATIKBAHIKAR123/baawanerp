import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/gradientText.dart';
import 'package:mlco/global/appCommon.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/services/companyFetch.dart';
import 'package:mlco/services/countryService.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/sessionIdFetch.dart';
import 'package:mlco/services/syncService.dart';

class addLedgerPopup extends StatefulWidget {
  final Function(String, String) onSubmit; // Define callback function

  addLedgerPopup({required this.onSubmit});

  @override
  _addLedgerPopupState createState() => _addLedgerPopupState();
}

class _addLedgerPopupState extends State<addLedgerPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide:
          BorderSide(width: 1, color: Color.fromRGBO(235, 235, 235, 1)));
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController gstcontroller = TextEditingController();
  TextEditingController areacontroller = TextEditingController();
  TextEditingController citycontroller = TextEditingController();
  Map<String, dynamic>? company;
  String? currentSessionId;
  List<dynamic> salesPersons = [];
  List<dynamic> stateList = [];
  List<String> cityList = [];
  List<String> areaList = [];
  int? stateId;
  int? salesPerson;

  @override
  void initState() {
    super.initState();
    loadSessionId();
  }

  void loadSessionId() async {
    String? sessionId = await UserDataUtil.getSessionId();
    company = await CompanyDataUtil.getCompanyFromLocalStorage();
    if (sessionId != null) {
      setState(() {
        currentSessionId = sessionId;

        getSalesPersons();
        stateList = loadStatesForLedgerCountry(company!['country']);
        getCities('City');
        getCities('Area');
      });
      print('Loaded currentSessionId: $sessionId');
    } else {
      print('Session ID not found');
    }
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

  static List<Map<String, dynamic>> loadStatesForLedgerCountry(
      String countryName) {
    final states = CountryDataService.getStatesForCountry(countryName);
    return states.map((state) {
      return {
        "id": state.id,
        "name": state.name,
        "code": state.code,
        "text": state.name, // same as Angular compatibility
      };
    }).toList();
  }

  getCities(columnTxt) async {
    try {
      var requestBody = {
        "table": 3,
        "column": columnTxt,
        "sessionId": currentSessionId
      };

      var response = await distinctService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          for (var item in decodedData) {
            columnTxt == "City" ? cityList.add(item['name']) : null;
            columnTxt == "Area" ? areaList.add(item['name']) : null;
          }
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      create();
    }
  }

  create() async {
    try {
      var requestBody = {
        "id": null,
        "name": namecontroller.text,
        "group_ID": 17,
        "address": addresscontroller.text,
        "area": areacontroller.text,
        "city": citycontroller.text,
        "state": stateId,
        "mobile": mobilecontroller.text,
        "email": emailcontroller.text,
        "gstNo": gstcontroller.text,
        "pinCode": null,
        "phone_1": null,
        "phone_2": null,
        "fax": null,
        "website": null,
        "tinV": null,
        "gstCategory": null,
        "gstType": 1,
        "opening_Bal": 0,
        "isCr": false,
        "credit_Limit": 0,
        "lock_Freeze": false,
        "creditDays": 0,
        "accountName": null,
        "bankName": null,
        "bankBranch": null,
        "brankAccountNo": null,
        "ifsc": null,
        "accounNo": null,
        "contactPerson": [],
        "contact_Person": null,
        "partyType": 1,
        "opening_Date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "panNo": null,
        "assignedUserID": salesPerson,
        "openingDetails": [],
        "bankDetails": [],
        "sessionId": currentSessionId
      };

      var response = await createledgerService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (mounted) {
        // Check if the widget is still mounted
        if (response.statusCode == 200) {
          ledgerSync();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        //isBtnLoading = false;
      });
      if (mounted) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final dropDownKey = GlobalKey<DropdownSearchState>();
    return Dialog(
        alignment: Alignment.center,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
        child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Spacer(flex: 1),
                          GradientText(
                            'Add Ledger',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            gradient: LinearGradient(colors: [
                              baawan_blue,
                              baawan_green,
                            ]),
                          ),
                          Spacer(flex: 1),
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: IconButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.black,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Name', border: borderStyle),
                        controller: namecontroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required.';
                          }
                          // const Text('This field is required');
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        decoration: InputDecoration(
                            labelText: 'Sales Person',
                            border: borderStyle,
                            enabledBorder: borderStyle,
                            focusedBorder: borderStyle),
                        items: salesPersons
                            .map((sp) => DropdownMenuItem<Map<String, dynamic>>(
                                  child: Text(sp['name']!),
                                  value: sp,
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            salesPerson = value['id'];
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                            hintText: 'Address', border: borderStyle),
                        controller: addresscontroller,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownSearch<String>(
                        items: (f, cs) => areaList,
                        popupProps: PopupProps.menu(
                            scrollbarProps:
                                ScrollbarProps(thumbColor: baawan_green),
                            fit: FlexFit.loose,
                            showSearchBox: true),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'Area ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (value) {
                          areacontroller.text = value ?? '';
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required.';
                          }
                          // const Text('This field is required');
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownSearch<String>(
                        items: (f, cs) => cityList,
                        popupProps: PopupProps.menu(
                            scrollbarProps:
                                ScrollbarProps(thumbColor: baawan_green),
                            fit: FlexFit.loose,
                            showSearchBox: true),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'City ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (value) {
                          citycontroller.text = value ?? '';
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required.';
                          }
                          // const Text('This field is required');
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<int>(
                        value: stateId,
                        menuMaxHeight: 420,
                        decoration: InputDecoration(
                            labelText: 'State',
                            border: borderStyle,
                            enabledBorder: borderStyle,
                            focusedBorder: borderStyle),
                        items: stateList
                            .map((sp) => DropdownMenuItem<int>(
                                  child: Text(sp['text']!),
                                  value: sp['id'],
                                ))
                            .toList(),
                        onChanged: (value) {
                          var stateObj;
                          stateObj =
                              stateList.where((s) => s['id'] == value).first;

                          print('value$value');
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Mobile ', border: borderStyle),
                        controller: mobilecontroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required.';
                          }
                          // const Text('This field is required');
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Email', border: borderStyle),
                        controller: emailcontroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required.';
                          }
                          // const Text('This field is required');
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: '${company!.taxNumberLabel}',
                            border: borderStyle),
                        controller: gstcontroller,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              gradient: mlcoGradient,
                              boxShadow: [],
                              borderRadius: BorderRadius.circular(6.0)),
                          child: TextButton(
                              onPressed: () {
                                submit();
                              },
                              child: Text(
                                'Create',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      )
                    ],
                  ),
                ))));
  }
}

class City {
  final String name;

  City({required this.name});

  @override
  String toString() {
    return name;
  }

  bool isEqual(City other) {
    return this.name == other.name;
  }
}
