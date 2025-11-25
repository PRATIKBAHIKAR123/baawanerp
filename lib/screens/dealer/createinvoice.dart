import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/searchItem.dart';
import 'package:mlco/common-widgets/searchbill.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/screens/dealer/dashboard/dealerdashboard.dart';
import 'package:mlco/screens/dealer/dealerbottomNaviagtion.dart';
import 'package:mlco/screens/dealer/dealerdrawer.dart';
import 'package:mlco/screens/dealer/invoice-dialog.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/itemService.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/sessionCheckService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateInvoiceScreen extends StatefulWidget {
  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final borderColor = Colors.grey.shade300;
  final TextStyle cardHeader = TextStyle(
    fontSize: 15,
    color: mlco_green,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle carddate = TextStyle(
    fontSize: 14,
    color: mlco_green,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle cardmaincontent = TextStyle(
    fontSize: 13,
    color: Color.fromRGBO(0, 0, 0, 1),
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle hintStyle = GoogleFonts.plusJakartaSans(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  final TextStyle greyPoppins = GoogleFonts.poppins(
    fontSize: 12,
    color: Color.fromRGBO(113, 113, 113, 1),
    fontWeight: FontWeight.w400,
  );

  final TextStyle cardcontent = TextStyle(
    fontSize: 13,
    color: mlco_green,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle crAmnt = TextStyle(
    fontSize: 13,
    color: Color.fromRGBO(229, 96, 0, 1),
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final BoxDecoration attachmentContainer = BoxDecoration(
    color: Color.fromRGBO(248, 248, 248, 1),
    borderRadius: BorderRadius.circular(8),
  );
  bool isItemLoading = false;
  bool isBtnLoading = false;
  bool isLoading = true;
  bool isDeleteDocLoading = true;

  String userData = '';
  late String currentSessionId;
  Map<String, dynamic> companyData = {};
  List spIds = [0, 1, 2, 3, 4, 5, 6, 7];
  List<Map<String, dynamic>>? Invoices;
  String searchText = '';
  int? itemsid;
  int? ledgerid;
  String selectedLedger = '';
  late int selectedLedgerId;
  bool isUpdateState = false;
  Map<String, dynamic>? selectedItem;
  final ledgerDescription = TextEditingController();
  final referenceNumber = TextEditingController();
  List<Map<String, dynamic>> plantList = [];
  Map<String, dynamic>? _selectedPlant;
  List<Map<String, dynamic>> machineNameList = [];
  Map<String, dynamic>? _selectedMachine;
  int? _selectedPlantID;
  TextEditingController _selectedDate = TextEditingController();
  double itemTotal = 0;
  List<Map<String, dynamic>> selectedItems = [];
  List<dynamic> uploadedFiles = [];
  String billNo = '';
  String ladgerLabel = '';
  int? invoice_typeID;
  bool showLedger = true;
  int quantity = 0;
  final GlobalKey<SearchItemState> _searchItemKey =
      GlobalKey<SearchItemState>();
  TextEditingController _quantityController = TextEditingController();

  late String fromDate;
  late String toDate;
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth = DateTime.now();
  late List<bool> _isExpanded;
  bool _isExpandedAttachments = false;
  bool _isExpandedDesc = false;
  String todaysDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  late FocusNode quantityfocus = FocusNode();

  List<Map<String, String>> totalData = [
    {'Total Qty': '00'},
    {'Total Amount': '00'},
    {'Grand Total': '00'},
  ];
  Map<String, dynamic> ledgerFilter = {
    "groups": [],
    "includeChildGroups": true,
    "lockFreeze": false
  };

  int _selectedIndex = 0;

  void updateDates(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
  }

  void _showLedger() {
    setState(() {
      showLedger = true;
    });

    // Use Future.delayed to wait until the widget is rendered
    Future.delayed(Duration(milliseconds: 100), () {
      //_searchLedgerKey.currentState?.focusLedgerField();
    });
  }

  late ScaffoldMessengerState scaffoldMessenger;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DealerDashboardScreen()),
        );
        break;
      case 1:
        Navigator.pushNamed(context, '/sales');
        break;
      case 2:
        Navigator.pushNamed(context, '/purchase');
        break;
      case 3:
        Navigator.pushNamed(context, '/stock');
        break;
      case 4:
        Navigator.pushNamed(context, '/account');
        break;
      default:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    // Avoid calling ScaffoldMessenger.of(context) here
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    invoice_typeID = 23;
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(lastDayOfMonth);
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        String? currentSessionId = userData['user']['currentSessionId'];
        ledgerid = userData['user']['ledger_ID'];
        companyData = userData['company'];
        if (currentSessionId != null) {
          setState(() {
            this.currentSessionId = currentSessionId;
          });
          print('Loaded currentSessionId: $currentSessionId');
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

  void itemsChange(String items) {
    print('items' + items);
    setState(() {
      searchText = items;
    });
    //getList();
  }

  itemsSelect(Map<String, dynamic> items) {
    print('items' + items.toString());
    itemsid = items['iid'];

    if (itemsid != null) {
      setState(() {
        selectedItem = items;
      });
      print('selectedItem$selectedItem');
    }
    quantityfocus.requestFocus();
  }

  void clearSearchItem() {
    _searchItemKey.currentState?.onClearItem();
  }

  void setSelectedPlantById(int id) {
    final selectedPlant =
        plantList.firstWhere((plant) => plant['id'] == id, orElse: () => {});
    if (selectedPlant.isNotEmpty) {
      setState(() {
        _selectedPlant = selectedPlant;
      });
    } else {
      print('Plant with id $id not found');
    }
  }

  Future<void> getMachinenames() async {
    try {
      var requestBody = {
        "type": 28,
        "table": 22,
        "sessionId": currentSessionId
      };
      //await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          machineNameList = List<Map<String, dynamic>>.from(decodedData);
          print('machineList: $machineNameList');
        });
      }
    } catch (e) {
      print('Error: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  void setSelectedMachineById(int id) {
    final selectedMachine = machineNameList
        .firstWhere((item) => item['id'] == id, orElse: () => {});
    if (selectedMachine.isNotEmpty) {
      setState(() {
        _selectedMachine = selectedMachine;
      });
    } else {
      print('Plant with id $id not found');
    }
  }

  Future<void> getsetupInfo() async {
    try {
      var requestBody = {
        "sessionId": currentSessionId,
        "fromInvoice": true,
        "invtype": 23
      };
      //await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      var response = await getSetupInfoService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          var setupinfoData = decodedData;
          if (setupinfoData.containsKey('groupsAssociated')) {
            ledgerFilter['groups'].addAll(setupinfoData['groupsAssociated']
                .map((group) => group['invGroup']));
          }
          print('setupinfoData: $setupinfoData');
          isLoading = false; // Set loading state to false
        });
      }
    } catch (e) {
      print('Error: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
      setState(() {
        isLoading = false; // Set loading state to false on error
      });
    }
  }

  getLedgers(ledgerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');
    if (ledgerList != null) {
      var ledgers = ledgerList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();

      Map<String, dynamic>? filteredLedger = ledgers.firstWhere(
        (ledger) => ledger['id'] == ledgerId,
      );
      print('filteredLedger$filteredLedger');
      setState(() {
        selectedLedger = filteredLedger['name'];
        selectedLedgerId = filteredLedger['id'];
      });
    }
    // Trigger a rebuild to update the UI
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
    print('itemadded');
    if (selectedItem != null) {
      var fullItem = await getItemInfo(selectedItem!['iid']);
      var pcsresult =
          await selectRate(fullItem['std_Sell_Rate'], fullItem, ledgerid!);

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
        "invType": invoice_typeID,
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
        "rateDiscount": fullItem['discount'],
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
            "invType": invoice_typeID
          },
        ],
        "invoiceItemBatchNo": [],
        "invoiceItemPIDNo": [],
        "invoiceQCListObservation": [],
        "stockplaces": ["KB"]
      };
      clearSearchItem();
      _quantityController.clear();
      selectedItem = null;

      bool itemExists = false;
      calculateTotal();
      setState(() {
        for (var item in selectedItems) {
          if (item['item_ID'] == newItem['item_ID'] &&
              item['amount'] == newItem['amount']) {
            item['std_Qty'] += newItem['std_Qty'];
            item['amount'] = item['std_Qty'] * item['std_Rate'];
            itemExists = true;
            break;
          }
        }

        if (!itemExists) {
          selectedItems.add(newItem);
          _isExpanded = List<bool>.filled(selectedItems.length, false);
        }
      });
      quantityfocus.unfocus();
    }
  }

  calculateTotal() {
    print('caulculatetotal');
    double totalQty = 0.0;
    double totalAmount = 0.0;

    for (var item in selectedItems) {
      // Convert std_Qty and amount to double if they are not already
      double qty = (item['std_Qty'] is int)
          ? (item['std_Qty'] as int).toDouble()
          : item['std_Qty'] as double;
      double amount = (item['amount'] is int)
          ? (item['amount'] as int).toDouble()
          : item['amount'] as double;

      totalQty += qty;
      totalAmount += amount;
    }

    setState(() {
      totalData[0]['Total Qty'] = totalQty.toStringAsFixed(2);
      totalData[1]['Total Amount'] = totalAmount.toStringAsFixed(2);
      totalData[2]['Grand Total'] = totalAmount.toStringAsFixed(2);
    });
  }

  submit() {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select Item'),
        ),
      );
    } else {
      if (selectedItems.isEmpty) {
      } else {
        setState(() {
          isBtnLoading = true;
        });
        submitInvoice();
      }
    }
  }

  submitInvoice() async {
    calculateItemsTotal();
    try {
      var requestBody = {
        "sessionId": currentSessionId,
        "inv_Type": invoice_typeID,
        "spCode": 1,
        "ledger_ID": ledgerid,
        "recBy": "Credit",
        "billStatus": 0,
        "bill_No": '',
        "itemID_Qty": selectedItems.length,
        "date": DateFormat('yyyy/MM/dd 23:59:59').format(DateTime.now()),
        "gstType": 2,
        "invoiceNo": 1,
        "useInCompany": true,
        "invoiceItemDetail": selectedItems,
        "isGenerated": false,
        "isApproved": false,
        "isAuthorised": false,
        "isAuthorized": false,
        "isHold": false,
        "shiptoLedgerID": ledgerid,
        "buyerLedgerID": ledgerid,
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
        "refDate": null,
        "roundOff": -0.1,
        "orderNo": null,
        "orderDate": null,
        "projectSiteId": null,
        "projectSiteAddress": null,
        "item_SubTotal": itemTotal,
        "extra_SubTotal": 0,
        "grandTotal": itemTotal,
        "subsidiaryOption": 0,
        "footerXML": [],
        "footerXMLArray": []
      };

      var response = await createDealerEnqService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (mounted) {
        // Check if the widget is still mounted
        if (response.statusCode == 200) {
          var reqInfo = Map<String, dynamic>.from(decodedData);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DealerDashboardScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        isBtnLoading = false;
      });
      if (mounted) {
        print('Error: $e');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('$e'),
          ),
        );
      }
    }
  }

  calculateItemsTotal() {
    for (var item in selectedItems) {
      if (item['amount'] != null) {
        itemTotal += item['amount'];
      }
    }
  }

  void ledgerChange(String items) {
    // print('items' + items);
    // setState(() {
    //   searchText = items;
    // });
    //getList();
  }

  ledgerSelect(Map<String, dynamic> ledger) {
    if (ledger.isNotEmpty) {
      setState(() {
        selectedLedger = ledger['name'];
        selectedLedgerId = ledger['id'];
      });
    }
  }

  deleteDocument(id, tableId) async {
    setState(() {
      isDeleteDocLoading = true;
    });
    try {
      var requestBody = {
        "id": id,
        "tableId": tableId,
        "sessionId": currentSessionId
      };

      var response = await deleteInvoiceDocService(requestBody);
      var decodedData = jsonDecode(response.body);
      setState(() {
        isDeleteDocLoading = false;
      });

      if (response.statusCode == 200) {}
    } catch (e) {
      print('Error: $e');
      setState(() {
        isDeleteDocLoading = false;
      });
    }
  }

  // Function to increment item quantity
  void itemIncrement(int index) {
    setState(() {
      selectedItems[index]['std_Qty'] =
          (selectedItems[index]['std_Qty'] ?? 0) + 1;
      selectedItems[index]['amount'] = selectedItems[index]['std_Qty'] *
          (selectedItems[index]['std_Rate'] ?? 0);

      selectedItems[index]['invoiceItemSubDetail'][0]['qty'] =
          selectedItems[index]['std_Qty'];
    });
    calculateTotal();
  }

  // Function to decrement item quantity
  void itemDecrement(int index) {
    setState(() {
      if ((selectedItems[index]['std_Qty'] ?? 0) > 1) {
        selectedItems[index]['std_Qty'] -= 1;
        selectedItems[index]['amount'] = selectedItems[index]['std_Qty'] *
            (selectedItems[index]['std_Rate'] ?? 0);

        selectedItems[index]['invoiceItemSubDetail'][0]['qty'] =
            selectedItems[index]['std_Qty'];
      } else {
        selectedItems.removeAt(index);
      }
    });
    calculateTotal();
  }

  lastBillNo() async {
    try {
      var requestBody = {
        "invtype": invoice_typeID,
        "sessionId": currentSessionId
      };

      var response = await createBillNo(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {}
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
  }

  clearForm() {
    setState(() {
      selectedItems = [];
      _quantityController.clear();
      selectedItem = null;
    });
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

  Future<List<dynamic>> getPCList(int itemId) async {
    // Check if the item ID is already in the cached list
    List<Map<String, dynamic>> pcList = [];
    var lst = pcList.where((x) => x['itemId'] == itemId).toList();
    if (lst.isEmpty) {
      // Fetch the item price categories from the server
      var itemPCSList = await getItemPriceCategories(itemId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MLCOAppBar(),
      drawer: DealerDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Card(
                margin: const EdgeInsets.only(bottom: 80),
                color: Colors.white,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 7, vertical: 10),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SearchItem(
                          key: _searchItemKey,
                          onTextChanged: itemsChange,
                          onitemSelects: itemsSelect,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            focusNode: quantityfocus,
                            onChanged: (text) {
                              var qty = int.tryParse(text);
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
                            },
                            decoration: InputDecoration(
                              constraints: BoxConstraints(
                                  minHeight: 48, maxHeight: 48, maxWidth: 348),
                              contentPadding: EdgeInsets.all(13),
                              hintText: 'QTY',
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
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(211, 211, 211, 1)),
                              ),
                            ),
                            maxLines: 1,
                          )),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(20, 38),
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          shadowColor: const Color.fromRGBO(0, 0, 0, 0),
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          addItem();
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Divider(),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: Text(
                                'Item Name',
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
                            flex: 1,
                            child: Container(),
                          )
                        ],
                      ),
                      Divider(),
                      const SizedBox(height: 5),
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
                                String HSN = item['hsn'] ?? '';
                                String SP = item['stockplaces'][0] ?? '';
                                String Unit = item['std_Unit'] ?? '';
                                String Category = item['pc'] ?? '';
                                String Discount =
                                    item['rateDiscount'].toString() ?? '';
                                double StdRate = item['std_Rate'] ?? 0.00;
                                double gstper = item['vatPer'] ?? 0.00;
                                double gst = item['cgstAmt'] +
                                    item['sgstAmt'] +
                                    item['igstAmt'];
                                return Card(
                                  shape: BeveledRectangleBorder(),
                                  color: Colors.white,
                                  margin: EdgeInsets.only(bottom: 10.0),
                                  child: Column(
                                    children: [
                                      customHeader(
                                          index, item, _isExpanded[index]),
                                      _isExpanded[index]
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(children: [
                                                Row(children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      'HSN :${HSN}',
                                                      style: cardmaincontent,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      'SP :${SP} ',
                                                      style: cardmaincontent,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      'Unit :${Unit} ',
                                                      style: cardmaincontent,
                                                    ),
                                                  ),
                                                ]),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Row(children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      'Rate :${CurrencyFormatter.format(StdRate)}',
                                                      style: cardmaincontent,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      'Category : $Category',
                                                      style: cardmaincontent,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      'Disc % :${Discount} ',
                                                      style: cardmaincontent,
                                                    ),
                                                  ),
                                                ]),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Row(children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      'GST % :${gstper}',
                                                      style: cardmaincontent,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      'GST : ${CurrencyFormatter.format(gst)}',
                                                      style: cardmaincontent,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      '',
                                                      style: cardmaincontent,
                                                    ),
                                                  ),
                                                ])
                                              ]))
                                          : Container()
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 42,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.green,
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
                              child: isBtnLoading
                                  ? Container(
                                      height: 20,
                                      width: 20,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isUpdateState ? "Update" : "Create",
                                      style: GoogleFonts.poppins(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 42,
                            width: 140,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 209, 208, 208),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () {
                                clearForm();
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
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DealerBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget customHeader(int index, Map<String, dynamic> item, bool isExpanded) {
    String itemname = item['name'] ?? '';

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
            '${itemname} :',
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
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  selectedItems.removeAt(index);
                });
              },
            )),
      ],
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
