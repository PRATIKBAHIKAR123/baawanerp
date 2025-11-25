import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/invoicemenulist.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/global/styles.dart';
import 'package:http/http.dart' as http;
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/appbarwithback.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/services/apiServices.dart';
import 'package:mlco/services/companyFetch.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/sessionCheckService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceViewScreen extends StatefulWidget {
  final String id;
  final int? invTypeID;
  final InvoiceType? invoiceType;

  InvoiceViewScreen({required this.id, this.invTypeID, this.invoiceType});

  @override
  State<InvoiceViewScreen> createState() => _InvoiceViewScreenState();
}

class _InvoiceViewScreenState extends State<InvoiceViewScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;
  Map<String, dynamic>? company;

  @override
  void initState() {
    super.initState();
    isValidSession();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    loadUserData();
  }

  String userData = '';
  late String currentSessionId;
  String BillNo = '';
  Map<String, dynamic> setupInfoData = {};
  Map<String, dynamic> invoiceData = {
    'ledger': '',
    'billno': '',
    'salesperson': ''
  };
  List<dynamic> stockPlaces = [];
  double totalGrandAmnt = 0;
  double totalGST = 0;
  double totalAmnt = 0;
  double totalQty = 0;
  double totalRate = 0;
  double roundOff = 0;

  List<Map<String, dynamic>>? Invoices;
  late String fromDate;
  late String toDate;

  void updateDates(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    getInvoiceDetails();
  }

  getSetupInfoData() async {
    try {
      var requestBody = {
        "invtype": widget.invTypeID,
        "fromInvoice": true,
        "sessionId": currentSessionId
      };

      var response = await getSetupInfoService(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          var decodedData = jsonDecode(response.body);
          setupInfoData = decodedData;
          stockPlaces = setupInfoData['stockPlaces'];
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

  getInvoiceDetails() async {
    setState(() {
      isLoading = true;
    });
    var requestBody = {
      "id": widget.id,
      "invType": widget.invTypeID,
      "sessionId": currentSessionId
    };

    try {
      var response = await getInvoiceService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);
        String ledgerName = await getLedgerNameById(decodedData['ledger_ID']);
        String salespersonName = '';
        if (decodedData['salesByUserID'] != null) {
          salespersonName = await getSalespersonNameById(
              decodedData['salesByUserID'], currentSessionId);
        }

        if (decodedData.containsKey('invoiceItemDetail')) {
          setState(() async {
            Invoices = List<Map<String, dynamic>>.from(
                decodedData['invoiceItemDetail']);
            invoiceData['billno'] = decodedData['bill_No'];
            invoiceData['ledger'] = ledgerName;
            invoiceData['salesperson'] = salespersonName;

            totalGrandAmnt = 0; // Reset the total amount before summing up

            totalAmnt = 0;
            totalQty = 0;
            totalRate = 0;
            totalGST = 0;
            totalAmnt = decodedData['item_SubTotal'];
            roundOff = decodedData['roundOff'];
            totalGrandAmnt = decodedData['grandTotal'];
            for (var invoice in Invoices!) {
              totalQty += invoice['std_Qty'];
              totalRate += invoice['std_Rate'];
              totalGST += invoice['sgstAmt'] +
                  invoice['cgstAmt'] +
                  invoice['igstAmt'] +
                  invoice['rateAfterVat'];
              //totalGrandAmnt += invoice['grandTotal'];
            }
            isLoading = false;
          });

          print('totalGrandAmnt: $totalGrandAmnt');
        } else {
          print('List not found in response body');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print(response.body);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');
    company = await CompanyDataUtil.getCompanyFromLocalStorage();
    if (userDataString != null) {
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        String? currentSessionId = userData['user']['currentSessionId'];

        if (currentSessionId != null) {
          setState(() {
            this.currentSessionId = currentSessionId;
          });
          print('Loaded currentSessionId: $currentSessionId');
          getSetupInfoData();
          getInvoiceDetails(); // Call getList() after loading user data
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

  onCheckPendingDetails() async {
    setState(() {
      isLoading = true;
    });

    var fdata = {
      "invCode": widget.id,
      "invType": widget.invTypeID,
      "sessionId": currentSessionId
    };

    try {
      var response = await checkPendingDetailsService(fdata);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);
        var currentStockList = decodedData;
        for (var i = 0; i < Invoices!.length; i++) {
          var ele = Invoices![i];

          // Find current stock item based on item_ID
          var currentStockItem =
              currentStockList.where((x) => x['item_ID'] == ele['item_ID']);
          if (currentStockItem.isNotEmpty) {
            var details = currentStockItem.first['details'];

            // Check if 'details' is a string and decode it if necessary
            if (details is String) {
              ele['details'] = jsonDecode(details);
            } else {
              ele['details'] = details;
            }
          } else {
            ele['details'] = [];
          }
        }
        setState(() {
          isLoading = false;
        });
      } else {
        print(response.body);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  onCheckStock() async {
    setState(() {
      isLoading = true;
    });
    List<Map<String, dynamic>> items = [];

    for (var i = 0; i < Invoices!.length; i++) {
      var ele = Invoices![i];
      var sp = setupInfoData['stockPlaces']
          .firstWhere((x) => x['name'] == ele['sp_text'], orElse: () => null);

      items.add({
        'item': ele['item_ID'],
        'stockPlace': sp != null ? sp['spId'] : 0,
        'enteredQty': ele['std_Qty'],
      });
    }

    var fdata = {'items': items, 'sessionId': currentSessionId};

    try {
      var response = await checkStockService(fdata);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);
        var currentStockList = decodedData;
        for (var i = 0; i < Invoices!.length; i++) {
          var ele = Invoices![i];

          // Find current stock item based on item_ID
          var currentStockItem =
              currentStockList.where((x) => x['item_ID'] == ele['item_ID']);

          // Update availableQty
          if (currentStockItem.isNotEmpty) {
            ele['availableQty'] = currentStockItem.first['currentStock'];
          } else {
            ele['availableQty'] = 0;
          }
// Apply custom logic to determine the color (as a string, to be used in the UI later)
          Color color;
          if (ele['availableQty'] != null) {
            if (ele['std_Qty'] > ele['availableQty'] &&
                ele['availableQty'] < 1) {
              color = Colors.red;
            } else if (ele['std_Qty'] > ele['availableQty'] &&
                ele['availableQty'] > 0) {
              color = Colors.red;
            } else if (ele['availableQty'] < 1) {
              color = Colors.red;
            } else {
              color = Colors.green;
            }
          } else {
            color = Colors.green;
          }

          // Add a new key for the "Stock" column with the assigned color
          ele['stockColumnColor'] = color;
          // Temporarily set std_Qty to 0
          var oldStdQty = ele['std_Qty'];
          ele['std_Qty'] = 0;

          // Perform any necessary updates in the UI or state management

          // Revert std_Qty to its original value
          ele['std_Qty'] = oldStdQty;

          // Perform any necessary updates in the UI or state management
        }
        setState(() {
          isLoading = false;
        });
      } else {
        print(response.body);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  onCheckPending() async {
    setState(() {
      isLoading = true;
    });

    var fdata = {
      "invCode": widget.id,
      "invType": widget.invTypeID,
      "sessionId": currentSessionId
    };

    try {
      var response = await checkPendingService(fdata);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);
        var currentStockList = decodedData;
        for (var i = 0; i < Invoices!.length; i++) {
          var ele = Invoices![i];

          // Find current stock item based on item_ID
          var currentStockItem =
              currentStockList.where((x) => x['item_ID'] == ele['item_ID']);

          // Update availableQty
          if (currentStockItem.isNotEmpty) {
            ele['pendingQty'] = currentStockItem.first['pendingQty'];
          } else {
            ele['pendingQty'] = 0;
          }
// Apply custom logic to determine the color (as a string, to be used in the UI later)
          Color color;
          if (ele['pendingQty'] != null) {
            if (ele['pendingQty'] != 0) {
              color = Colors.red;
            } else {
              color = Colors.green;
            }
          } else {
            color = Colors.green;
          }

          // Add a new key for the "Stock" column with the assigned color
          ele['pendingColumnColor'] = color;
        }
        setState(() {
          isLoading = false;
        });
      } else {
        print(response.body);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mlcoAppBarWithBack(
        title: 'Invoice Details',
        invoiceDetails: invoiceData,
      ),
      //drawer: Drawer(backgroundColor: Colors.green,),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: Invoices?.length ?? 0,
                    itemBuilder: (context, index) {
                      if (Invoices == null || Invoices!.isEmpty) {
                        return Center(
                          child: Text('No invoices found'),
                        );
                      }
                      var invoice = Invoices![index];

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${invoice['particular']}',
                                    style: inter600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(children: [
                                  Text(
                                    'HSN : ',
                                    style: inter_13_500,
                                  ),
                                  Text(
                                    invoice['hsn'],
                                    style: inter_13_500,
                                  ),
                                ]),
                                Row(children: [
                                  Text(
                                    'Stock Place : ',
                                    style: inter_13_500,
                                  ),
                                  Text(
                                    invoice['sp_text'],
                                    style: inter_13_500,
                                  ),
                                ]),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(children: [
                                  Text(
                                    'QTY : ',
                                    style: inter_13_500,
                                  ),
                                  Text(
                                    invoice['std_Qty'].toString(),
                                    style: inter_13_500,
                                  ),
                                ]),
                                Row(children: [
                                  Text(
                                    'Unit : ',
                                    style: inter_13_500,
                                  ),
                                  Text(
                                    invoice['unittext'],
                                    style: inter_13_500,
                                  ),
                                ]),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (invoice['pendingQty'] != null)
                                  Row(children: [
                                    Text(
                                      'Pending : ',
                                      style: inter_13_500,
                                    ),
                                    Text(
                                      invoice['pendingQty'].toString(),
                                      style: TextStyle(
                                          color: invoice['pendingColumnColor']),
                                    ),
                                  ]),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            if (invoice['availableQty'] != null)
                              Row(children: [
                                Text(
                                  'Stock : ',
                                  style: inter_13_500,
                                ),
                                Text(
                                  invoice['availableQty'].toString(),
                                  style: TextStyle(
                                      color: invoice['stockColumnColor']),
                                ),
                              ]),
                            if (invoice['details'] != null &&
                                invoice['details'].isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pending Details:',
                                    style: inter_13_500,
                                  ),
                                  SizedBox(
                                    height: 100, // Adjust height as needed
                                    child: ListView.builder(
                                      itemCount: invoice['details'].length,
                                      itemBuilder: (context, index) {
                                        var detail = invoice['details'][index];
                                        return ListTile(
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(formatDate(detail['Date']) ??
                                                  ''),
                                              Text(detail['Bill_No'] ?? ''),
                                              Text(detail['TypeName'] ?? ''),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(children: [
                                  Text(
                                    'Rate : ',
                                    style: inter_13_500,
                                  ),
                                  Text(
                                    CurrencyFormatter.format(
                                        invoice['std_Rate'] ?? ''),
                                    style: inter_13_500,
                                  ),
                                ]),
                                Row(children: [
                                  Text(
                                    'Category : ',
                                    style: inter_13_500,
                                  ),
                                  Text(
                                    invoice['priceCategoryText'] ?? 'None',
                                    style: inter_13_500,
                                  ),
                                ]),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(children: [
                                  Text(
                                    'Disc : ',
                                    style: inter_13_500,
                                  ),
                                  Text(
                                    CurrencyFormatter.format(
                                        invoice['discount1'] ?? ''),
                                    style: inter_13_500,
                                  ),
                                ]),
                                Row(children: [
                                  Text(
                                    '${company!.taxLabel} : ',
                                    style: inter_13_500,
                                  ),
                                  Text(
                                    invoice['vatPer'].toString(),
                                    style: inter_13_500,
                                  ),
                                ]),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Text(
                                    'Amount : ',
                                    style: inter_13_500,
                                  ),
                                  Text(
                                    CurrencyFormatter.format(
                                        invoice['amount'] ?? ''),
                                    style: inter600,
                                  ),
                                ]),
                              ],
                            ),
                            Divider()
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          invViewBottomsheet(
            totalQty,
            totalRate,
            totalAmnt,
          ),
        ],
      ),
    );
  }

  Widget invViewBottomsheet(totalqty, totalRate, totalamount) {
    final TextStyle inter14_w600 = GoogleFonts.inter(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );

    final TextStyle inter13_w600 = GoogleFonts.inter(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );
    final TextStyle totalStyle = GoogleFonts.inter(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
    final formattedtotalRate = CurrencyFormatter.format(totalRate);
    final formattedroundOff = CurrencyFormatter.format(roundOff);
    final formattedTotalGST = CurrencyFormatter.format(totalGST);
    final formattedTotal = CurrencyFormatter.format(totalamount);
    final formattedGrandTotal = CurrencyFormatter.format(totalGrandAmnt);
    return Container(
      padding: EdgeInsets.all(16),
      height: 156,
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
                  Row(
                    children: [
                      Text(
                        'Total Qty :',
                        style: inter13_w600,
                      ),
                      Text(
                        ' $totalqty',
                        style: inter13_w600,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total ${company!.taxLabelForExtraCharges} :' +
                            ' ${formattedTotalGST}',
                        style: inter14_w600,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Rate :',
                        style: inter14_w600,
                      ),
                      Text(
                        ' ${formattedtotalRate}',
                        style: inter13_w600,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount :' + ' ${formattedTotal}',
                        style: inter14_w600,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        onCheckStock();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4), // Adjust padding here
                        minimumSize: Size(50, 30), // Minimum width and height
                        textStyle: TextStyle(fontSize: 12),
                      ),
                      child: Text(
                        'Check Stock',
                        style: TextStyle(fontSize: 12),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        onCheckPending();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4), // Adjust padding here
                        minimumSize: Size(50, 30), // Minimum width and height
                        textStyle: TextStyle(fontSize: 12),
                      ),
                      child: Text(
                        'Check Pending',
                        style: TextStyle(fontSize: 12),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        onCheckPendingDetails();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4), // Adjust padding here
                        minimumSize: Size(50, 30), // Minimum width and height
                        textStyle: TextStyle(fontSize: 12),
                      ),
                      child: Text(
                        'Check Pending Details',
                        style: TextStyle(fontSize: 12),
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Sub Total :',
                        style: inter13_w600,
                      ),
                      Text(
                        ' $formattedTotal',
                        style: inter13_w600,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Round Off :' + ' ${formattedroundOff}',
                        style: inter14_w600,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Grand Total :' + ' ${formattedGrandTotal}',
                    style: totalStyle,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
