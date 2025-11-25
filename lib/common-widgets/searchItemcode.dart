import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlco/services/itemService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/styles.dart';

class SearchItemCode extends StatefulWidget {
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  final Function(String) onTextChanged;
  final Function(Map<String, dynamic>)? onitemSelects;

  SearchItemCode({required this.onTextChanged, this.onitemSelects});

  @override
  State<SearchItemCode> createState() => _SearchItemCodeState();
}

class _SearchItemCodeState extends State<SearchItemCode> {
  TextEditingController _textEditingController = TextEditingController();
  bool _showClearIcon = false;

  final borderColor = Colors.grey.shade300;
  final TextStyle hintStyle = GoogleFonts.plusJakartaSans(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  late ScrollController _scrollController;
  List<Map<String, dynamic>>? items = [];
  late String currentSessionId;

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
          getItems();
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
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  getItems() async {
    try {
      var requestBody = {
        "table": 0,
        "column": 'Item_CodeTxt',
        "sessionId": currentSessionId
      };

      var response = await itemFilterService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          items = List<Map<String, dynamic>>.from(decodedData);
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

  onClearItem() {
    _textEditingController.clear();

    setState(() {
      _showClearIcon = false;
    });
    widget.onitemSelects?.call({'id': '', 'name': ''});
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return items!.where((item) {
              return item['name']
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (Map<String, dynamic> option) =>
              option['name'],
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            _textEditingController = textEditingController;
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (text) {
                print('Text field value changed: $text');
                widget.onTextChanged(text);
                setState(() {
                  _showClearIcon = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                focusNode.unfocus();
              },
              decoration: InputDecoration(
                constraints:
                    BoxConstraints(minHeight: 48, maxHeight: 48, maxWidth: 348),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(15),
                  child: Image.asset(
                    'assets/icons/search.png',
                    width: 18,
                    height: 18,
                  ),
                ),
                suffixIcon: _showClearIcon
                    ? IconButton(
                        onPressed: () {
                          onClearItem();
                        },
                        icon: Icon(color: Colors.black, Icons.close),
                      )
                    : null,
                contentPadding: EdgeInsets.all(13),
                hintText: 'Search Item',
                hintStyle: hintStyle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      BorderSide(color: Color.fromRGBO(211, 211, 211, 1)),
                ),
              ),
              maxLines: 1,
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<Map<String, dynamic>> onSelected,
              Iterable<Map<String, dynamic>> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                child: Container(
                    height: 500,
                    width: 340,
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
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 8,
                      child: ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, dynamic> option =
                              options.elementAt(index);
                          return ListTile(
                            title: Text(option['name']),
                            onTap: () {
                              onSelected(option);
                              print('Selected: ${option['name']}');
                              widget.onitemSelects?.call(option);
                            },
                          );
                        },
                      ),
                    )),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
