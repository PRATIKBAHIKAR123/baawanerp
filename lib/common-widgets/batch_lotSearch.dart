import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/sessionIdFetch.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/styles.dart';

class SearchItemBatchLot extends StatefulWidget {
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  final Function(String) onTextChanged;
  final Function(Map<String, dynamic>)? onLotBatchNoSelects;
  final String? itemCode;

  SearchItemBatchLot(
      {Key? key,
      this.itemCode,
      required this.onTextChanged,
      this.onLotBatchNoSelects})
      : super(key: key);

  @override
  State<SearchItemBatchLot> createState() => SearchItemState();
}

class SearchItemState extends State<SearchItemBatchLot> {
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
  String? currentSessionId;
  bool _isFocused = false;
  FocusNode _focusNode = FocusNode();

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
  void didUpdateWidget(covariant SearchItemBatchLot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.itemCode != widget.itemCode) {
      print('Item code changed: ${widget.itemCode}');
      getItems();
      _focusNode.addListener(() {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  getItems() async {
    currentSessionId = await UserDataUtil.getSessionId();
    try {
      var requestBody = {
        "table": 25,
        "column": "MfgCode",
        "searchText": widget.itemCode.toString() ?? "",
        "sessionId": currentSessionId
      };

      var response = await distinctService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          items = List<Map<String, dynamic>>.from(decodedData ?? []);
        });
      } else {}
    } catch (e) {
      print("Error fetching distinct lot/batch numbers: $e");
    }
  }

  onClearItem() {
    _textEditingController.clear();
    widget.onLotBatchNoSelects?.call({});
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
            if (items == null || items!.isEmpty) return [];
            if (_isFocused && textEditingValue.text.isEmpty) {
              return items!;
            }
            return items!.where((item) {
              final nameLower = item['name'].toLowerCase();
              final codeLower = item['ict']?.toLowerCase() ?? '';
              final searchLower = textEditingValue.text.toLowerCase();
              return nameLower.contains(searchLower) ||
                  codeLower.contains(searchLower);
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
                hintText: 'Search Lot/Batch No',
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
                            subtitle: Text(option['ict'] ?? ''),
                            onTap: () {
                              onSelected(option);
                              print('Selected: ${option['name']}');
                              widget.onLotBatchNoSelects?.call(option);
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
