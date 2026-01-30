import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mlco/screens/sales/salesProformaInvoice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mlco/common-widgets/addledgerpopup.dart';
import 'package:mlco/common-widgets/additempopup.dart';
import 'package:mlco/common-widgets/searchItem.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/services/itemService.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/services/companyFetch.dart';
import 'package:mlco/services/invoiceService.dart';

class CreateSalesChalanScreen extends StatefulWidget {
  final InvoiceType invoiceType;
  const CreateSalesChalanScreen(
      {Key? key, this.invoiceType = InvoiceType.salesChalan})
      : super(key: key);

  @override
  State<CreateSalesChalanScreen> createState() =>
      _CreateSalesChalanScreenState();
}

class _CreateSalesChalanScreenState extends State<CreateSalesChalanScreen> {
  int? ledgerId;
  String? currentSessionId;
  bool isItemLoading = false;
  int quantity = 1;
  double rate = 0.0;
  List<dynamic> priceCatList = [];
  Map<String, dynamic>? selectedItem;
  List<Map<String, dynamic>> selectedItems = [];
  List<bool> _isExpanded = [];

  TextEditingController qtyController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  String? priceCategoryTxt;
  List<dynamic> stockPlaceList = [];
  String? stockPlaceTxt;

  final GlobalKey<SearchItemState3> _searchItemKey =
      GlobalKey<SearchItemState3>();
  final OutlineInputBorder inputBorderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide:
          BorderSide(width: 1, color: Color.fromRGBO(235, 235, 235, 1)));
  ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? company;
  bool isBtnLoading = false;
  double totalQty = 0;
  double totalAmount = 0;
  double totalRate = 0;
  double totalGST = 0;

  final TextStyle cardmaincontent = TextStyle(
    fontSize: 13,
    color: Color.fromRGBO(0, 0, 0, 1),
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  @override
  void initState() {
    super.initState();
    qtyController.text = quantity.toString();
    loadSessionId();
  }

  void loadSessionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    company = await CompanyDataUtil.getCompanyFromLocalStorage();

    if (userDataString != null) {
      Map<String, dynamic> userData = jsonDecode(userDataString);
      setState(() {
        currentSessionId = userData['user']['currentSessionId'];
        getSetupInfoData();
      });
    }
  }

  getSetupInfoData() async {
    try {
      var requestBody = {
        "invtype": widget.invoiceType.id,
        "fromInvoice": true,
        "sessionId": currentSessionId
      };

      var response = await getSetupInfoService(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          var decodedData = jsonDecode(response.body);
          stockPlaceList = decodedData['stockPlaces'] ?? [];
          if (stockPlaceList.isNotEmpty) {
            stockPlaceTxt = stockPlaceList.first['name'];
          }
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  itemsSelect(Map<String, dynamic> items) async {
    print('items' + items.toString());
    setState(() {
      selectedItem = items;
    });
    if (items['iid'] != null && ledgerId != null) {
      var fullItem = await getItemInfo(items['iid']);
      if (fullItem != null) {
        var pcsresult =
            await selectRate(fullItem['std_Sell_Rate'], fullItem, ledgerId!);
        setState(() {
          quantity = 1;
          qtyController.text = quantity.toString();
          rate = pcsresult['rate'] ?? 0.0;
          rateController.text = rate.toString();

          if (pcsresult['pc'] == 'None') {
            priceCatList.add({
              'priceCategoryName': 'None',
            });
          }
          priceCategoryTxt = pcsresult['pc'] ?? 'None';
          discountController.text = (fullItem['discount'] ?? 0).toString();
        });
      }
    } else if (ledgerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a ledger first"),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> getItemInfo(itemID) async {
    setState(() {
      isItemLoading = true;
    });
    var ItemInfo;
    try {
      var requestBody = {"id": itemID, "sessionId": currentSessionId};

      var response =
          await getItemInfoService(requestBody); // Ensure this is imported
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ItemInfo = Map<String, dynamic>.from(decodedData);
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
    return null;
  }

  void clearSearchItem() {
    _searchItemKey.currentState?.onClearItem();
  }

  addItem() async {
    if (selectedItem != null) {
      var fullItem = await getItemInfo(selectedItem!['iid']);
      if (fullItem == null) return;

      var pcsresult =
          await selectRate(fullItem['std_Sell_Rate'], fullItem, ledgerId!);

      if (pcsresult['pc'] == 'None') {
        priceCatList.add({
          'priceCategoryName': 'None',
        });
      }
      priceCategoryTxt = pcsresult['pc'] ?? 'None';

      // Typically Chalan uses different ID, utilizing widget.invoiceType.id
      int invTypeID = widget.invoiceType.id;

      var result = invoiceGridCalculations(
        gstType: invTypeID, // Using invoice ID as GST Type proxy or logic
        qty: quantity.toDouble(),
        rate: pcsresult['rate'],
        disc1: 0.0,
        disc2: 0.0,
        disc3: 0.0,
        ratedisc: double.tryParse(discountController.text) ??
            fullItem['discount'] ??
            0.0,
        vat: fullItem['vatPer'] ?? 0.0,
        conversions: 1,
        basecurrency: 0,
        precision: 2,
      );

      int spId = 1;
      if (stockPlaceList.isNotEmpty) {
        var sp = stockPlaceList.firstWhere(
            (element) => element['name'] == stockPlaceTxt,
            orElse: () => {'spId': 1});
        spId = sp['spId'] ?? 1;
      }

      var newItem = {
        "sessionId": currentSessionId,
        "item_ID": selectedItem!['iid'],
        "invType": invTypeID,
        "invoiceNo": 1,
        "std_Qty": quantity,
        "itemDescription": "",
        "hsn": fullItem['hsnNo'] ?? "",
        "name": selectedItem!['nm'],
        "item_code": selectedItem!['ict'],
        "std_Rate": rateController.text.isNotEmpty
            ? double.parse(rateController.text)
            : pcsresult['rate'],
        "std_Unit": fullItem['std_Unit'] ?? "",
        "pc": pcsresult['pc'],
        "amount": pcsresult['rate'] * quantity,
        "rateDiscount": double.tryParse(discountController.text) ?? 0.0,
        "cgstPer": result['cgstPer'],
        "cgstAmt": result['cgstAmt'],
        "sgstPer": result['sgstPer'],
        "sgstAmt": result['sgstAmt'],
        "result": result['igstPer'],
        "igstAmt": result['igstAmt'],
        "vatPer": fullItem['vatPer'],
        "sp_Code": spId,
        "sp_text": stockPlaceTxt,
        "unittext": fullItem['std_Unit'],
        "particular": selectedItem!['nm'] ?? "",
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
        "stockplaces": [stockPlaceTxt ?? ""]
      };

      selectedItem = null;
      qtyController.clear();
      rateController.clear();
      discountController.clear();
      clearSearchItem();
      bool itemExists = false;

      setState(() {
        for (var item in selectedItems) {
          if (item['item_ID'] == newItem['item_ID']) {
            item['std_Qty'] = (item['std_Qty'] ?? 0) + newItem['std_Qty'];
            item['amount'] = item['std_Qty'] * item['std_Rate'];
            // Update subdetails... omitted for brevity
            itemExists = true;
            break;
          }
        }

        if (!itemExists) {
          selectedItems.add(newItem);
          _isExpanded =
              List<bool>.filled(selectedItems.length, false, growable: true);
        }
      });
      _scrollToBottom();
      calculateTotal();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  calculateTotal() {
    double totalqty = 0.0;
    double totalamount = 0.0;
    double totalgst = 0.0;
    double totalrate = 0.0;

    setState(() {
      for (var item in selectedItems) {
        double qty = (item['std_Qty'] is int)
            ? (item['std_Qty'] as int).toDouble()
            : (item['std_Qty'] as double? ?? 0.0);
        double rate = (item['std_Rate'] is int)
            ? (item['std_Rate'] as int).toDouble()
            : (item['std_Rate'] as double? ?? 0.0);
        double cgst = (item['cgstAmt'] is int)
            ? (item['cgstAmt'] as int).toDouble()
            : (item['cgstAmt'] as double? ?? 0.0);
        double igst = (item['igstAmt'] is int)
            ? (item['igstAmt'] as int).toDouble()
            : (item['igstAmt'] as double? ?? 0.0);
        double sgst = (item['sgstAmt'] is int)
            ? (item['sgstAmt'] as int).toDouble()
            : (item['sgstAmt'] as double? ?? 0.0);
        double discount = (item['rateDiscount'] is int)
            ? (item['rateDiscount'] as int).toDouble()
            : (item['rateDiscount'] as double? ?? 0.0);

        item['amount'] = (rate - (rate * discount / 100)) * qty;
        totalqty += qty;
        totalamount += item['amount'];
        totalrate += rate;
        totalgst += (igst + cgst + sgst);
      }

      totalQty = totalqty;
      totalRate = totalrate;
      totalGST = totalgst;
      totalAmount = totalamount;
    });
  }

  submitInvoice() async {
    try {
      int spId = 1;
      if (stockPlaceList.isNotEmpty) {
        var sp = stockPlaceList.firstWhere(
            (element) => element['name'] == stockPlaceTxt,
            orElse: () => {'spId': 1});
        spId = sp['spId'] ?? 1;
      }

      var requestBody = {
        "sessionId": currentSessionId,
        "inv_Type": widget.invoiceType.id,
        "spCode": spId,
        "ledger_ID": ledgerId,
        "recBy": "Credit",
        "billStatus": 0,
        "bill_No": '',
        "itemID_Qty": selectedItems.length,
        "date": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "gstType": 2, // Default
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
        "refDate": null,
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
        "footerXMLArray": [],
      };

      var response = await createInvoiceService(requestBody);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dispatch Note Created Successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProformaInvoiceScreen(
                    invoiceType: InvoiceType.salesChalan,
                  )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${response.body}')),
        );

        print(response.body);
      }
    } catch (e) {
      print("Error submitting: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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

    if (ledLst.isNotEmpty && itemPcs.isNotEmpty) {
      for (var ele in ledLst) {
        var allmatch = true;
        if (ele['brand'] != null && item['brand'] != ele['brand'])
          allmatch = false;
        if (ele['category'] != null && item['category'] != ele['category'])
          allmatch = false;
        if (ele['sizes'] != null && item['sizes'] != ele['sizes'])
          allmatch = false;
        if (ele['type'] != null && item['type'] != ele['type'])
          allmatch = false;
        if (ele['itemGroup'] != null && item['itemGroup'] != ele['itemGroup'])
          allmatch = false;

        if (allmatch) {
          var itempc = itemPcs
              .where((x) => x['priceCategoryName'] == ele['priceCategoryName'])
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

    setState(() {
      isItemLoading = false;
    });
    return result;
  }

  Future<List<dynamic>> getPCList(int itemId) async {
    var itemPCSList = await getItemPriceCategories(itemId);
    priceCatList = itemPCSList ?? [];
    return itemPCSList ?? [];
  }

  Future<List<dynamic>?> getItemPriceCategories(int itemId) async {
    try {
      var requestBody = {"id": itemId, "sessionId": currentSessionId};
      var response = await itemPriceCatListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return List<dynamic>.from(decodedData);
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<List<dynamic>> getLedgerPCList(int ledgerId) async {
    var ledgerPCSList = await getLedgerPriceCategories(ledgerId);
    return ledgerPCSList ?? [];
  }

  Future<List<dynamic>?> getLedgerPriceCategories(int ledgerId) async {
    try {
      var requestBody = {"id": ledgerId, "sessionId": currentSessionId};
      var response = await ledgerPriceCatListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return List<dynamic>.from(decodedData);
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MLCOAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CREATE NEW ${widget.invoiceType.name.toUpperCase().replaceAll('-', ' ')}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),

                        // Ledger Section
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    0.77, // Adjusted
                                child: SearchLedger2(
                                  onTextChanged: (val) {},
                                  onledgerSelects: (ledger) {
                                    setState(() {
                                      ledgerId = ledger['id'];
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 4),
                              Container(
                                  padding: EdgeInsets.all(6),
                                  height: 52,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      gradient: mlcoGradient,
                                      borderRadius: BorderRadius.circular(6.0)),
                                  child: GestureDetector(
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
                                      child: Center(
                                          child: Icon(Icons.add,
                                              color: Colors.white))))
                            ]),
                        SizedBox(height: 10),
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
                          onChanged: (value) {
                            setState(() {
                              stockPlaceTxt = value;
                            });
                          },
                        ),
                        SizedBox(height: 10),

                        SizedBox(height: 20),
                        // Item Section
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.77,
                                child: SearchItem3(
                                  key: _searchItemKey,
                                  onTextChanged: (val) {},
                                  onitemSelects: (item) {
                                    itemsSelect(item);
                                  },
                                ),
                              ),
                              SizedBox(width: 4),
                              Container(
                                  padding: EdgeInsets.all(6),
                                  height: 52,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      gradient: mlcoGradient,
                                      borderRadius: BorderRadius.circular(6.0)),
                                  child: GestureDetector(
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
                                      child: Center(
                                          child: Icon(Icons.add,
                                              color: Colors.white))))
                            ]),
                        SizedBox(height: 10),
                        if (isItemLoading)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: LinearProgressIndicator(),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: qtyController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    quantity = int.tryParse(value) ?? 1;
                                  });
                                },
                                decoration: InputDecoration(
                                    border: inputBorderStyle,
                                    enabledBorder: inputBorderStyle,
                                    labelText: 'QTY'),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: rateController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    border: inputBorderStyle,
                                    enabledBorder: inputBorderStyle,
                                    labelText: 'Rate'),
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                                padding: EdgeInsets.all(10),
                                height: 52,
                                width: 50,
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
                                    )))
                          ],
                        ),
                        SizedBox(height: 30),

                        // Items List Header
                        Row(
                          children: [
                            Expanded(flex: 1, child: Container()),
                            Expanded(
                                flex: 5,
                                child:
                                    Text('Item Code', style: cardmaincontent)),
                            Expanded(
                                flex: 2,
                                child: Text('Qty',
                                    style: cardmaincontent,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 3,
                                child: Text('Amount',
                                    style: cardmaincontent,
                                    textAlign: TextAlign.center)),
                            Expanded(flex: 3, child: Container()),
                          ],
                        ),
                        // Items List
                        Column(
                          children: selectedItems.map<Widget>((item) {
                            int index = selectedItems.indexOf(item);
                            String itemName = item['name'] ?? '';
                            String HSN = item['hsn'] ?? '';
                            String SP = stockPlaceTxt!.isNotEmpty
                                ? stockPlaceTxt
                                : (item['stockplaces'] as List).isNotEmpty
                                    ? item['stockplaces'][0]
                                    : '';
                            String Unit = item['std_Unit'] ?? '';
                            String Category = item['pc'] ?? '';
                            String Discount = item['rateDiscount'].toString();
                            double StdRate = item['std_Rate'] ?? 0.00;
                            double gstper = item['vatPer'] ?? 0.00;
                            double gst = (item['cgstAmt'] ?? 0.0) +
                                (item['sgstAmt'] ?? 0.0) +
                                (item['igstAmt'] ?? 0.0);

                            return Card(
                              shape: BeveledRectangleBorder(),
                              color: Colors.white,
                              margin: EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: [
                                  customHeader(index, item, _isExpanded[index]),
                                  if (_isExpanded[index])
                                    Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${itemName}',
                                                  style: cardmaincontent,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                          if (company != null)
                                            Row(children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: Row(children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        '${company?.taxLabel ?? 'Tax'}',
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
                                                        '${company?.taxLabelForExtraCharges ?? 'Tax Amt'}',
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
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 20),
                        if (selectedItems.isNotEmpty) totalBottomsheet(),
                        SizedBox(height: 80), // Footer spacing
                      ]),
                ),
              ),

              // Bottom Submit Button
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                    gradient: mlcoGradient,
                    borderRadius: BorderRadius.circular(10.0)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent),
                  onPressed: () {
                    submitInvoice();
                  },
                  child: Text(
                    'Submit Dispatch Note',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget customHeader(int index, Map<String, dynamic> item, bool isExpanded) {
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
              size: 24,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            '${itemcode}',
            style: cardmaincontent,
          ),
        ),
        Expanded(
          flex: 2,
          child: FittedBox(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedItems.removeAt(index);
                      if (_isExpanded.length > index)
                        _isExpanded.removeAt(index);
                      calculateTotal();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.delete, size: 20, color: Colors.red),
                  ),
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ItemEditPopup(context, item);
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.edit, size: 20, color: Colors.black),
                  ),
                )
              ],
            )),
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
              Expanded(flex: 2, child: Text('Total Qty', style: maincontent)),
              Expanded(flex: 1, child: Text(':', style: maincontent)),
              Expanded(flex: 3, child: Text('${totalQty}', style: maincontent)),
            ]),
            Row(children: [
              Expanded(
                  flex: 2, child: Text('Total Amount', style: maincontent)),
              Expanded(flex: 1, child: Text(':', style: maincontent)),
              Expanded(
                  flex: 3,
                  child: Text('${formatItemAmount(totalAmount)}',
                      style: maincontent)),
            ]),
          ],
        ));
  }

  Widget ItemEditPopup(BuildContext context, item) {
    final TextStyle mainTitle = TextStyle(
      fontSize: 16,
      color: Color.fromRGBO(0, 0, 0, 1),
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
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
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter QTY';
                  }
                  return null;
                },
                onChanged: (value) {
                  item['std_Qty'] = double.tryParse(value) ?? item['std_Qty'];
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
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Rate';
                  }
                  return null;
                },
                onChanged: (value) {
                  item['std_Rate'] = double.tryParse(value) ?? item['std_Rate'];
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
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Discount.';
                  }
                  return null;
                },
                onChanged: (value) {
                  item['rateDiscount'] = double.tryParse(value) ?? 0.0;
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
    return amount;
  }
}
