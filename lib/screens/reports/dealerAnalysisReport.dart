import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/exportbutton.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/invoiceview.dart';
import 'package:mlco/common-widgets/norecordfound.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/global/appCommon.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/backbuttonappbar.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/dealer/createinvoice.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/agefilterPopup.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/ageing.dart';
import 'package:mlco/screens/reports/toDatefilterPopup.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/reportdownloadservice.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DealerAnalysisReportScreen extends StatefulWidget {
  @override
  _DealerAnalysisReportScreenState createState() =>
      _DealerAnalysisReportScreenState();
}

class _DealerAnalysisReportScreenState
    extends State<DealerAnalysisReportScreen> {
  final TextStyle inter16 = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(129, 129, 129, 1));

  final TextStyle inter13 = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Color.fromRGBO(0, 0, 0, 1));

  int _selectedIndex = 0;
  bool isLoading = false; // Set to false for static data

  String userData = '';
  late String currentSessionId;
  String BillNo = '';
  double totalGrandAmnt = 0;
  int totalRows = 0;
  double totalPending = 0;
  int totalAvgDays = 0;
  late String fromDate;
  late String toDate;
  int? ledgerid;
  late String todaysDate;
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
  DateTime lastDayOfPreviousMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 0);
  String salesPerson = '';
  String? selectedParent = 'Analysis';
  List<int> uniqueLedgerIds = [];
  int? invTypeId = 1;
  List<Map<String, dynamic>> parentOutstandings = [];
  List<Map<String, dynamic>> aginglist = [];
  List<Map<String, dynamic>> Invoices = [];
  List<Map<String, dynamic>>? tabs = [
    {'key': 'Analysis', 'value': ''}
  ];
  List<Map<String, dynamic>>? groups = [];

  final List<Map<String, dynamic>> parentReports = [
    {'id': '1', 'name': 'Test Project'},
    {'id': '2', 'name': 'Test Project Child'},
    {'id': '2', 'name': 'Test Project Child 2'}
  ];
  final OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: Color.fromRGBO(160, 160, 160, 1)));

  @override
  void initState() {
    super.initState();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(lastDayOfPreviousMonth);
    todaysDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    loadUserData();
  }

  void updateDates(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    getList();
  }

  void ledgerChange(String ledger) {
    //getList();
  }

  ledgerSelect(Map<String, dynamic> ledger) {
    print('ledger' + ledger.toString());
    ledgerid = ledger['id'];
    if (ledgerid != null) {
      getList();
    }
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
          // Call getList() after loading user data
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

  Future<void> getList() async {
    if (invTypeId == 1) {
      DateTime parsedFromDate =
          DateFormat('dd/MM/yyyy HH:mm:ss').parse(fromDate);
      DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);
      String formattedFromDate =
          DateFormat('MM/dd/yyyy 00:00:00').format(parsedFromDate);
      String formattedToDate =
          DateFormat('MM/dd/yyyy 23:59:59').format(parsedToDate);
      setState(() {
        isLoading = true;
      });

      try {
        var requestBody = {
          "fromDate": formattedFromDate,
          "toDate": formattedToDate,
          "ledgerId": ledgerid,
          "invType": invTypeId.toString(),
          "sessionId": currentSessionId
        };

        var response = await salesColumnarReportService(requestBody);
        var decodedData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          setState(() {
            List<Map<String, dynamic>> ungroups =
                List<Map<String, dynamic>>.from(decodedData);
            groups = [];
            tabs = [
              {'key': 'Analysis', 'value': ''}
            ];
            parentOutstandings = ungroups;

            isLoading = false;
          });
          getAgingList();
          print('groups: $groups');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No details found'),
            ),
          );
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No details found"),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } else {
      getInvoicesList();
    }
  }

  Future<void> getAgingList() async {
    DateTime parsedFromDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(fromDate);
    DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);
    String formattedFromDate =
        DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    String formattedToDate =
        DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    String formattedFromDatefrom =
        DateFormat('yyyy/MM/dd').format(parsedFromDate);
    String formattedToDateto = DateFormat('yyyy/MM/dd').format(parsedToDate);
    setState(() {
      isLoading = true;
    });

    try {
      var requestBody = {
        "fromDate": formattedFromDatefrom,
        "toDate": formattedToDateto,
        "ledgerId": ledgerid,
        "invType": invTypeId.toString(),
        "dateFrom": formattedFromDate,
        "dateTo": formattedToDate,
        "sessionId": currentSessionId
      };

      var response = await agingReportService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        aginglist = List<Map<String, dynamic>>.from(decodedData);
        mergeData();
        setState(() {
          isLoading = false;
        });
        print('agingdata: $aginglist');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No details found'),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getInvoicesList() async {
    DateTime parsedFromDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(fromDate);
    DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);
    String formattedFromDate =
        DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    String formattedToDate =
        DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    setState(() {
      isLoading = true;
    });
    parentOutstandings = [];
    try {
      var requestBody = {
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "ledgerId": ledgerid,
        "invType": invTypeId.toString(),
        "sessionId": currentSessionId
      };

      var response = await getInvoiceListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          List<Map<String, dynamic>> ungroups =
              List<Map<String, dynamic>>.from(decodedData['list']);

          ungroups.forEach((v) {
            var rec = {
              'Bill_No': v['bill_No'],
              'Date': v['date'],
              'Days': null,
              'GrandTotal': v['grandTotal'],
              'GstNo': null,
              'INVAmount': v['grandTotal'],
              'INVBill_No': v['bill_No'],
              'INVDate': v['date'],
              'InvCode': v['invCode'],
              'InvoiceNo': null,
              'Output CGST @9%': null,
              'Output SGST @9%': null,
              'PName': v['partyName'],
              'RecAmount': null,
              'RecBill_No': null,
              'RecDate': null,
              'RoundOff': null,
              'Sales @Essco Faucet': null,
              'Sales @Essco Sanitaryware': null,
              'Sales @Jaquar Cisterns': null,
              'Sales @Jaquar Faucets': null,
              'Sales @Jaquar Sanitaryware': null,
              'Sales @Jaquar Spares': null,
              'Sales @Jaquar Wellness': null,
              'Sales @Misc': null,
              'SalesValue': v['item_SubTotal'],
              'TypeName': getInvTypeText(invTypeId!).toString(),
            };

            parentOutstandings.add(rec);
          });
          isLoading = false;
          groups = [];
          tabs = [
            {'key': 'Analysis', 'value': ''}
          ];
          groups = groupBy(parentOutstandings, 'TypeName');
        });
        print('parentOutstandings: $parentOutstandings');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No details found'),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void mergeData() {
    // Create a mapping of invoices by Bill_No
    Map<String, Map<String, dynamic>> invoiceMap = {};

    for (var invoice in parentOutstandings) {
      invoiceMap[invoice['Bill_No']] = invoice;
    }

    // Merge receipts into invoices
    for (var receipt in aginglist) {
      var billNo = receipt['INVBill_No'];
      if (invoiceMap.containsKey(billNo)) {
        var invoice = invoiceMap[billNo];
        if (invoice != null) {
          invoice.addAll(receipt);
        }
      }
    }

    // Update the Invoices list
    parentOutstandings = invoiceMap.values.toList();
    groups = groupBy(parentOutstandings, 'TypeName');
    // Print the updated Invoices list
    print('Updated Invoices: $parentOutstandings');
  }

  void _onQuickLinkTapped(id) {
    print(id);
    setState(() {
      selectedParent = id;
    });
    if (id != 'Analysis') {
      setState(() {
        var selectedType = groups!.firstWhere((test) => test['key'] == id);
        Invoices = selectedType['value'];
        totalRows = selectedType['value']!.length;
        totalGrandAmnt =
            sumOfArrayProperty(selectedType['value'], 'GrandTotal');
        totalPending = sumOfArrayProperty(selectedType['value'], 'SalesValue');
        totalAvgDays = getAvgDays(selectedType['value']);
      });
    }
  }

  List<Map<String, String>> getLedgerSummary(List<Map<String, dynamic>> lst) {
    if (lst.isEmpty) return [];

    // Keys to skip
    List<String> skipKeys = [
      'Date',
      'InvoiceNo',
      'PName',
      'TypeName',
      'Bill_No',
      'GstNo',
      'GrandTotal',
      'SalesValue',
      'Days',
      'INVAmount',
      'INVBill_No',
      'INVDate',
      'InvCode',
      'RecAmount',
      'RecBill_No',
      'RecDate'
    ];

    // Getting distinct object keys
    List<Map<String, String>> distinctObjectKeys = [];
    List<String> keys = lst[0].keys.toList();

    // Find keys not in skipKeys and add to distinctObjectKeys
    for (var key in keys) {
      if (!skipKeys.contains(key)) {
        distinctObjectKeys.add({'ledger': key, 'amount': '0'});
      }
    }

    // Summing up the amounts for each ledger
    for (var item in distinctObjectKeys) {
      String ledgerKey = item['ledger']!;
      double total = lst.fold(0, (sum, element) {
        var value = element[ledgerKey] ?? 0.0;
        return sum + (value is double ? value : 0.0);
      });
      item['amount'] = formatAmount(total);
    }

    return distinctObjectKeys;
  }

  String formatAmount(double amount) {
    var formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount); // Ensure the input is of type double
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainDashboardScreen()),
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

  void billNoChange(String bill) {
    print('billNoChange' + bill);
    setState(() {
      BillNo = bill;
    });
  }

  String getInvTypeText(int invType) {
    var matchedItem = enInvTypeForDropdown.firstWhere(
      (item) => item['id'] == invType,
    );
    return matchedItem != null ? matchedItem['text'] : 'Unknown Type';
  }

  int getReceiptCount(List<Map<String, dynamic>> invoices) {
    var invoiceBillNos = invoices.map((invoice) => invoice['Bill_No']).toSet();
    var receiptInvBillNos =
        aginglist.map((receipt) => receipt['INVBill_No']).toSet();

    var uniqueMatchingBillNos = invoiceBillNos.intersection(receiptInvBillNos);

    return uniqueMatchingBillNos.length;
  }

  int getAvgDays(List<Map<String, dynamic>> data) {
    // Ensure the list is not empty to avoid division by zero
    if (data.isEmpty) return 0;

    // Map the 'Days' values, replacing null with 0
    var daysList = data.map((item) => item['Days'] ?? 0).toList();

    // Sum the 'Days' values
    var totalDays = daysList.reduce((sum, days) => sum + days);

    // Calculate the average and round to the nearest integer
    var avgDays = (totalDays / data.length).round();

    // Return the average, ensuring it is not NaN
    return avgDays.isNaN ? 0 : avgDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MLCOAppBackButtonBar(),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: SearchLedger2(
              onTextChanged: ledgerChange,
              onledgerSelects: ledgerSelect,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: DropdownButtonFormField<int>(
              value: invTypeId,
              decoration: InputDecoration(
                  labelText: 'Select Type',
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  focusedBorder: borderStyle),
              items: enInvTypeForDropdown
                  .map((sp) => DropdownMenuItem<int>(
                        child: Text(sp['text']),
                        value: sp['id'],
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  invTypeId = value;
                });
                getList();
                print('invTypeId$invTypeId');
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dealer Analysis',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    fixedSize: Size(95, 20),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      side: BorderSide(
                          width: 2,
                          color: Colors.green), // Border color and width
                    ),
                  ),
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true, // No backdrop
                      barrierLabel: 'Popup', // Adding barrierLabel
                      transitionDuration: Duration(milliseconds: 200),
                      pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: FilterPopup(
                                onSubmit: updateDates,
                              ),
                            ),
                          ),
                        );
                      },
                      transitionBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 1),
                            end: Offset(0, 0),
                          ).animate(animation),
                          child: child,
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter'),
                      Image.asset(
                        'assets/icons/filter.png',
                        width: 20,
                        height: 20,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 10),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tabs!.map((link) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                      onTap: () => {_onQuickLinkTapped(link['key'])},
                      child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: 164,
                          decoration: BoxDecoration(
                              gradient: link['key'] == selectedParent
                                  ? mlcoGradient
                                  : inactivelinksgradient,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                link['key'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  color: link['key'] == selectedParent
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              if (link['key'] != 'Analysis')
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        tabs!.remove(link);
                                        selectedParent = 'Analysis';
                                      });
                                    },
                                    icon: Icon(Icons.close))
                            ],
                          ))),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          if (groups == null || groups!.isEmpty)
            !isLoading ? noRecordsFound() : Container(),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: selectedParent == 'Analysis'
                      ? ListView.builder(
                          itemCount: groups!.length,
                          itemBuilder: (context, index) {
                            var invoice = groups![index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              color: Color.fromRGBO(255, 255, 255, 1),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            flex: 4,
                                            child: Text(
                                              invoice['key'] ?? '',
                                              style: GoogleFonts.inter(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              ':',
                                              style: GoogleFonts.inter(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              invoice['value']
                                                  .length
                                                  .toString(),
                                              style: GoogleFonts.inter(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )),
                                        Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                // Check if the key is already present in the tabs list
                                                bool keyExists = tabs!.any(
                                                    (tab) =>
                                                        tab['key'] ==
                                                        invoice['key']);

                                                // Add the invoice to tabs if the key does not already exist
                                                if (!keyExists) {
                                                  tabs!.add(invoice);
                                                }
                                                selectedParent = invoice['key'];
                                                Invoices = invoice['value'];
                                                totalRows =
                                                    invoice['value']!.length;
                                                totalGrandAmnt =
                                                    sumOfArrayProperty(
                                                        invoice['value'],
                                                        'GrandTotal');
                                                totalPending =
                                                    sumOfArrayProperty(
                                                        invoice['value'],
                                                        'SalesValue');
                                                totalAvgDays = getAvgDays(
                                                    invoice['value']);
                                              });
                                            },
                                            child: Icon(
                                              Icons.expand_more,
                                              size: 30,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child:
                                              Text('Receipt', style: inter16),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text('-', style: inter16),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: ShaderMask(
                                            shaderCallback: (bounds) =>
                                                mlcoGradient.createShader(
                                                    Offset.zero & bounds.size),
                                            child: Text(
                                              getReceiptCount(invoice['value'])
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child:
                                              Text('Avg Days', style: inter16),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text('-', style: inter16),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: ShaderMask(
                                            shaderCallback: (bounds) =>
                                                mlcoGradient.createShader(
                                                    Offset.zero & bounds.size),
                                            child: Text(
                                              '${getAvgDays(invoice['value']) ?? ''} Days',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Taxable Value',
                                              style: inter16),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text('-', style: inter16),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: ShaderMask(
                                            shaderCallback: (bounds) =>
                                                mlcoGradient.createShader(
                                                    Offset.zero & bounds.size),
                                            child: Text(
                                              '₹' +
                                                  formatAmount(
                                                          sumOfArrayProperty(
                                                              invoice['value'],
                                                              'SalesValue'))
                                                      .toString(),
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Grand Total',
                                              style: inter16),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text('-', style: inter16),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: ShaderMask(
                                            shaderCallback: (bounds) =>
                                                mlcoGradient.createShader(
                                                    Offset.zero & bounds.size),
                                            child: Text(
                                              '₹' +
                                                  formatAmount(
                                                          sumOfArrayProperty(
                                                              invoice['value'],
                                                              'GrandTotal'))
                                                      .toString(),
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Container(),
                ),
          if (selectedParent != 'Analysis')
            Expanded(
              flex: 100,
              child: ListView.builder(
                itemCount: Invoices!.length,
                itemBuilder: (context, index) {
                  var invoice = Invoices![index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    color: Color.fromRGBO(255, 255, 255, 1),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${formatDate(invoice['Date'])}',
                                  style: inter16),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text('${invoice['Bill_No'] ?? ''}',
                                      style: inter13),
                                ],
                              ),
                              if (invoice['InvCode'] != null)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              InvoiceViewScreen(
                                                id: invoice['InvCode']
                                                    .toString(),
                                                invTypeID: invTypeId,
                                              )),
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/icons/Menubab.png',
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text('Sales Value', style: inter16),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('-', style: inter16),
                              ),
                              Expanded(
                                flex: 6,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => mlcoGradient
                                      .createShader(Offset.zero & bounds.size),
                                  child: Text(
                                    '₹${formatAmount(invoice['SalesValue'])}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text('Grand Total', style: inter16),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('-', style: inter16),
                              ),
                              Expanded(
                                flex: 6,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => mlcoGradient
                                      .createShader(Offset.zero & bounds.size),
                                  child: Text(
                                    '₹${formatAmount(invoice['GrandTotal'] ?? '')}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text('Recepit Date', style: inter16),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('-', style: inter16),
                              ),
                              Expanded(
                                flex: 6,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => mlcoGradient
                                      .createShader(Offset.zero & bounds.size),
                                  child: invoice['RecDate'] != null
                                      ? Text(
                                          '${formatDateTime(invoice['RecDate']) ?? ''}',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text('Recepit Amount', style: inter16),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('-', style: inter16),
                              ),
                              Expanded(
                                flex: 6,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => mlcoGradient
                                      .createShader(Offset.zero & bounds.size),
                                  child: invoice['RecAmount'] != null
                                      ? Text(
                                          '₹${formatAmount(invoice['RecAmount'] ?? '') ?? ''}',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text('Days', style: inter16),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('-', style: inter16),
                              ),
                              Expanded(
                                flex: 6,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => mlcoGradient
                                      .createShader(Offset.zero & bounds.size),
                                  child: invoice['Days'] != null
                                      ? Text(
                                          '${invoice['Days'] ?? ''}',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: selectedParent != 'Analysis'
          ? Container(
              decoration: BoxDecoration(
                  gradient: mlcoGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return summaryPopup(context, Invoices, selectedParent);
                      },
                    );
                  },
                  child: Container(
                    // Adjust the height to make it bigger
                    width: 100.0, // Adjust the width to make it bigger
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('View Summary',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  )),
            )
          : null,
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          if (selectedParent != 'Analysis')
            outstadingBottomsheet(
                totalGrandAmnt, totalPending, totalRows, totalAvgDays),
          CustomBottomNavBar(
              currentIndex: _selectedIndex, onTap: _onItemTapped),
        ],
      ),
    );
  }

  Widget summaryPopup(BuildContext context, group, selectedParent) {
    group = getLedgerSummary(group);
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$selectedParent' + ' Summary',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 30),
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                      )),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                  itemCount: group?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (group == null || group.isEmpty) {
                      return Center(
                        child: Text('No Items found'),
                      );
                    }
                    var item = group[index];

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
                                  'Ledger',
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
                                  '${item['ledger'] ?? ''}',
                                  style: valuetxt,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Amount',
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
                                  '₹${formatItemAmount(item['amount'])}',
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
          ],
        ),
      ),
    );
  }
}

Widget outstadingBottomsheet(totalamount, pending, rows, avgdays) {
  final TextStyle inter14_w600 = GoogleFonts.inter(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  final TextStyle inter13_w600 = GoogleFonts.inter(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );
  final formattedTotal = CurrencyFormatter.format(totalamount);
  final formattedPending = CurrencyFormatter.format(pending);
  return Container(
    padding: EdgeInsets.all(10),
    height: 160,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(gradient: mlcoGradient),
    child: BottomSheet(
      backgroundColor: Colors.transparent,
      onClosing: () {},
      builder: (BuildContext context) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Rows :' + '${rows}',
                  style: inter13_w600,
                ),
                Text(
                  'Avg Days :' + ' ${avgdays}',
                  style: inter13_w600,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Value :' + ' ${formattedPending}',
                  style: inter14_w600,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grand Total :' + ' ${formattedTotal}',
                  style: inter14_w600,
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
