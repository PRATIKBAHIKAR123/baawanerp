import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/searchbill.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/screens/dealer/createinvoice.dart';
import 'package:mlco/screens/dealer/dealerbottomNaviagtion.dart';
import 'package:mlco/screens/dealer/dealerdrawer.dart';
import 'package:mlco/screens/dealer/invoice-dialog.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/sessionCheckService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DealerDashboardScreen extends StatefulWidget {
  @override
  State<DealerDashboardScreen> createState() => _DealerDashboardScreenState();
}

class _DealerDashboardScreenState extends State<DealerDashboardScreen> {
  final List<Map<String, dynamic>> quickLinks = [
    {'id': '23', 'name': 'Sales Enquiry'},
    {'id': '5', 'name': ' Sales Order'},
    {'id': '1', 'name': 'Sales Invoice'},
    {'id': '3', 'name': 'Sales Return '},
  ];
  String _selectedLink = '23';
  int _selectedIndex = 0;
  String userData = '';
  late String currentSessionId;
  int? itemid;
  int? ledgerid;
  String BillNo = '';
  double totalGrandAmnt = 0;
  bool isLoading = true;
  String pageTitle = 'Sales Enquiry';

  List<Map<String, dynamic>>? Invoices;
  late String fromDate;
  late String toDate;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    isValidSession();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    loadUserData();
  }

  void _onQuickLinkTapped(String id) {
    print(id);
    setState(() {
      _selectedLink = id;
    });
    getList();
    switch (id) {
      case '1':
        {
          pageTitle = 'Sales Invoice';
        }
        break;
      case '5':
        {
          pageTitle = 'Sales Order';
        }
      case '3':
        {
          pageTitle = 'Sales Return';
        }
      case '23':
        {
          pageTitle = 'Sales Enquiry';
        }
    }
  }

  void updateDates(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    getList();
  }

  getList() async {
    String? formattedFromDate;
    String? formattedToDate;
    if (fromDate != '') {
      DateTime parsedFromDate =
          DateFormat('dd/MM/yyyy HH:mm:ss').parse(fromDate);
      formattedFromDate =
          DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    }
    if (toDate != '') {
      DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);
      formattedToDate = DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    }

    setState(() {
      isLoading = true;
    });
    try {
      var requestBody = {
        "invType": int.parse(_selectedLink),
        "spIds": [0, 1, 2, 3],
        "isSync": false,
        "bill_No": null,
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "text": BillNo == '' ? null : BillNo,
        "ledger_ID": ledgerid,
        "isChildLedgers": true,
        "sessionId": currentSessionId
      };

      var response = await getInvoiceListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData['list']);

          isLoading = false;
        });
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
            ledgerid = userData['user']['ledger_ID'];
          });
          print('Loaded currentSessionId: $currentSessionId');
          getList(); // Call getList() after loading user data
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

  ledgerSelect(Map<String, dynamic> ledger) {
    print('ledger' + ledger.toString());
    itemid = ledger['id'];
    if (itemid != null) {
      BillNo = '';
      getList();
    }
  }

  void billNoChange(String bill) {
    print('billNoChange' + bill);
    setState(() {
      BillNo = bill;
      fromDate = '';
      toDate = '';
    });
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MLCOAppBar(),
      drawer: DealerDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Container(
              child: SearchBill(
                onTextChanged: billNoChange,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Quick Links',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: quickLinks.map((link) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                        onTap: () => {_onQuickLinkTapped(link['id'])},
                        child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 133,
                            decoration: BoxDecoration(
                                gradient: link['id'] == _selectedLink
                                    ? mlcoGradient2
                                    : inactivelinksgradient,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24))),
                            child: Text(
                              link['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                color: link['id'] == _selectedLink
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 14,
                              ),
                            ))),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pageTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        barrierDismissible: true,
                        barrierColor: Colors.transparent, // No backdrop
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
                  ),
                ],
              ),
            ),
            isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                          bottom: _selectedLink == '23' ? 100 : 10),
                      itemCount: Invoices?.length ?? 0,
                      itemBuilder: (context, index) {
                        if (Invoices == null || Invoices!.isEmpty) {
                          return Center(
                            child: Text('No invoices found'),
                          );
                        }
                        var invoice = Invoices![index];
                        DateTime date = DateTime.parse(invoice['date']);
                        String formattedDate = formatDateTime(invoice['date']);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${formattedDate} ',
                                style: inter400,
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${invoice['bill_No']}',
                                    style: inter_13_500,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return InvoiceDialog(
                                            sessionId: currentSessionId,
                                            id: invoice['invCode'].toString(),
                                            invType: int.parse(_selectedLink),
                                            invoice: invoice,
                                          );
                                        },
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
                              SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'RefNo: ${invoice['refNo'] ?? ''}',
                                      style: inter600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Taxable Value: ',
                                      style: inter600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                              locale: 'en_IN', symbol: '₹')
                                          .format(
                                              invoice['item_SubTotal'] ?? 0.00),
                                      style: mlco_gradient_text2,
                                    ),
                                  ]),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Grand Total: ',
                                      style: inter600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                              locale: 'en_IN', symbol: '₹')
                                          .format(
                                              invoice['grandTotal'] ?? 0.00),
                                      style: mlco_gradient_text2,
                                    ),
                                  ]),
                              Divider()
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: _selectedLink == '23'
          ? Container(
              child: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateInvoiceScreen()),
                );
              },
              child: Text(
                'Add Enquiry',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ))
          : null,
      bottomNavigationBar: DealerBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
