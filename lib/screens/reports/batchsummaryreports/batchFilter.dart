import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/gradientText.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/global/appCommon.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/itemService.dart';
import 'package:mlco/services/sessionIdFetch.dart';
import 'package:mlco/services/syncService.dart';

class BatchStockSummaryFilterPopup extends StatefulWidget {
  final Function(Map<String, dynamic>?) onSubmit; // Define callback function

  BatchStockSummaryFilterPopup({required this.onSubmit});

  @override
  _BatchStockSummaryFilterPopupState createState() =>
      _BatchStockSummaryFilterPopupState();
}

class _BatchStockSummaryFilterPopupState
    extends State<BatchStockSummaryFilterPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide:
          BorderSide(width: 1, color: Color.fromRGBO(235, 235, 235, 1)));
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController itemcodecontroller = TextEditingController();
  TextEditingController hsncontroller = TextEditingController();
  TextEditingController taxcontroller = TextEditingController();
  TextEditingController mrpcodecontroller = TextEditingController();
  TextEditingController ratecontroller = TextEditingController();
  TextEditingController lpratecodecontroller = TextEditingController();
  String? currentSessionId;
  List<dynamic> salesPersons = [];
  List<Map<String, dynamic>> itemCodeList = [];
  List<Map<String, dynamic>> itemNameList = [];
  List<dynamic> productTypes = EnProductType;
  List<String> cityList = [];
  List<String> areaList = [];
  List<String> brandList = [];
  List<String> categoryList = [];
  List<String> subCategoryList = [];
  List<String> typeList = [];
  List<String> brandCodeList = [];
  List<dynamic> unitList = [];
  String itemCode = '';
  String itemName = '';
  String brand = '';
  String category = '';
  String subCategory = '';
  String type = '';
  String brandCode = '';
  String tax = '0';
  String mrp = '';
  String rate = '0';
  String lprate = '0';
  String unit = '';
  int producttypeid = 1;
  Map<String, dynamic>? salesLedgerObj;
  Map<String, dynamic>? purchaseLedgerObj;
  int? stockPlace;
  List<Map<String, dynamic>> stockPlaceList = [];
  String? stockPlaceName;
  bool _showICTClearIcon = false;
  bool _showNameClearIcon = false;

  @override
  void initState() {
    super.initState();
    loadSessionId();
  }

  void loadSessionId() async {
    String? sessionId = await UserDataUtil.getSessionId();

    if (sessionId != null) {
      setState(() {
        currentSessionId = sessionId;

        getUnits();
        getName();
        getItemCT();
        getList('Brand');
        getList('Category');
        getList('Sizes');
        getList('Type');
        getList('ItemGroup');
        getStockPlaceList();
      });
      print('Loaded currentSessionId: $sessionId');
    } else {
      print('Session ID not found');
    }
  }

  getUnits() async {
    try {
      var requestBody = {"table": 16, "sessionId": currentSessionId};

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          unitList = decodedData;
        });
      } else {}
    } catch (e) {
      print('Error: $e');
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

  getList(columnTxt) async {
    try {
      var requestBody = {
        "table": 0,
        "column": columnTxt,
        "sessionId": currentSessionId
      };

      var response = await distinctService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          for (var item in decodedData) {
            columnTxt == "Brand" ? brandList.add(item['name']) : null;
            columnTxt == "Category" ? categoryList.add(item['name']) : null;
            columnTxt == "Sizes" ? subCategoryList.add(item['name']) : null;
            columnTxt == "Type" ? typeList.add(item['name']) : null;
            columnTxt == "ItemGroup" ? brandCodeList.add(item['name']) : null;
          }
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  void getName() => fetchData("Name", (data) => itemNameList = data);
  void getItemCT() => fetchData("Item_CodeTxt", (data) => itemCodeList = data);

  Future<void> fetchData(String column,
      Function(List<Map<String, dynamic>>) setStateCallback) async {
    try {
      var requestBody = {
        "table": 0,
        "column": column,
        "sessionId": currentSessionId
      };

      var response = await itemFilterService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          setStateCallback(List<Map<String, dynamic>>.from(decodedData));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No details found for $column'),
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

  submit() {
    String formattedFromDate =
        fromDate.text.isNotEmpty ? '${fromDate.text} 00:00:00' : '';
    String formattedToDate =
        toDate.text.isNotEmpty ? '${toDate.text} 23:59:59' : '';
    Map<String, dynamic> filterData = {
      'itemCode': itemCode,
      'itemName': itemName,
      'brand': brand,
      'category': category,
      'subCategory': subCategory,
      'type': type,
      'brandCode': brandCode,
      'fromDate': formattedFromDate,
      'toDate': formattedToDate,
      'stockPlace': stockPlace,
    };
    widget.onSubmit(filterData); // Call the callback with filter data
    Navigator.of(context).pop(); // Close the dialog
  }

  clearFilters() {
    setState(() {
      itemCode = '';
      itemName = '';
      brand = '';
      category = '';
      subCategory = '';
      type = '';
      brandCode = '';
      fromDate.clear();
      toDate.clear();
      stockPlace = null;
      stockPlaceName = null;
    });
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

  void clearTextField(String fieldName, Function(String) setFieldValue,
      Function(bool) setShowClearIcon) {
    setFieldValue('');
    setState(() {
      setShowClearIcon(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final dropDownKey = GlobalKey<DropdownSearchState>();
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
                      buildAutocompleteField(
                          itemCode,
                          'Item Code',
                          itemCodeList,
                          _showICTClearIcon,
                          (value) => itemCode = value,
                          (value) => _showICTClearIcon = value),
                      SizedBox(
                        height: 5,
                      ),
                      buildAutocompleteField(
                          itemName,
                          'Item Name',
                          itemNameList,
                          _showICTClearIcon,
                          (value) => itemName = value,
                          (value) => _showNameClearIcon = value),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownSearch<String>(
                        items: (f, cs) => brandList,
                        popupProps: PopupProps.menu(
                          fit: FlexFit.loose,
                          showSearchBox: true,
                          scrollbarProps:
                              ScrollbarProps(thumbColor: baawan_green),
                        ),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'Brand ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (value) {
                          brand = value ?? '';
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownSearch<String>(
                        items: (f, cs) => categoryList,
                        popupProps: PopupProps.menu(
                          fit: FlexFit.loose,
                          showSearchBox: true,
                          scrollbarProps:
                              ScrollbarProps(thumbColor: baawan_green),
                        ),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'Category ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (value) {
                          category = value ?? '';
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownSearch<String>(
                        items: (f, cs) => subCategoryList,
                        popupProps: PopupProps.menu(
                          fit: FlexFit.loose,
                          showSearchBox: true,
                          scrollbarProps:
                              ScrollbarProps(thumbColor: baawan_green),
                        ),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'Sizes',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (value) {
                          subCategory = value ?? '';
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownSearch<String>(
                        items: (f, cs) => typeList,
                        popupProps: PopupProps.menu(
                          fit: FlexFit.loose,
                          showSearchBox: true,
                          scrollbarProps:
                              ScrollbarProps(thumbColor: baawan_green),
                        ),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (value) {
                          type = value ?? '';
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownSearch<String>(
                        items: (f, cs) => brandCodeList,
                        popupProps: PopupProps.menu(
                          fit: FlexFit.loose,
                          showSearchBox: true,
                          scrollbarProps:
                              ScrollbarProps(thumbColor: baawan_green),
                        ),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'Group',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (value) {
                          brandCode = value ?? '';
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                              labelText: 'Stock Place',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder()),
                          value: stockPlace == 001 ? '' : stockPlaceName,
                          items: [
                            DropdownMenuItem<String>(
                              child: Text('Select Stock Place'), // Empty option
                              value: '', // Default value when stockPlace is 0
                            ),
                            ...stockPlaceList
                                .map((sp) => DropdownMenuItem<String>(
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
                              stockPlaceName =
                                  ''; // Reset stockPlaceName to empty
                            }
                            setState(() {}); // Update the UI
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
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
                          SizedBox(
                              width: 16), // Add spacing between the text fields
                          Expanded(
                            child: TextFormField(
                              controller: toDate,
                              decoration: InputDecoration(
                                hintText: 'To',
                                border: borderStyle,
                              ),
                              onTap: () =>
                                  onTapToDateFunction(context: context),
                            ),
                          ),
                        ],
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
                                clearFilters();
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
                            height: 42,
                            width: 130,
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
                                submit();
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
                      )
                    ],
                  ),
                ))));
  }

  Widget buildAutocompleteField(
      String fieldValue,
      String hintText,
      List<Map<String, dynamic>> optionsList,
      bool showClearIcon,
      Function(String) setFieldValue,
      Function(bool) setShowClearIcon) {
    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Map<String, dynamic>>.empty();
        }
        return optionsList.where((item) {
          return item['name']
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (Map<String, dynamic> option) => option['name'],
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        // Set the controller text based on the fieldValue
        textEditingController.text = fieldValue;
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (text) {
            setState(() {
              setFieldValue(text);
              setShowClearIcon(text.isNotEmpty);
            });
          },
          onSubmitted: (text) {
            focusNode.unfocus();
          },
          decoration: InputDecoration(
            constraints:
                BoxConstraints(minHeight: 48, maxHeight: 48, maxWidth: 348),
            suffixIcon: showClearIcon
                ? IconButton(
                    onPressed: () {
                      clearTextField(
                          fieldValue, setFieldValue, setShowClearIcon);
                    },
                    icon: Icon(color: Colors.black, Icons.close),
                  )
                : null,
            contentPadding: EdgeInsets.all(13),
            hintText: hintText,
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(),
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
              height: 200,
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
              child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> option = options.elementAt(index);
                  return ListTile(
                    title: Text(option['name']),
                    onTap: () {
                      onSelected(option);
                      setState(() {
                        setFieldValue(option['name']);
                        setShowClearIcon(true);
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
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
