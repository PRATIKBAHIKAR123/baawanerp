import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/searchsalesperson.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/agefilterPopup.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/ageing.dart';
import 'package:mlco/screens/reports/ledgerRegisterFilter.dart';
import 'package:mlco/screens/reports/toDatefilterPopup.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesPersonReportScreen extends StatefulWidget {
  @override
  _SalesPersonReportScreenState createState() =>
      _SalesPersonReportScreenState();
}

class _SalesPersonReportScreenState extends State<SalesPersonReportScreen> {
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
  double totalRows = 0;
  double openingAmount = 0;
  double closingAmount = 0;
  double totalPending = 0;
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  late String fromDate;
  late String toDate;
  bool isOpeningBal = true;
  bool isRunningBal = true;
  bool isChildLedgers = true;
  bool isMonthWise = false;
  String isCrDr = '1';
  int? ledgerid;
  late String todaysDate;
  String salesPerson = '';
  int? selectedParent;
  List<int> uniqueLedgerIds = [];
  List<Map<String, dynamic>> parentOutstandings = [];
  List<Map<String, dynamic>> childOutstandings = [];
  Map<String, dynamic> ledgersInfo = {};
  List<Map<String, dynamic>> Invoices = [];
  List<Map<String, dynamic>> salesPersons = [];
  int? salesPersonId;
  final ScrollController _scrollController = ScrollController();
  bool _isButtonVisible = true;

