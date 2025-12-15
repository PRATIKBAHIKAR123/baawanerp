import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/additempopup.dart';
import 'package:mlco/common-widgets/addledgerpopup.dart';
import 'package:mlco/common-widgets/searchItem.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/global/appCommon.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/sales/salesQuatation.dart';
import 'package:mlco/services/companyFetch.dart';
import 'package:mlco/services/countryService.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/itemService.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/sessionIdFetch.dart';

class CreateQuotationScreen extends StatefulWidget {
  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  final OutlineInputBorder inputBorderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide:
          BorderSide(width: 1, color: Color.fromRGBO(235, 235, 235, 1)));

  final GlobalKey<SearchItemState3> _searchItemKey =
      GlobalKey<SearchItemState3>();
  final TextStyle cardmaincontent = TextStyle(
    fontSize: 13,
    color: Color.fromRGBO(0, 0, 0, 1),
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );
  final ScrollController _scrollController = ScrollController();
  int formStep = 1;
  List<dynamic> stockPlaceList = [];
  List<dynamic> salesPersons = [];
  List<dynamic> stateList = [];
  List<dynamic> priceCatList = [];
  int invTypeID = 4;
  int? ledgerId;
  int? itemsid;
  Map<String, dynamic>? selectedItem;
  List<Map<String, dynamic>> selectedItems = [];
  Map<String, dynamic>? salesPerson;
  String? currentSessionId;
  Map<String, dynamic>? ledgerObject;
  int? stateId;
  String? priceCategoryTxt;
  String? stockPlaceTxt;
  String stateTxt = '';
  Map<String, dynamic>? company;

  int quantity = 0;
  double rate = 0;
  double discount = 0;
  TextEditingController qtycontroller = TextEditingController();
  TextEditingController ratecontroller = TextEditingController();
  TextEditingController discountcontroller = TextEditingController();
  TextEditingController _selectedDate = TextEditingController();
  TextEditingController _refNo = TextEditingController();
  TextEditingController _refDate = TextEditingController();
  bool isItemLoading = false;
  bool isBtnLoading = false;
  bool isLoading = true;
  late List<bool> _isExpanded;
  int totalRows = 0;
  double totalQty = 0;
  double totalAmount = 0;
  double totalRate = 0;
  double totalGST = 0;
  FocusNode qtyfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    ratecontroller.text = rate.toString();
    discountcontroller.text = discount.toString();
    _selectedDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    loadSessionId();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadSessionId() async {
    String? sessionId = await UserDataUtil.getSessionId();

    company = await CompanyDataUtil.getCompanyFromLocalStorage();
    if (sessionId != null) {
      setState(() {
        currentSessionId = sessionId;
        getSetupInfoData();
        getSalesPersons();
        stateList = loadStatesForLedgerCountry(company!['country']);
      });
      print('Loaded currentSessionId: $sessionId');
    } else {
      print('Session ID not found');
    }
  }

  getSetupInfoData() async {
    try {
      var requestBody = {
        "invtype": invTypeID,
        "fromInvoice": true,
        "sessionId": currentSessionId
      };

      var response = await getSetupInfoService(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          var decodedData = jsonDecode(response.body);

          stockPlaceList = decodedData['stockPlaces'];
          stockPlaceTxt = stockPlaceList.first['name'];
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
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

  getLedgerInfo(ledgerid) async {
    try {
      var requestBody = {"id": ledgerid, "sessionId": currentSessionId};

      var response = await ledgerInfoService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          ledgerObject = decodedData;

          // isLoading = false;
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  ledgerSelect(Map<String, dynamic> ledger) {
    setState(() {
      ledgerId = ledger['id'];
      print('ledger$ledger');
      ledgerObject = ledger;
      salesPerson = salesPersons
          .where((sp) => sp['id'] == ledger['assignedUserId'])
          .first;
      //stateId = stateList.where((sp) => sp['id'] == ledger['state']).first;
    });
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

  void billNoChange(String bill) {}

  void itemsChange(String items) {}

  itemsSelect(Map<String, dynamic> items) async {
    print('items' + items.toString());
    itemsid = items['iid'];
    setState(() {
      selectedItem = items;
    });
    if (itemsid != null) {
      var fullItem = await getItemInfo(selectedItem!['iid']);
      var pcsresult =
          await selectRate(fullItem['std_Sell_Rate'], fullItem, ledgerId!);
      setState(() {
        print('fullItem$fullItem');
        var result = invoiceGridCalculations(
          gstType: 4,
          qty: quantity.toDouble(),
          rate: pcsresult['rate'],
          disc1: 0.0,
          disc2: 0.0,
          disc3: 0.0,
          ratedisc: fullItem['discount'],
          vat: fullItem['vatPer'],
          conversions: 1,
          basecurrency: 0,
          precision: 2,
        );
        quantity = 1;
        qtycontroller.text = quantity.toString();
        discount = fullItem['discount'];
        discountcontroller.text = discount.toString();
        rate = pcsresult['rate'];
        ratecontroller.text = rate.toString();

        if (pcsresult['pc'] == 'None') {
          priceCatList.add({
            'priceCategoryName': 'None',
          });
        }
        priceCategoryTxt = pcsresult['pc'] ?? 'None';
        print('priceCategoryTxt${pcsresult['pc']}');
      });
      qtyfocusNode.requestFocus();
    }
  }

  Future<Map<String, dynamic>> getItemInfo(itemID) async {
    setState(() {
      isItemLoading = true;
    });
    var ItemInfo;
    try {
      var requestBody = {"id": itemID, "sessionId": currentSessionId};

      var response = await getItemInfoService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          ItemInfo = Map<String, dynamic>.from(decodedData);
        });
      }
      setState(() {
        isItemLoading = false;
      });
      return ItemInfo;
    } catch (e) {
      print('Error: $e');
      setState(() {
        isItemLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
    return ItemInfo;
  }

  addItem() async {
    print('itemadded${selectedItem}');
    if (selectedItem != null) {
      var fullItem = await getItemInfo(selectedItem!['iid']);
      var pcsresult =
          await selectRate(fullItem['std_Sell_Rate'], fullItem, ledgerId!);
      print('priceCategoryName${pcsresult['pc']}');
      if (pcsresult['pc'] == 'None') {
        priceCatList.add({
          'priceCategoryName': 'None',
        });
      }
      priceCategoryTxt = pcsresult['pc'] ?? 'None';
      print('fullItem$fullItem');
      var result = invoiceGridCalculations(
        gstType: 4,
        qty: quantity.toDouble(),
        rate: pcsresult['rate'],
        disc1: 0.0,
        disc2: 0.0,
        disc3: 0.0,
        ratedisc: fullItem['discount'],
        vat: fullItem['vatPer'],
        conversions: 1,
        basecurrency: 0,
        precision: 2,
      );

      print('result$result');

      var newItem = {
        "sessionId": currentSessionId,
        "item_ID": selectedItem!['iid'],
        "invType": invTypeID,
        "invoiceNo": 1,
        "std_Qty": quantity,
        "itemDescription": "",
        "hsn": fullItem['hsnNo'],
        "name": selectedItem!['nm'],
        "item_code": selectedItem!['ict'],
        "std_Rate": pcsresult['rate'],
        "std_Unit": fullItem['std_Unit'],
        "pc": pcsresult['pc'],
        "amount": pcsresult['rate'] * quantity,
        "rateDiscount": double.tryParse(discountcontroller.text),
        "cgstPer": result['cgstPer'],
        "cgstAmt": result['cgstAmt'],
        "sgstPer": result['sgstPer'],
        "sgstAmt": result['sgstAmt'],
        "result": result['igstPer'],
        "igstAmt": result['igstAmt'],
        "vatPer": fullItem['vatPer'],
        "invoiceItemSubDetail": [
          {
            "qty": quantity,
            "new0_Against1": false,
            "refName": "",
            "effect": 0,
            "conversion": 1,
            "invType": invTypeID
          },
        ],
        "invoiceItemBatchNo": [],
        "invoiceItemPIDNo": [],
        "invoiceQCListObservation": [],
        "stockplaces": ["KB"]
      };
      selectedItem = null;
      qtycontroller.clear();
      ratecontroller.clear();
      discountcontroller.clear();
      //priceCategoryTxt = 'None';
      clearSearchItem();
      bool itemExists = false;

      setState(() {
        for (var item in selectedItems) {
          if (item['item_ID'] == newItem['item_ID']) {
            item['std_Qty'] += newItem['std_Qty'];
            item['amount'] = item['std_Qty'] * item['std_Rate'];
            itemExists = true;
            for (var subitem in item['invoiceItemSubDetail']) {
              subitem['qty'] += newItem['std_Qty'];
            }
            break;
          }
        }

        if (!itemExists) {
          selectedItems.add(newItem);
          _isExpanded = List<bool>.filled(selectedItems.length, false);
        }
      });
      _scrollToBottom();
      calculateTotal();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  submitInvoice() async {
    //calculateTotal();
    try {
      var requestBody = {
        "sessionId": currentSessionId,
        "inv_Type": invTypeID,
        "spCode": 1,
        "ledger_ID": ledgerId,
        "recBy": "Credit",
        "billStatus": 0,
        "bill_No": '',
        "itemID_Qty": selectedItems.length,
        "date": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "gstType": 2,
        "invoiceNo": 1,
        "useInCompany": true,
        "invoiceItemDetail": selectedItems,
        "isGenerated": false,
        "isApproved": false,
        "isAuthorised": false,
        "isAuthorized": false,
        "isHold": false,
        "shiptoLedgerID": ledgerId,
        "buyerLedgerID": ledgerId,
        "orderItemId": 0,
        "orderQty": 0,
        "orderInvcode": 0,
        "workType": 0,
        "poNumber": "",
        "poRecDate": null,
        "yourRefDate": null,
        "yourRefNo": "",
        "transactionType": 1,
        "poDate": null,
        "departmentId": null,
        "departmentUserId": 113,
        "partyDeliveryAddress": null,
        "companyDeliveryAddress": null,
        "lrNo": null,
        "vehicleNo": null,
        "deliveryBy": null,
        "paymentTerms": null,
        "kindAttention": null,
        "projectName": null,
        "remark": null,
        "otherRefNo": null,
        "otherRefDate": null,
        "note": null,
        "transportBy": null,
        "ledgerOrder": null,
        "ledgerorderNo": null,
        "ledgerContactPerson": null,
        "ledgerContactPersonMobile": "-  -",
        "refInv_Type": null,
        "againstRefNo": null,
        "againstRefDate": null,
        "bomRefName": "",
        "paymentInfo": null,
        "voucherId": null,
        "supplyTo": 96,
        "scheduleDate": DateFormat('yyyy/MM/dd').format(DateTime.now()),
        "invoiceTncMap": [],
        "refNo": null,
        "refDate": _refDate.text.isEmpty ? null : _refDate.text,
        "roundOff": -0.1,
        "orderNo": null,
        "orderDate": null,
        "projectSiteId": null,
        "projectSiteAddress": null,
        "item_SubTotal": totalAmount,
        "extra_SubTotal": 0,
        "grandTotal": totalAmount,
        "subsidiaryOption": 0,
        "footerXML": [],
        "footerXMLArray": []
      };

      var response = await createInvoiceService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (mounted) {
        // Check if the widget is still mounted
        if (response.statusCode == 200) {
          var reqInfo = Map<String, dynamic>.from(decodedData);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SalesQuotationScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        isBtnLoading = false;
      });
      if (mounted) {
        print('Error: $e');
      }
    }
  }

  calculateTotal() {
    print('caulculatetotal');
    double totalqty = 0.0;
    double totalamount = 0.0;
    double totalgst = 0.0;
    double totalrate = 0.0;

    setState(() {
      for (var item in selectedItems) {
        // Convert std_Qty and amount to double if they are not already
        double qty = (item['std_Qty'] is int)
            ? (item['std_Qty'] as int).toDouble()
            : item['std_Qty'] as double;
        double amount = (item['amount'] is int)
            ? (item['amount'] as int).toDouble()
            : item['amount'] as double;
        double rate = (item['std_Rate'] is int)
            ? (item['std_Rate'] as int).toDouble()
            : item['std_Rate'] as double;
        double cgst = (item['cgstAmt'] is int)
            ? (item['cgstAmt'] as int).toDouble()
            : item['cgstAmt'] as double;
        double igst = (item['igstAmt'] is int)
            ? (item['igstAmt'] as int).toDouble()
            : item['igstAmt'] as double;
        double sgst = (item['sgstAmt'] is int)
            ? (item['sgstAmt'] as int).toDouble()
            : item['sgstAmt'] as double;

        amount = (rate - (rate * item['rateDiscount'] / 100)) * qty;
        item['amount'] = (rate - (rate * item['rateDiscount'] / 100)) * qty;
        totalqty += qty;
        totalamount += amount;
        totalrate += rate;
        totalgst = igst + cgst + sgst;
      }

      totalQty = totalqty;
      totalRate = totalrate;
      totalGST = totalgst;
      totalAmount = totalamount;
    });
    print('selectedItems$selectedItems');
  }

  void clearSearchItem() {
    _searchItemKey.currentState?.onClearItem();
  }

  Future<Map<String, dynamic>> selectRate(
      double rate, Map<String, dynamic> item, int ledger) async {
    setState(() {
      isItemLoading = true;
    });
    var result = {
      'rate': rate,
      'pc': 'None',
      'priceCategory': 0,
      'discount': 0
    };
    var ledLst = await getLedgerPCList(ledger);
    var itemPcs = await getPCList(item['id']);
    print('itemPcs$itemPcs');
    var priceBiz = {};

    if (priceBiz.containsKey('discount')) {
      result['discount'] = priceBiz['discount'];
    }

    if (priceBiz.containsKey('rate')) {
      result['rate'] = priceBiz['rate'];
    } else {
      if (ledLst.isNotEmpty && itemPcs.isNotEmpty) {
        for (var ele in ledLst) {
          var allmatch = true;

          if (ele['brand'] != null && item['brand'] != ele['brand']) {
            allmatch = false;
          }

          if (ele['category'] != null && item['category'] != ele['category']) {
            allmatch = false;
          }

          if (ele['sizes'] != null && item['sizes'] != ele['sizes']) {
            allmatch = false;
          }

          if (ele['type'] != null && item['type'] != ele['type']) {
            allmatch = false;
          }

          if (ele['itemGroup'] != null &&
              item['itemGroup'] != ele['itemGroup']) {
            allmatch = false;
          }

          if (allmatch) {
            var itempc = itemPcs
                .where(
                    (x) => x['priceCategoryName'] == ele['priceCategoryName'])
                .toList();

            if (itempc.isNotEmpty) {
              result['rate'] = itempc[0]['rate'];
              result['pc'] = ele['priceCategoryName'];
              result['priceCategory'] = ele['priceCategoryID'];
              break;
            }
          }
        }
      }
    }
    setState(() {
      isItemLoading = false;
    });
    return result;
  }

  Future<List<dynamic>> getPCList(int itemId) async {
    // Check if the item ID is already in the cached list
    List<Map<String, dynamic>> pcList = [];
    var lst = pcList.where((x) => x['itemId'] == itemId).toList();
    if (lst.isEmpty) {
      // Fetch the item price categories from the server
      var itemPCSList = await getItemPriceCategories(itemId);
      priceCatList = itemPCSList ?? [];
      if (itemPCSList != null) {
        pcList.add({'itemId': itemId, 'pcList': itemPCSList});
      }
      return itemPCSList ?? [];
    }
    return lst[0]['pcList'];
  }

  Future<List<dynamic>?> getItemPriceCategories(int itemId) async {
    var itemPcs;
    try {
      var requestBody = {"id": itemId, "sessionId": currentSessionId};

      var response = await itemPriceCatListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        itemPcs = List<dynamic>.from(decodedData);
        return itemPcs;
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
    return null;
  }

  Future<List<dynamic>> getLedgerPCList(int ledgerId) async {
    // Check if the item ID is already in the cached list
    List<Map<String, dynamic>> pcList = [];
    var lst = pcList.where((x) => x['itemId'] == ledgerId).toList();
    if (lst.isEmpty) {
      // Fetch the item price categories from the server
      var ledgerPCSList = await getLedgerPriceCategories(ledgerId);
      if (ledgerPCSList != null) {
        pcList.add({'ledgerId': ledgerId, 'pcList': ledgerPCSList});
      }
      return ledgerPCSList ?? [];
    }
    return lst[0]['pcList'];
  }

  Future<List<dynamic>?> getLedgerPriceCategories(int ledgerId) async {
    var ledgerPcs;
    try {
      var requestBody = {"id": ledgerId, "sessionId": currentSessionId};

      var response = await ledgerPriceCatListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ledgerPcs = List<dynamic>.from(decodedData);
        return ledgerPcs;
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectRefDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _refDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MLCOAppBar(),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 80),
        child: Column(children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, gradient: mlcoGradient),
                  child: IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        if (formStep == 1) {
                          setState(() {
                            Navigator.pop(context);
                          });
                        } else {
                          setState(() {
                            formStep = 1;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.white,
                      )),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'CREATE NEW SALES QUOTATION',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: formStep == 1 ? ledgerForm(context) : ItemForm(context),
            ),
          ),
        ]),
      ),
      bottomSheet: Container(
        height: 56,
        decoration: BoxDecoration(gradient: mlcoGradient),
        child: Center(
          child: formStep == 1
              ? TextButton(
                  onPressed: () {
                    if (ledgerId != null) {
                      setState(() {
                        formStep = 2;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select Ledger'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Next Page',
                    style: TextStyle(color: Colors.white),
                  ))
              : TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return previewPopup(context);
                      },
                    );
                    //submitInvoice();
                  },
                  child: Text(
                    'Preview',
                    style: TextStyle(color: Colors.white),
                  )),
        ),
      ),
    );
  }

  Widget ledgerForm(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 21,
              width: 21,
              decoration:
                  BoxDecoration(gradient: mlcoGradient, shape: BoxShape.circle),
              child: Text(
                '1',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              height: 4,
              width: 140,
              decoration: BoxDecoration(color: Colors.grey),
            ),
            Container(
              alignment: Alignment.center,
              height: 21,
              width: 21,
              decoration:
                  BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
              child: Text('2', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            padding: EdgeInsets.all(10),
            height: 40,
            width: 100,
            decoration: BoxDecoration(
                gradient: mlcoGradient,
                boxShadow: [],
                borderRadius: BorderRadius.circular(6.0)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  //fixedSize: Size(95, 20),
                  backgroundColor: Colors.transparent,
                  elevation: 0),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Text(
                      'Add Ledger',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return addLedgerPopup(
                            onSubmit: (String, Object) {},
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ]),
        const SizedBox(
          height: 20,
        ),
        SearchLedger2(
          onTextChanged: billNoChange,
          onledgerSelects: ledgerSelect,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Bill No.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: inputBorderStyle,
                  enabledBorder: inputBorderStyle,
                  label: Text('Bill No.'),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextFormField(
                controller: _selectedDate,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Bill Date.';
                  }
                  return null;
                },
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
                decoration: InputDecoration(
                    border: inputBorderStyle,
                    enabledBorder: inputBorderStyle,
                    label: Text('Bill Date'),
                    suffixIcon: Image.asset(
                      'assets/icons/Calendar.png',
                      height: 24,
                      width: 24,
                    ),
                    suffixIconConstraints: BoxConstraints(maxHeight: 24)),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        DropdownButtonFormField<String>(
          value: stockPlaceTxt,
          decoration: InputDecoration(
              labelText: 'Stock Place',
              border: inputBorderStyle,
              enabledBorder: inputBorderStyle,
              focusedBorder: inputBorderStyle),
          items: stockPlaceList
              .map((sp) => DropdownMenuItem<String>(
                    child: Text(sp['name']!),
                    value: sp['name'],
                  ))
              .toList(),
          onChanged: (value) {},
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Ref No.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: inputBorderStyle,
                  enabledBorder: inputBorderStyle,
                  label: Text('Ref No.'),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextFormField(
                readOnly: true,
                controller: _refDate,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Ref Date.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    border: inputBorderStyle,
                    enabledBorder: inputBorderStyle,
                    label: Text('Ref Date'),
                    suffixIcon: Image.asset(
                      'assets/icons/Calendar.png',
                      height: 24,
                      width: 24,
                    ),
                    suffixIconConstraints: BoxConstraints(maxHeight: 24)),
                onTap: () {
                  _selectRefDate(context);
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter PO NO.';
            }
            return null;
          },
          decoration: InputDecoration(
            border: inputBorderStyle,
            enabledBorder: inputBorderStyle,
            label: Text('PO NO.'),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        DropdownButtonFormField<int>(
          value: stateId,
          menuMaxHeight: 420,
          decoration: InputDecoration(
              labelText: 'Supply To',
              border: inputBorderStyle,
              enabledBorder: inputBorderStyle,
              focusedBorder: inputBorderStyle),
          items: stateList
              .map((sp) => DropdownMenuItem<int>(
                    child: Text(sp['text']!),
                    value: sp['id'],
                  ))
              .toList(),
          onChanged: (value) {
            var stateObj;
            stateObj = stateList.where((s) => s['id'] == value).first;
            stateTxt = stateObj['text'];
            print('value$value');
          },
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          decoration: InputDecoration(
            border: inputBorderStyle,
            enabledBorder: inputBorderStyle,
            label: Text('Credit Days'),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Map<String, dynamic>>(
                value: salesPerson,
                decoration: InputDecoration(
                    labelText: 'Sales Person',
                    border: inputBorderStyle,
                    enabledBorder: inputBorderStyle,
                    focusedBorder: inputBorderStyle),
                items: salesPersons
                    .map((sp) => DropdownMenuItem<Map<String, dynamic>>(
                          child: Text(sp['name']!),
                          value: sp,
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: 'Ref By',
                    border: inputBorderStyle,
                    enabledBorder: inputBorderStyle,
                    focusedBorder: inputBorderStyle),
                items: stockPlaceList
                    .map((sp) => DropdownMenuItem<String>(
                          child: Text(sp['name']!),
                          value: sp['name'],
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          maxLines: 4,
          decoration: InputDecoration(
            border: inputBorderStyle,
            enabledBorder: inputBorderStyle,
            label: Text('Ship Adrress'),
          ),
        ),
      ],
    );
  }

  Widget ItemForm(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 21,
              width: 21,
              decoration:
                  BoxDecoration(gradient: mlcoGradient, shape: BoxShape.circle),
              child: Text(
                '1',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              height: 4,
              width: 140,
              decoration: BoxDecoration(gradient: mlcoGradient),
            ),
            Container(
              alignment: Alignment.center,
              height: 21,
              width: 21,
              decoration:
                  BoxDecoration(gradient: mlcoGradient, shape: BoxShape.circle),
              child: Text('2', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            padding: EdgeInsets.all(10),
            height: 40,
            width: 100,
            decoration: BoxDecoration(
                gradient: mlcoGradient,
                boxShadow: [],
                borderRadius: BorderRadius.circular(6.0)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  //fixedSize: Size(95, 20),
                  backgroundColor: Colors.transparent,
                  elevation: 0),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Text(
                      'Add Item',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return addItemPopup(
                            onSubmit: (String, Object) {},
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ]),
        const SizedBox(
          height: 20,
        ),
        SearchItem3(
          key: _searchItemKey,
          onTextChanged: itemsChange,
          onitemSelects: itemsSelect,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: qtycontroller,
                focusNode: qtyfocusNode,
                onChanged: (value) {
                  var qty = int.tryParse(value);
                  if (qty != null) {
                    setState(() {
                      quantity = qty;
                    });
                  } else {
                    setState(() {
                      quantity =
                          0; // or handle the invalid input case as needed
                    });
                  }

                  if (value == '0') {
                    setState(() {
                      qtycontroller.text = '1';
                      quantity = 1;
                    });
                  }
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter QTY.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: inputBorderStyle,
                  enabledBorder: inputBorderStyle,
                  label: Text('QTY.'),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: priceCategoryTxt,
                menuMaxHeight: 420,
                decoration: InputDecoration(
                    labelText: 'Category',
                    border: inputBorderStyle,
                    enabledBorder: inputBorderStyle,
                    focusedBorder: inputBorderStyle),
                items: priceCatList
                    .map((sp) => DropdownMenuItem<String>(
                          child: Text(sp['priceCategoryName']),
                          value: sp['priceCategoryName'],
                        ))
                    .toList(),
                onChanged: (value) {
                  print('value$value');
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: TextFormField(
                controller: ratecontroller,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Rate.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: inputBorderStyle,
                  enabledBorder: inputBorderStyle,
                  label: Text('Rate'),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 4,
              child: TextFormField(
                controller: discountcontroller,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Discount.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: inputBorderStyle,
                  enabledBorder: inputBorderStyle,
                  label: Text('Discount.'),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 50,
                  width: 40,
                  decoration: BoxDecoration(
                      gradient: mlcoGradient,
                      boxShadow: [],
                      borderRadius: BorderRadius.circular(6.0)),
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        addItem();
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      )),
                ))
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
                flex: 5,
                child: Text(
                  'Item Code',
                  style: cardmaincontent,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  'Qty',
                  style: cardmaincontent,
                  textAlign: TextAlign.center,
                )),
            Expanded(
                flex: 3,
                child: Text(
                  'Amount',
                  style: cardmaincontent,
                  textAlign: TextAlign.center,
                )),
            Expanded(
              flex: 3,
              child: Container(),
            )
          ],
        ),
        isItemLoading
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: mlco_green,
                      strokeWidth: 3,
                    ),
                  )
                ],
              )
            : Column(
                children: selectedItems.map<Widget>((item) {
                  int index = selectedItems.indexOf(item);
                  String itemName = item['name'] ?? '';
                  String HSN = item['hsn'] ?? '';
                  String SP = item['stockplaces'][0] ?? '';
                  String Unit = item['std_Unit'] ?? '';
                  String Category = item['pc'] ?? '';
                  String Discount = item['rateDiscount'].toString() ?? '';
                  double StdRate = item['std_Rate'] ?? 0.00;
                  double gstper = item['vatPer'] ?? 0.00;
                  double gst =
                      item['cgstAmt'] + item['sgstAmt'] + item['igstAmt'];
                  return Card(
                    shape: BeveledRectangleBorder(),
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: [
                        customHeader(index, item, _isExpanded[index]),
                        _isExpanded[index]
                            ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${itemName}',
                                          style: cardmaincontent,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(children: [
                                    Expanded(
                                        flex: 6,
                                        child: Row(children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'HSN',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              ':',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${HSN}',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                        ])),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                        flex: 6,
                                        child: Row(children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'SP',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              ':',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${SP} ',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                        ])),
                                  ]),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(children: [
                                    Expanded(
                                        flex: 6,
                                        child: Row(children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Rate',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              ':',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '₹${formatAmount(StdRate)}',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                        ])),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                        flex: 6,
                                        child: Row(children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Unit',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              ':',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${Unit} ',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                        ])),
                                  ]),
                                  Row(children: [
                                    Expanded(
                                        flex: 6,
                                        child: Row(children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Category',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              ':',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '$Category',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                        ])),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                        flex: 6,
                                        child: Row(children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Disc',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              ':',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${Discount} ',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                        ])),
                                  ]),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(children: [
                                    Expanded(
                                        flex: 6,
                                        child: Row(children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${company!.taxLabel}',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              ':',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${gstper}',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                        ])),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                        flex: 6,
                                        child: Row(children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${company!.taxLabelForExtraCharges}',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              ':',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '₹${formatAmount(gst)}',
                                              style: cardmaincontent,
                                            ),
                                          ),
                                        ])),
                                  ]),
                                ]))
                            : Container()
                      ],
                    ),
                  );
                }).toList(),
              ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: totalBottomsheet(),
        )
      ],
    );
  }

  Widget customHeader(int index, Map<String, dynamic> item, bool isExpanded) {
    String itemname = item['name'] ?? '';
    String itemcode = item['item_code'] ?? '';
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                for (int i = 0; i < _isExpanded.length; i++) {
                  _isExpanded[i] = i == index ? !_isExpanded[i] : false;
                }
              });
            },
            child: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            '${itemcode} :',
            style: cardmaincontent,
          ),
        ),
        Expanded(
          flex: 2,
          child: FittedBox(
            // Ensure the text fits within the container
            fit: BoxFit.scaleDown,
            child: Text(
              '${item['std_Qty']}',
              textAlign: TextAlign.right,
              style: cardmaincontent,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: FittedBox(
            // Ensure the text fits within the container
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${formatItemAmount(item['amount'])}',
              textAlign: TextAlign.right,
              style: cardmaincontent,
            ),
          ),
        ),
        Expanded(
            flex: 3,
            child: Row(children: [
              IconButton(
                constraints: BoxConstraints(maxWidth: 1),
                icon: Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    selectedItems.removeAt(index);
                    calculateTotal();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ItemEditPopup(context, item);
                    },
                  );
                },
              )
            ])),
      ],
    );
  }

  Widget totalBottomsheet() {
    final TextStyle maincontent = TextStyle(
      fontSize: 15,
      color: Color.fromRGBO(0, 0, 0, 1),
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
    );
    return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: mlcoGradient, borderRadius: BorderRadius.circular(5)),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Total Qty',
                  style: maincontent,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  ':',
                  style: maincontent,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${totalQty}',
                  style: maincontent,
                ),
              ),
            ]),

            Row(children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Total ${company!.taxLabelForExtraCharges}',
                  style: maincontent,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  ':',
                  style: maincontent,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${formatItemAmount(totalGST)}',
                  style: maincontent,
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Total Rate',
                  style: maincontent,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  ':',
                  style: maincontent,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${formatItemAmount(totalRate)}',
                  style: maincontent,
                ),
              ),
            ]),
            // Row(
            //   children: [
            //     Text(
            //       'Total Rate : ${formatItemAmount(totalRate)}',
            //       style: maincontent,
            //     ),
            //   ],
            // ),
            Row(children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Total Amount',
                  style: maincontent,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  ':',
                  style: maincontent,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${formatItemAmount(totalAmount)}',
                  style: maincontent,
                ),
              ),
            ]),
            // Row(
            //   children: [
            //     Text(
            //       'Total Amount : ${formatItemAmount(totalAmount)}',
            //       style: maincontent,
            //     ),
            //   ],
            // ),
          ],
        ));
  }

  Widget previewPopup(BuildContext context) {
    final TextStyle mainTitle = TextStyle(
      fontSize: 16,
      color: Color.fromRGBO(0, 0, 0, 1),
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
    );
    final TextStyle lblText = TextStyle(
      fontSize: 13,
      color: Color.fromRGBO(129, 129, 129, 1),
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
    );
    final TextStyle valuetxt = TextStyle(
      fontSize: 13,
      color: Color.fromRGBO(0, 0, 0, 1),
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
    );
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, gradient: mlcoGradient),
                  child: IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.white,
                      )),
                ),
                SizedBox(width: 30),
                Text(
                  'Preview Details',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  '${ledgerObject?['name'] ?? ''}',
                  style: mainTitle,
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Stock Place',
                    style: lblText,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '-',
                    style: lblText,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${stockPlaceTxt ?? ''}',
                    style: mainTitle,
                  ),
                ),
                // Text(
                //   'Stock Place - ',
                //   style: lblText,
                // ),
                // Text(
                //   '${stockPlaceTxt ?? ''}',
                //   style: mainTitle,
                // )
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Supply To',
                    style: lblText,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '-',
                    style: lblText,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${stateTxt}',
                    style: valuetxt,
                  ),
                ),
                // Text(
                //   'Supply To - ',
                //   style: lblText,
                // ),
                // Text(
                //   '${stateTxt}',
                //   style: valuetxt,
                // )
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Sales Person',
                    style: lblText,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '-',
                    style: lblText,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${salesPerson != null ? salesPerson!['name'] : ''}',
                    style: valuetxt,
                  ),
                ),
                // Text(
                //   'Sales Person - ',
                //   style: lblText,
                // ),
                // Text(
                //   '${salesPerson != null ? salesPerson!['name'] : ''}',
                //   style: valuetxt,
                // )
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            Expanded(
              child: ListView.builder(
                  itemCount: selectedItems?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (selectedItems == null || selectedItems.isEmpty) {
                      return Center(
                        child: Text('No Items found'),
                      );
                    }
                    var item = selectedItems[index];
                    String HSN = item['hsn'] ?? '';
                    String SP = item['stockplaces'][0] ?? '';
                    String Unit = item['std_Unit'] ?? '';
                    String Category = item['pc'] ?? '';
                    String Discount = item['rateDiscount'].toString() ?? '';
                    double StdRate = item['std_Rate'] ?? 0.00;
                    double gstper = item['vatPer'] ?? 0.00;
                    double gst =
                        item['cgstAmt'] + item['sgstAmt'] + item['igstAmt'];
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Item',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '-',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${item['name'] ?? ''}',
                                  style: valuetxt,
                                ),
                              ),
                              // Text(
                              //   'Item - ',
                              //   style: lblText,
                              // ),
                              // Expanded(
                              //     child: Text(
                              //   '${item['name'] ?? ''}',
                              //   style: valuetxt,
                              //   overflow: TextOverflow.ellipsis,
                              // ))
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Category',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '-',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${item['pc'] ?? ''}',
                                  style: valuetxt,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Text(
                              //   'Category - ',
                              //   style: lblText,
                              // ),
                              // Expanded(
                              //     child: Text(
                              //   '${item['pc'] ?? ''}',
                              //   style: valuetxt,
                              //   overflow: TextOverflow.ellipsis,
                              // ))
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Qty',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '-',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${item['std_Qty'] ?? ''}',
                                  style: valuetxt,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Text(
                              //   'Qty - ',
                              //   style: lblText,
                              // ),
                              // Text(
                              //   '${item['std_Qty'] ?? ''}',
                              //   style: valuetxt,
                              //   overflow: TextOverflow.ellipsis,
                              // )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Discount',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '-',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${formatItemAmount(item['rateDiscount'] ?? 0) ?? ''}',
                                  style: valuetxt,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Text(
                              //   'Discount - ',
                              //   style: lblText,
                              // ),
                              // Text(
                              //   '${formatItemAmount(item['rateDiscount'] ?? 0) ?? ''}',
                              //   style: valuetxt,
                              //   overflow: TextOverflow.ellipsis,
                              // )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Rate',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '-',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '₹${formatAmount(StdRate)}',
                                  style: valuetxt,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Row(
                              //   children: [
                              //     Text(
                              //       'Rate - ',
                              //       style: lblText,
                              //     ),
                              //     Text(
                              //       '₹${formatAmount(StdRate)}',
                              //       style: valuetxt,
                              //       overflow: TextOverflow.ellipsis,
                              //     )
                              //   ],
                              // ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${company!.taxLabel}',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '-',
                                  style: lblText,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${formatItemAmount(gstper ?? 0) ?? ''}',
                                  style: valuetxt,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            if (selectedItems.isNotEmpty)
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
                        submitInvoice();
                      },
                      child: Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget ItemEditPopup(BuildContext context, item) {
    final TextStyle mainTitle = TextStyle(
      fontSize: 16,
      color: Color.fromRGBO(0, 0, 0, 1),
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
    );
    final TextStyle lblText = TextStyle(
      fontSize: 13,
      color: Color.fromRGBO(129, 129, 129, 1),
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
    );
    final TextStyle valuetxt = TextStyle(
      fontSize: 13,
      color: Color.fromRGBO(0, 0, 0, 1),
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
    );
    return Dialog(
      child: Container(
        height: 480,
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, gradient: mlcoGradient),
                  child: IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.white,
                      )),
                ),
                SizedBox(width: 30),
                Text(
                  'Item Edit',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextFormField(
                initialValue: item['std_Qty'].toString(),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter QTY';
                  }
                  return null;
                },
                onChanged: (value) {
                  item['std_Qty'] = double.tryParse(value);
                },
                decoration: InputDecoration(
                  border: inputBorderStyle,
                  enabledBorder: inputBorderStyle,
                  label: Text('QTY'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextFormField(
                initialValue: item['std_Rate'].toString(),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Rate';
                  }
                  return null;
                },
                onChanged: (value) {
                  item['std_Rate'] = double.tryParse(value);
                },
                decoration: InputDecoration(
                  border: inputBorderStyle,
                  enabledBorder: inputBorderStyle,
                  label: Text('Rate'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 4,
              child: TextFormField(
                initialValue: item['rateDiscount'].toString(),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Discount.';
                  }
                  return null;
                },
                onChanged: (value) {
                  item['rateDiscount'] = double.tryParse(value);
                },
                decoration: InputDecoration(
                  border: inputBorderStyle,
                  enabledBorder: inputBorderStyle,
                  label: Text('Discount.'),
                ),
              ),
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
                      calculateTotal();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Object formatItemAmount(dynamic amount) {
  try {
    final double amountDouble = amount is int ? amount.toDouble() : amount;
    final NumberFormat numberFormat = NumberFormat("#,##,##0.00", "en_IN");
    return numberFormat.format(amountDouble);
  } catch (e) {
    return amount; // Return the original value if parsing fails
  }
}
