import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/exportbutton.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/norecordfound.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/searchgroup.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/backbuttonappbar.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/reports/groupsummaryfilter.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/agefilterPopup.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/ageing.dart';
import 'package:mlco/screens/reports/ledgerRegisterFilter.dart';
import 'package:mlco/screens/reports/toDatefilterPopup.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/reportdownloadservice.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupSummaryReportScreen extends StatefulWidget {
  @override
  _GroupSummaryReportScreenState createState() =>
      _GroupSummaryReportScreenState();
}

class _GroupSummaryReportScreenState extends State<GroupSummaryReportScreen> {
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
  bool isChildLedgers = false;
  bool isMonthWise = false;
  String isCrDr = '1';
  int? groupid;
  late String todaysDate;
  String salesPerson = '';
  int? selectedParent;
  List<int> uniquegroupids = [];
  List<Map<String, dynamic>> parentOutstandings = [];
  List<Map<String, dynamic>> childOutstandings = [];
  Map<String, dynamic> ledgersInfo = {};
  Map<String, dynamic> ledgersBalInfo = {};
  List<Map<String, dynamic>> Invoices = [];
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

  updateDates(String from, String to, bool ischild) {
    setState(() {
      fromDate = from;
      toDate = to;
      isChildLedgers = ischild;
    });
    getList();
  }

  void groupChange(String ledger) {
    //getList();
  }

  groupSelect(Map<String, dynamic> group) {
    print('ledger' + group.toString());
    groupid = group['id'];
    if (groupid != null) {
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
        "groupId": groupid,
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "includeChildGroups": isChildLedgers,
        "sessionId": currentSessionId
      };
      var response = await groupsummaryReportListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);
          List<Map<String, dynamic>> tempInvoices = Invoices;
          totalRows = 00;
          double refAmount = 00;
          double refPending = 00;
          totalGrandAmnt = 00;
          totalPending = 00;
          openingAmount = 00;
          closingAmount = 00;
          for (var invoice in tempInvoices) {
            totalRows++;

            // if (invoice['type'] == "Closing Amount") {
            //   closingAmount = invoice['debit'];
            // }
          }
          closingAmount = getTotal(tempInvoices);
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

  double getTotal(List<Map<String, dynamic>> lst) {
    double total = 0.0;

    for (var params in lst) {
      double openingBal = params['OPENINGBAL'];
      double debit = params['DEBIT'];
      double credit = params['CREDIT'];
      bool isCr = params['IsCr'];

      double val =
          openingBal + debit * (!isCr ? 1 : -1) + credit * (isCr ? 1 : -1);

      total += val;
    }

    return total;
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

  String formatClosingNumberVal({
    required double openingBal,
    required double debit,
    required double credit,
    required bool isCr,
  }) {
    // Calculating the value based on given parameters
    double val =
        openingBal + debit * (!isCr ? 1 : -1) + credit * (isCr ? 1 : -1);

    // Formatting the value and adding ' Cr' or ' Dr' suffix
    Object formattedValue = CurrencyFormatter.format(val.abs());
    String suffix = val < 0 ? 'Cr' : 'Dr';

    return '$formattedValue $suffix';
  }

  void billNoChange(String bill) {
    print('billNoChange' + bill);
    setState(() {
      BillNo = bill;
    });
  }

  void export() async {
    print('export');
    DateTime parsedFromDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(fromDate);
    DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);
    String formattedFromDate =
        DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    String formattedToDate =
        DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);

    try {
      var requestBody = {
        "groupId": groupid,
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "includeChildGroups": isChildLedgers,
        "sessionId": currentSessionId
      };
      var response = await groupsummaryReportExportService(requestBody);

      if (response.statusCode == 200) {
        await downloadreport(
            context, response.bodyBytes, 'group-summaryReport');
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
            child: SearchGroup(
              onTextChanged: groupChange,
              onledgerSelects: groupSelect,
            ),
          ),
          // Padding(
          //     padding: EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: [
          //         GestureDetector(
          //           onTap: () {
          //             setState(() {
          //               isChildLedgers = !isChildLedgers;
          //             });
          //             getList();
          //           },
          //           child: Row(
          //             children: [
          //               Checkbox(
          //                 materialTapTargetSize:
          //                     MaterialTapTargetSize.shrinkWrap,
          //                 value: isChildLedgers,
          //                 onChanged: (bool? value) {
          //                   setState(() {
          //                     isChildLedgers = value ?? false;
          //                   });
          //                   getList();
          //                 },
          //               ),
          //               Text(
          //                 'Include Child',
          //                 style: GoogleFonts.plusJakartaSans(
          //                   fontWeight: FontWeight.w600,
          //                   fontSize: 13,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     )),
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
                      'Group Summary',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
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
                                  child: GroupSummaryFilterPopup(
                                    onSubmit: updateDates,
                                    initialFromDate: fromDate,
                                    initialToDate: toDate,
                                    initialChildLedgers: isChildLedgers,
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
                    SizedBox(width: 5),
                    exportButton(context, export)
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 2,
          ),
          if (Invoices == null || Invoices!.isEmpty)
            !isLoading ? noRecordsFound() : Container(),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: Invoices.length,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      var invoice = Invoices[index];

                      var debit = '00';
                      if (invoice['DEBIT'] != null) {
                        debit = CurrencyFormatter.format(invoice['DEBIT']);
                      }

                      var credit = '00';
                      if (invoice['CREDIT'] != null) {
                        credit = CurrencyFormatter.format(invoice['CREDIT']);
                      }

                      var running = '00';
                      if (invoice['OPENINGBAL'] != null) {
                        running = formatCurrency(invoice['OPENINGBAL']);
                      }
                      var perticular = '';
                      if (invoice['Name'] != null) {
                        perticular = invoice['Name'];
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
                                  Expanded(
                                    child: Text(
                                      '$perticular',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
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
                                  Expanded(
                                    flex: 4,
                                    child:
                                        Text('Opening Balance', style: inter16),
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
                                        '$running',
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
                                    flex: 4,
                                    child: Text('Debit', style: inter16),
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
                                        '$debit',
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text('Credit', style: inter16),
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
                                        '$credit',
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
                                    flex: 4,
                                    child:
                                        Text('Closing Balance', style: inter16),
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
                                        '${formatClosingNumberVal(
                                          credit: invoice['CREDIT'],
                                          openingBal: invoice['OPENINGBAL'],
                                          debit: invoice['DEBIT'],
                                          isCr: invoice['IsCr'],
                                        )}',
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

String formatCurrency(dynamic value) {
  if (value == null) {
    return '00';
  }

  double amount = value.toDouble();
  String formattedValue = CurrencyFormatter.format(amount.abs());

  if (amount < 0) {
    formattedValue += ' Cr';
  } else {
    formattedValue += ' Dr';
  }

  return formattedValue;
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
  final formattedPending = formatCurrency(pending);
  int formattedRows = rows.toInt();
  return Container(
    padding: EdgeInsets.all(14),
    height: 165,
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Opening Amount :' + ' ${formattedTotal}',
            //       style: inter14_w600,
            //     ),
            //   ],
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Closing Amount :' + ' ${formattedPending}',
                  style: inter14_w600,
                )
              ],
            ),
          ],
        );
      },
    ),
  );
}
