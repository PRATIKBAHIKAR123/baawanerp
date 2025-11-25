import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/styles.dart';

class SearchItem extends StatefulWidget {
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  final Function(String) onTextChanged;
  final Function(Map<String, dynamic>)? onitemSelects;

  SearchItem({Key? key, required this.onTextChanged, this.onitemSelects})
      : super(key: key);

  @override
  State<SearchItem> createState() => SearchItemState();
}

class SearchItemState extends State<SearchItem> {
  TextEditingController _textEditingController = TextEditingController();
  bool _showClearIcon = false;

  final borderColor = Colors.grey.shade300;
  final TextStyle hintStyle = GoogleFonts.plusJakartaSans(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  List<Map<String, dynamic>>? items = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getItems();
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

  getItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? itemList = prefs.getStringList('item-list');
    if (itemList != null) {
      items = itemList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    }
    setState(() {}); // Trigger a rebuild to update the UI
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
    return Row(children: [
      Expanded(
        child: Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return items!.where((item) {
              final nameLower = item['nm'].toLowerCase();
              final codeLower = item['ict']?.toLowerCase() ?? '';
              final searchLower = textEditingValue.text.toLowerCase();
              return nameLower.contains(searchLower) ||
                  codeLower.contains(searchLower);
            });
          },
          displayStringForOption: (Map<String, dynamic> option) => option['nm'],
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
                            title: Text(option['nm']),
                            subtitle: Text(option['ict'] ?? ''),
                            onTap: () {
                              onSelected(option);
                              print('Selected: ${option['nm']}');
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

class SearchItem3 extends StatefulWidget {
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  final Function(String) onTextChanged;
  final Function(Map<String, dynamic>)? onitemSelects;

  SearchItem3({Key? key, required this.onTextChanged, this.onitemSelects})
      : super(key: key);

  @override
  State<SearchItem3> createState() => SearchItemState3();
}

class SearchItemState3 extends State<SearchItem3> {
  TextEditingController _textEditingController = TextEditingController();
  bool _showClearIcon = false;

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
  List<Map<String, dynamic>>? items = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getItems();
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

  getItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? itemList = prefs.getStringList('item-list');
    if (itemList != null) {
      items = itemList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    }
    setState(() {}); // Trigger a rebuild to update the UI
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
    return Row(children: [
      Expanded(
        child: Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return items!.where((item) {
              final nameLower = item['nm'].toLowerCase();
              final codeLower = item['ict']?.toLowerCase() ?? '';
              final searchLower = textEditingValue.text.toLowerCase();
              return nameLower.contains(searchLower) ||
                  codeLower.contains(searchLower);
            });
          },
          displayStringForOption: (Map<String, dynamic> option) => option['nm'],
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
                          onClearItem();
                        },
                        icon: Icon(color: Colors.black, Icons.close),
                      )
                    : null,
                contentPadding: EdgeInsets.all(13),
                hintText: 'Search Item',
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
                        padding: EdgeInsets.all(10.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, dynamic> option =
                              options.elementAt(index);
                          return ListTile(
                            title: Text(option['ict'] ?? ''),
                            subtitle: Column(
                              children: [
                                Text(option['nm'] ?? ''),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      option['brd'] ?? '',
                                      style: itemTextStyle,
                                    ),
                                    Text(
                                      option['cat'] ?? '',
                                      style: itemTextStyle,
                                    ),
                                    Text(
                                      option['siz'] ?? '',
                                      style: itemTextStyle,
                                    ),
                                    Text(
                                      option['hsn'] ?? '',
                                      style: itemTextStyle,
                                    )
                                  ],
                                )
                              ],
                            ),
                            onTap: () {
                              onSelected(option);
                              print('Selected: ${option['nm']}');
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
