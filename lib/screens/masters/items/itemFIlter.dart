import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/services/itemService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemFilterPopup extends StatefulWidget {
  final Function(String, String, String, String, String, String, int)
      onSubmit; // Define callback function
  final Map<String, dynamic>? initialValues;
  final String? filterType;

  ItemFilterPopup(
      {required this.onSubmit, this.initialValues, this.filterType});

  @override
  _ItemFilterPopupState createState() => _ItemFilterPopupState();
}

class _ItemFilterPopupState extends State<ItemFilterPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );

  List<Map<String, dynamic>> itemCodeList = [];
  List<Map<String, dynamic>> itemNameList = [];
  List<Map<String, dynamic>> brandList = [];
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> subCategoryList = [];
  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> brandCodeList = [];
  List<Map<String, dynamic>> stockPlaceList = [];

  String itemCode = '';
  String itemName = '';
  String brand = '';
  String category = '';
  String subCategory = '';
  String type = '';
  String brandCode = '';
  int stockPlace = 0;

  late String currentSessionId;
  bool _showICTClearIcon = false;
  bool _showNameClearIcon = false;
  bool _showBrandClearIcon = false;
  bool _showCategoryClearIcon = false;
  bool _showSubCategoryClearIcon = false;
  bool _showTypeClearIcon = false;
  bool _showBrandCodeClearIcon = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    itemCode = widget.initialValues!['itemName'] ?? '';
    itemCode = widget.initialValues!['itemCode'] ?? '';
    brand = widget.initialValues!['brand'] ?? '';
    category = widget.initialValues!['category'] ?? '';
    subCategory = widget.initialValues!['subCategory'] ?? '';
    type = widget.initialValues!['type'] ?? '';
    brandCode = widget.initialValues!['brandCode'] ?? '';
    stockPlace = widget.initialValues!['stockPlace'] ?? 0;
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
          getItemCT();
          getName();
          getBrand();
          getCategory();
          getSubCategory();
          getType();
          getBrandCode();
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

  Future<void> getStockPlaceList() async {
    try {
      var requestBody = {"table": 4, "sessionId": currentSessionId};

      var response = await itemStockPlaceService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          stockPlaceList = List<Map<String, dynamic>>.from(decodedData);
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

  void getItemCT() => fetchData("Item_CodeTxt", (data) => itemCodeList = data);
  void getBrand() => fetchData("Brand", (data) => brandList = data);
  void getCategory() => fetchData("Category", (data) => categoryList = data);
  void getSubCategory() => fetchData("Sizes", (data) => subCategoryList = data);
  void getType() => fetchData("Type", (data) => typeList = data);
  void getBrandCode() => fetchData("ItemGroup", (data) => brandCodeList = data);
  void getName() => fetchData("Name", (data) => itemNameList = data);

  void submitDate() {
    print('itemCode: $itemCode');
    print('brand: $brand');
    print('category: $category');
    print('subCategory: $subCategory');
    print('type: $type');
    print('brandCode: $brandCode');
    print('stockPlace: $stockPlace');
    widget.onSubmit(
        itemCode, brand, category, subCategory, type, brandCode, stockPlace);
    Navigator.of(context).pop();
  }

  void clearTextField(String fieldName, Function(String) setFieldValue,
      Function(bool) setShowClearIcon) {
    setFieldValue('');
    setState(() {
      setShowClearIcon(false);
    });
  }

  onClearForm() {
    setState(() {
      itemCode = '';
      brand = '';
      category = '';
      subCategory = '';
      subCategory = '';
      type = '';
      brandCode = '';
      stockPlace = 0;
      _showICTClearIcon = false;
      _showBrandClearIcon = false;
      _showCategoryClearIcon = false;
      _showSubCategoryClearIcon = false;
      _showTypeClearIcon = false;
      _showBrandCodeClearIcon = false;
    });
    widget.onSubmit(
        itemCode, brand, category, subCategory, type, brandCode, stockPlace);
    print('itemCode: $itemCode');
    print('brand: $brand');
    print('category: $category');
    print('subCategory: $subCategory');
    print('type: $type');
    print('brandCode: $brandCode');
    print('stockPlace: $stockPlace');
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
            border: borderStyle,
            enabledBorder: borderStyle,
            focusedBorder: borderStyle,
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
        height: 350, // Adjust height to fit all fields
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildAutocompleteField(
                brand,
                'Brand',
                brandList,
                _showBrandClearIcon,
                (value) => brand = value,
                (value) => _showBrandClearIcon = value),
            SizedBox(
              height: 5,
            ),
            buildAutocompleteField(
                category,
                'Category',
                categoryList,
                _showCategoryClearIcon,
                (value) => category = value,
                (value) => _showCategoryClearIcon = value),
            SizedBox(
              height: 5,
            ),
            buildAutocompleteField(
                subCategory,
                'Sub Category',
                subCategoryList,
                _showSubCategoryClearIcon,
                (value) => subCategory = value,
                (value) => _showSubCategoryClearIcon = value),
            SizedBox(
              height: 5,
            ),
            buildAutocompleteField(type, 'Type', typeList, _showTypeClearIcon,
                (value) => type = value, (value) => _showTypeClearIcon = value),
            SizedBox(
              height: 5,
            ),
            buildAutocompleteField(
                brandCode,
                'Brand Code',
                brandCodeList,
                _showBrandCodeClearIcon,
                (value) => brandCode = value,
                (value) => _showBrandCodeClearIcon = value),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 5,
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
            )
          ],
        ),
      ),
    );
  }
}
