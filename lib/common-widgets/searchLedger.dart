import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/styles.dart';

class SearchLedger extends StatefulWidget {
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  final Function(String) onTextChanged;
  final Function(Map<String, dynamic>)? onledgerSelects;

  SearchLedger({required this.onTextChanged, this.onledgerSelects});

  @override
  State<SearchLedger> createState() => _SearchLedgerState();
}

class _SearchLedgerState extends State<SearchLedger> {
  TextEditingController _textEditingController = TextEditingController();
  bool _showClearIcon = false;

  final borderColor = Colors.grey.shade300;
  final TextStyle hintStyle = GoogleFonts.plusJakartaSans(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  late ScrollController _scrollController;
  List<Map<String, dynamic>>? ledgers = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getLedgers();
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

  getLedgers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');
    if (ledgerList != null) {
      ledgers = ledgerList
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
            return ledgers!.where((ledger) {
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
                          onClearLedger();
                        },
                        icon: Icon(color: Colors.black, Icons.close),
                      )
                    : null,
                contentPadding: EdgeInsets.all(13),
                hintText: 'Search Bill No. Or Party Name',
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
                        controller: _scrollController,
                        padding: EdgeInsets.all(10.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, dynamic> option =
                              options.elementAt(index);
                          return ListTile(
                            title: Text(option['name']),
                            subtitle: Text(
                                option['address'] ?? 'No address available'),
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

class SearchLedger2 extends StatefulWidget {
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  final Function(String) onTextChanged;
  final Map<String, dynamic>? ledgerFilter;
  final Function(Map<String, dynamic>)? onledgerSelects;

  const SearchLedger2(
      {super.key,
      required this.onTextChanged,
      this.ledgerFilter,
      this.onledgerSelects});

  @override
  State<SearchLedger2> createState() => _SearchLedgerState2();
}

class _SearchLedgerState2 extends State<SearchLedger2> {
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
  List<Map<String, dynamic>>? ledgers = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getGroups();
    getLedgers();
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

  getLedgers() async {
    print('ledgerlistFilter: ${widget.ledgerFilter}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');

    if (ledgerList != null) {
      // Create a map of group ID to group name for quick lookup
      Map<int, String> groupMap = {}; // Use int for group ID since it's numeric
      for (var group in groups!) {
        groupMap[group['id']] =
            group['name']; // Store id as key and name as value
      }

      print('Group Map: $groupMap'); // Debug print to see the group map

      // Load ledgers
      ledgers = ledgerList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();

      // Print ledgers for debugging
      print('Initial Ledgers: $ledgers');

      // Optionally filter ledgers based on the selected groups
      if (widget.ledgerFilter != null &&
          widget.ledgerFilter!['groups'].length > 0) {
        ledgers = ledgers!
            .where((ledger) =>
                widget.ledgerFilter!['groups'].contains(ledger['group_ID']))
            .toList();
        print('Filtered Ledgers: $ledgers');
      }

      // Add groupName to each ledger based on group_ID
      for (var ledger in ledgers!) {
        ledger['groupName'] =
            groupMap[ledger['group_ID']] ?? ''; // Set groupName
      }
    }

    setState(() {}); // Trigger a rebuild to update the UI
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
            return ledgers!.where((ledger) {
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
                hintText: 'Search Ledger',
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
                            trailing: Text(option['groupName'] ?? ''),
                            subtitle: Column(
                              children: [
                                Text(
                                    option['address'] ?? 'No address available')
                              ],
                            ),
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
