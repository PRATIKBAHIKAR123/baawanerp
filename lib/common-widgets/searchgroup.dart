import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlco/global/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchGroup extends StatefulWidget {
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  final Function(String) onTextChanged;
  final Map<String, dynamic>? ledgerFilter;
  final Function(Map<String, dynamic>)? onledgerSelects;

  const SearchGroup(
      {super.key,
      required this.onTextChanged,
      this.ledgerFilter,
      this.onledgerSelects});

  @override
  State<SearchGroup> createState() => SearchGroupState();
}

class SearchGroupState extends State<SearchGroup> {
  TextEditingController _textEditingController = TextEditingController();
  bool _showClearIcon = false;

  final borderColor = Colors.grey.shade300;
  final TextStyle hintStyle = GoogleFonts.plusJakartaSans(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  late ScrollController _scrollController;
  List<Map<String, dynamic>>? groups = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getGroups();
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

  getGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? groupList = prefs.getStringList('group-list');
    if (groupList != null) {
      groups = groupList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    }
    setState(() {}); // Trigger a rebuild to update the UI
  }

  onClearLedger() {
    _textEditingController.clear();
    widget.onledgerSelects?.call({});
    setState(() {
      _showClearIcon = false;
    });
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
            return groups!.where((ledger) {
              return ledger['name']
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
                    BoxConstraints(minHeight: 53, maxHeight: 53, maxWidth: 348),
                // prefixIcon: Padding(
                //   padding: EdgeInsets.all(15),
                //   child: Image.asset(
                //     'assets/icons/search.png',
                //     width: 18,
                //     height: 18,
                //   ),
                // ),
                suffixIcon: _showClearIcon
                    ? IconButton(
                        onPressed: () {
                          onClearLedger();
                        },
                        icon: Icon(color: Colors.black, Icons.close),
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
                        controller: _scrollController,
                        padding: EdgeInsets.all(10.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, dynamic> option =
                              options.elementAt(index);
                          return ListTile(
                            title: Text(option['name']),
                            // trailing: Text(option['groupName'] ?? ''),
                            // subtitle: Column(
                            //   children: [
                            //     Text(
                            //         option['address'] ?? 'No address available')
                            //   ],
                            // ),
                            onTap: () {
                              onSelected(option);
                              print('Selected: ${option['name']}');
                              widget.onledgerSelects?.call(option);
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
