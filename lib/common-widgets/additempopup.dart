import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/gradientText.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/global/appCommon.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/itemService.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/sessionIdFetch.dart';
import 'package:mlco/services/syncService.dart';

class addItemPopup extends StatefulWidget {
  final Function(String, String) onSubmit; // Define callback function

  addItemPopup({required this.onSubmit});

  @override
  _addItemPopupState createState() => _addItemPopupState();
}

class _addItemPopupState extends State<addItemPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide:
          BorderSide(width: 1, color: Color.fromRGBO(235, 235, 235, 1)));
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController itemcodecontroller = TextEditingController();
  TextEditingController hsncontroller = TextEditingController();
  TextEditingController taxcontroller = TextEditingController();
  TextEditingController mrpcodecontroller = TextEditingController();
  TextEditingController ratecontroller = TextEditingController();
  TextEditingController lpratecodecontroller = TextEditingController();
  String? currentSessionId;
  List<dynamic> salesPersons = [];
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

  Map<String, dynamic> salesLedgerFilter = {
    "groups": [9],
    "includeChildGroups": true,
  };
  Map<String, dynamic> purchageledgerFilter = {
    "groups": [10],
    "includeChildGroups": true,
  };

  @override
  void initState() {
    super.initState();
    ratecontroller.text = rate;
    taxcontroller.text = tax;
    lpratecodecontroller.text = lprate;
    loadSessionId();
  }

  void loadSessionId() async {
    String? sessionId = await UserDataUtil.getSessionId();

    if (sessionId != null) {
      setState(() {
        currentSessionId = sessionId;

        getUnits();
        getList('Brand');
        getList('Category');
        getList('Sizes');
        getList('Type');
        getList('ItemGroup');
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

  submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      create();
    }
  }

  create() async {
    var taxper = 0.00;
    taxper = double.parse(taxcontroller.text);
    try {
      var requestBody = {
        "id": null,
        "item_ID": null,
        "item_CodeTxt": itemcodecontroller.text,
        "name": namecontroller.text,
        "brand": brand,
        "category": category,
        "sizes": subCategory,
        "type": type,
        "itemGroup": itemCode,
        "hsnNo": hsncontroller.text,
        "mrp": mrpcodecontroller.text,
        "vatPer": taxper,
        "std_Sell_Rate": ratecontroller.text,
        "std_Unit": unit,
        "costing_On": 1,
        "last_Purchaserate": lpratecodecontroller.text,
        "productType": producttypeid,
        "barcode": null,
        "isActive": true,
        "salesLedger_Id_Object": salesLedgerObj,
        "purchaseLegderId_Object": purchaseLedgerObj,
        "isAllowNagativeStock": true,
        "stockMaintain": true,
        "salesAccountLedgerID": salesLedgerObj!['id'],
        "purchaseAccountLedgerID": purchaseLedgerObj!['id'],
        "sessionId": currentSessionId
      };

      var response = await createitemService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (mounted) {
        // Check if the widget is still mounted
        if (response.statusCode == 200) {
          itemSync();
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

  onSalesLedgerChange(String) {}

  onPurchaseLedgerChange(String) {}

  onSalesLedgerSelect(Map<String, dynamic> ledger) {
    setState(() {
      salesLedgerObj = ledger;
    });
  }

  onPurchaseLedgerSelect(Map<String, dynamic> ledger) {
    setState(() {
      purchaseLedgerObj = ledger;
    });
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
                            'Add Item',
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
                            hintText: 'Item Code', border: borderStyle),
                        controller: itemcodecontroller,
                      ),
                      SizedBox(
                        height: 10,
                      ),
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
                            labelText: 'Sub Category ',
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
                            labelText: 'Brand Code',
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'HSN No', border: borderStyle),
                              controller: hsncontroller,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'This field is required.';
                                }
                                // const Text('This field is required');
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: TextFormField(
                            decoration: InputDecoration(
                                hintText: 'TAX %', border: borderStyle),
                            controller: taxcontroller,
                          )),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<int>(
                        value: producttypeid,
                        decoration: InputDecoration(
                          labelText: 'Product Type',
                          border: borderStyle,
                          enabledBorder: borderStyle,
                          focusedBorder: borderStyle,
                        ),
                        items: productTypes
                            .map((sp) => DropdownMenuItem<int>(
                                  child: Text(sp['name']!),
                                  value: sp['id'], // Assign the id as the value
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            producttypeid = value;
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'MRP',
                                  border: borderStyle,
                                  enabledBorder: borderStyle),
                              controller: mrpcodecontroller,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child:
                                DropdownButtonFormField<Map<String, dynamic>>(
                              decoration: InputDecoration(
                                  labelText: 'UOM',
                                  border: borderStyle,
                                  enabledBorder: borderStyle,
                                  focusedBorder: borderStyle),
                              items: unitList
                                  .map((sp) =>
                                      DropdownMenuItem<Map<String, dynamic>>(
                                        child: Text(sp['name']!),
                                        value: sp,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  unit = value['name'];
                                }
                              },
                              validator: (value) {
                                if (unit!.isEmpty) {
                                  return 'This field is required.';
                                }
                                // const Text('This field is required');
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Rate', border: borderStyle),
                              controller: ratecontroller,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: TextFormField(
                            decoration: InputDecoration(
                                hintText: 'Last Pur Rate', border: borderStyle),
                            controller: lpratecodecontroller,
                          )),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SearchLedger2(
                        onTextChanged: onSalesLedgerChange,
                        ledgerFilter: salesLedgerFilter,
                        onledgerSelects: onSalesLedgerSelect,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SearchLedger2(
                        onTextChanged: onPurchaseLedgerChange,
                        ledgerFilter: purchageledgerFilter,
                        onledgerSelects: onPurchaseLedgerSelect,
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