  final List<Map<String, dynamic>> parentReports = [
    {'id': '1', 'name': 'Test Project'},
    {'id': '2', 'name': 'Test Project Child'},
    {'id': '2', 'name': 'Test Project Child 2'}
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    todaysDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    loadUserData();
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      bool isBottom = _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent;
      if (isBottom) {
        setState(() {
          _isButtonVisible = false; // Hide button when at the bottom
        });
      } else {
        setState(() {
          _isButtonVisible = true; // Show button when not at the bottom
        });
      }
    } else {
      setState(() {
        _isButtonVisible = true; // Show button while scrolling
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  updateDates(String from, String to) {
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
    salesPersonId = ledger['id'];
    if (salesPersonId != null) {
      salesPerson = ledger['name'];
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

  getList() async {
    DateTime parsedFromDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(fromDate);
    DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);
    String formattedFromDate =
        DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    String formattedToDate =
        DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    setState(() {
      isLoading = true;
    });

    try {
      var requestBody = {
        "userId": salesPersonId ?? null,
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "sessionId": currentSessionId
      };

      var response = await salesPersonReportListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);

          totalRows = 00;
          for (var invoice in Invoices) {
            totalRows++;
          }
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

  getSalesPersons() async {
    try {
      var requestBody = {"table": 18, "sessionId": currentSessionId};

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          salesPersons = decodedData;

          // isLoading = false;
        });
      } else {}
    } catch (e) {
      print('Error: $e');
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

  void billNoChange(String bill) {
    print('billNoChange' + bill);
    setState(() {
      BillNo = bill;
    });
  }

  @override
  Widget build(BuildContext context) {
    String _fromDate = '';
    if (fromDate != null) {
      DateTime date = DateFormat('dd/MM/yyyy HH:mm:ss').parse(fromDate);
      _fromDate = DateFormat('dd/MM/yyyy').format(date);
      print('_fromDate$_fromDate');
    }
    String _toDate = '';
    if (toDate != null) {
      DateTime date = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);
      _toDate = DateFormat('dd/MM/yyyy').format(date);
    }
    return Scaffold(
      appBar: MLCOAppBar(),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: SearchItemSalesPerson(
              onTextChanged: ledgerChange,
              onitemSelects: ledgerSelect,
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
                      'Sales Person',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Row(
                    //   children: [
                    //     Text(
                    //       'Ledger:',
                    //       style: GoogleFonts.plusJakartaSans(
                    //           fontWeight: FontWeight.w500, fontSize: 13),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
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
                                  initialFromDate: fromDate,
                                  initialToDate: toDate,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Filter',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Image.asset(
                          'assets/icons/filter.png',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
          SizedBox(
            height: 2,
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: Invoices.length,
                    itemBuilder: (context, index) {
                      var invoice = Invoices[index];
                      String formattedDate = '';
                      if (invoice['Date'] != null) {
                        formattedDate = formatDateTime(invoice['Date']);
                      }

                      var StdRate = '00';
                      if (invoice['StdRate'] != null) {
                        StdRate = CurrencyFormatter.format(invoice['StdRate']);
                      }

                      var Amount = '00';
                      if (invoice['Amount'] != null) {
                        Amount = CurrencyFormatter.format(invoice['Amount']);
                      }
                      String billNo = '';
                      if (invoice['BillNo'] != null) {
                        billNo = invoice['BillNo'];
                      }
                      var Qty = 0;
                      if (invoice['Qty'] != null) {
                        Qty = invoice['Qty'].toInt();
                      }

                      var item = '';
                      if (invoice['ItemName'] != null) {
                        item = invoice['ItemName'];
                      }
                      var perticular = '';
                      if (invoice['Ledger'] != null) {
                        perticular = invoice['Ledger'];
                      }
                      String category = '';
                      if (invoice['Category'] != null) {
                        category = invoice['Category'];
                      }
                      String subcategory = '';
                      if (invoice['SubCategory'] != null) {
                        subcategory = invoice['SubCategory'];
                      }
                      String type = '';
                      if (invoice['ItemType'] != null) {
                        type = invoice['ItemType'];
                      }
                      String brand = '';
                      if (invoice['Brand'] != null) {
                        brand = invoice['Brand'];
                      }
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        color: Color.fromRGBO(255, 255, 255, 1),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      // Text(
                                      //   'Bill No - ',
                                      //   style: inter16,
                                      // ),
                                      Text('${invoice['ItemCode']}',
                                          style: inter13),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      // Text(
                                      //   'Date - ',
                                      //   style: inter16,
                                      // ),
                                      Text('$formattedDate', style: inter16),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        mlcoGradient.createShader(
                                            Offset.zero & bounds.size),
                                    child: Text(
                                      item,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return InvoiceDialog(
                                            sessionId: currentSessionId,
                                            id: invoice['invVchId'].toString(),
                                            invType: 1,
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
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('Bill No - ', style: inter16),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          billNo,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Qty - ', style: inter16),
                                      Text('$Qty', style: inter13),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('Category - ', style: inter16),
                                      Text('$category', style: inter13),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Sub Category - ', style: inter16),
                                      Text('$subcategory', style: inter13),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('Type - ', style: inter16),
                                      Text('$type', style: inter13),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Brand - ', style: inter16),
                                      Text('$brand', style: inter13),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('Ledger - ', style: inter16),
                                      Text('$perticular', style: inter13),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('Std Rate - ', style: inter16),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          StdRate,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Amount - ', style: inter16),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          Amount,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
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
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          outstadingBottomsheet(openingAmount, closingAmount, totalRows),
          CustomBottomNavBar(
              currentIndex: _selectedIndex, onTap: _onItemTapped),
        ],
      ),
    );
  }
}

Widget outstadingBottomsheet(totalamount, pending, rows) {
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
  int formattedRows = rows.toInt();
  return Container(
    padding: EdgeInsets.all(14),
    height: 135,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(gradient: mlcoGradient),
    child: BottomSheet(
      backgroundColor: Colors.transparent,
      onClosing: () {},
      builder: (BuildContext context) {
        return Column(
          children: [
            Row(
              children: [
                Text(
                  'Total Rows :',
                  style: inter13_w600,
                ),
                Text(
                  ' $formattedRows',
                  style: inter13_w600,
                )
              ],
            ),
            // SizedBox(
            //   height: 1,
            // ),
          ],
        );
      },
    ),
  );
}
