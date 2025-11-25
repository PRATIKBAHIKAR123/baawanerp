import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/gradientText.dart';
import 'package:mlco/global/appCommon.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/sessionIdFetch.dart';
import 'package:mlco/services/syncService.dart';

class LedgerFilterPopup extends StatefulWidget {
  final Function(String, int?) onSubmit;
  final Map<String, dynamic>? initialValues;
  LedgerFilterPopup({
    required this.onSubmit,
    this.initialValues,
  });

  @override
  _LedgerFilterPopupState createState() => _LedgerFilterPopupState();
}

class _LedgerFilterPopupState extends State<LedgerFilterPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide:
          BorderSide(width: 1, color: Color.fromRGBO(235, 235, 235, 1)));
  final borderColor = Colors.grey.shade300;
  final TextStyle hintStyle = GoogleFonts.plusJakartaSans(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  final TextStyle itemTextStyle = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  late ScrollController _scrollController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController groupcontroller = TextEditingController();
  TextEditingController citycontroller = TextEditingController();
  int? groupId;
  String? currentSessionId;
  List<Map<String, dynamic>> groupList = [];
  List<Map<String, dynamic>> cityList = [];
  TextEditingController _textEditingController = TextEditingController();
  bool _showClearIcon = false;
  bool _showGroupClearIcon = false;
  String city = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    loadSessionId();
    city = widget.initialValues!['city'] ?? '';
    print('object${widget.initialValues!['city']}');
    groupId = widget.initialValues!['group'];
  }

  void loadSessionId() async {
    String? sessionId = await UserDataUtil.getSessionId();

    if (sessionId != null) {
      setState(() {
        currentSessionId = sessionId;

        getCities('City');
        getGroups();
      });
      print('Loaded currentSessionId: $sessionId');
    } else {
      print('Session ID not found');
    }
  }

  @override
  void dispose() {
    // Dispose of the controller to prevent memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  getGroups() async {
    try {
      var requestBody = {"table": 10, "sessionId": currentSessionId};

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          groupList = List<Map<String, dynamic>>.from(decodedData);
          if (groupId != null) {
            var _grp =
                groupList.where((grp) => grp['id'] == groupId).toList().first;
            groupcontroller.text = _grp['name'];
          }
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
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
          cityList = List<Map<String, dynamic>>.from(decodedData);
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

  create() {
    widget.onSubmit(city, groupId);
    Navigator.pop(context);
  }

  onClearItem() {
    citycontroller.clear();
    city = '';
    setState(() {
      _showClearIcon = false;
    });
  }

  onClearGroup() {
    groupcontroller.clear();
    setState(() {
      _showGroupClearIcon = false;
      groupId = null;
    });
  }

  onClearForm() {
    setState(() {
      groupId = null;
      citycontroller.clear();
      city = '';
      _showGroupClearIcon = false;
      _showClearIcon = false;
    });
    Navigator.pop(context);
    widget.onSubmit(city, groupId);
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
                      Autocomplete<Map<String, dynamic>>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Map<String, dynamic>>.empty();
                          }
                          return cityList!.where((item) {
                            final nameLower = item['name'].toLowerCase();
                            final searchLower =
                                textEditingValue.text.toLowerCase();
                            return nameLower.contains(searchLower);
                          });
                        },
                        displayStringForOption: (Map<String, dynamic> option) =>
                            option['name'],
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          textEditingController.text = city;
                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            onChanged: (text) {
                              print('Text field value changed: $text');
                              setState(() {
                                city = text;
                                _showClearIcon = text.isNotEmpty;
                              });
                            },
                            onSubmitted: (text) {
                              focusNode.unfocus();
                            },
                            decoration: InputDecoration(
                              constraints: BoxConstraints(
                                  minHeight: 53, maxHeight: 53, maxWidth: 348),
                              suffixIcon: _showClearIcon
                                  ? IconButton(
                                      onPressed: () {
                                        onClearItem();
                                      },
                                      icon: Icon(
                                          color: Colors.black, Icons.close),
                                    )
                                  : null,
                              contentPadding: EdgeInsets.all(13),
                              hintText: 'City',
                              hintStyle: hintStyle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(211, 211, 211, 1)),
                              ),
                            ),
                            maxLines: 1,
                          );
                        },
                        optionsViewBuilder: (BuildContext context,
                            AutocompleteOnSelected<Map<String, dynamic>>
                                onSelected,
                            Iterable<Map<String, dynamic>> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              child: Container(
                                  height: 500,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: RawScrollbar(
                                    thumbColor: mlco_green,
                                    thumbVisibility: true,
                                    controller: _scrollController,
                                    thickness: 8,
                                    child: ListView.builder(
                                      padding: EdgeInsets.all(10.0),
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final Map<String, dynamic> option =
                                            options.elementAt(index);
                                        return ListTile(
                                          title: Text(option['name'] ?? ''),
                                          onTap: () {
                                            onSelected(option);
                                            city = option['name'];
                                            print(
                                                'Selected: ${option['name']}');
                                          },
                                        );
                                      },
                                    ),
                                  )),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Autocomplete<Map<String, dynamic>>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Map<String, dynamic>>.empty();
                          }
                          return groupList!.where((item) {
                            final nameLower = item['name'].toLowerCase();
                            final searchLower =
                                textEditingValue.text.toLowerCase();
                            return nameLower.contains(searchLower);
                          });
                        },
                        displayStringForOption: (Map<String, dynamic> option) =>
                            option['name'],
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          groupcontroller = textEditingController;
                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            onChanged: (text) {
                              print('Text field value changed: $text');
                              setState(() {
                                _showGroupClearIcon = text.isNotEmpty;
                              });
                            },
                            onSubmitted: (text) {
                              focusNode.unfocus();
                            },
                            decoration: InputDecoration(
                              constraints: BoxConstraints(
                                  minHeight: 53, maxHeight: 53, maxWidth: 348),
                              suffixIcon: _showGroupClearIcon
                                  ? IconButton(
                                      onPressed: () {
                                        onClearGroup();
                                      },
                                      icon: Icon(
                                          color: Colors.black, Icons.close),
                                    )
                                  : null,
                              contentPadding: EdgeInsets.all(13),
                              hintText: 'Group',
                              hintStyle: hintStyle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(211, 211, 211, 1)),
                              ),
                            ),
                            maxLines: 1,
                          );
                        },
                        optionsViewBuilder: (BuildContext context,
                            AutocompleteOnSelected<Map<String, dynamic>>
                                onSelected,
                            Iterable<Map<String, dynamic>> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              child: Container(
                                  height: 500,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: RawScrollbar(
                                    thumbColor: mlco_green,
                                    thumbVisibility: true,
                                    controller: _scrollController,
                                    thickness: 8,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      padding: EdgeInsets.all(10.0),
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final Map<String, dynamic> option =
                                            options.elementAt(index);
                                        return ListTile(
                                          title: Text(option['name'] ?? ''),
                                          onTap: () {
                                            onSelected(option);
                                            groupId = option['id'];
                                            print(
                                                'Selected: ${option['name']}');
                                          },
                                        );
                                      },
                                    ),
                                  )),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 42,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () {
                                onClearForm();
                              },
                              child: Text(
                                "Clear",
                                style: GoogleFonts.poppins(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            height: 42,
                            width: 130,
                            decoration: BoxDecoration(
                                gradient: mlcoGradient,
                                boxShadow: [],
                                borderRadius: BorderRadius.circular(6.0)),
                            child: TextButton(
                                onPressed: () {
                                  submit();
                                },
                                child: Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ))));
  }
}
