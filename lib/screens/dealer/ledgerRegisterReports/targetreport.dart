import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/dealer/dashboard/dealerdashboard.dart';
import 'package:mlco/screens/dealer/dealerbottomNaviagtion.dart';
import 'package:mlco/screens/dealer/dealerdrawer.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/agefilterPopup.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/ageing.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TargetReportScreen extends StatefulWidget {
  @override
  _TargetReportScreenState createState() => _TargetReportScreenState();
}

class _TargetReportScreenState extends State<TargetReportScreen> {
  final TextStyle inter16 = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(129, 129, 129, 1));

  final TextStyle inter13 = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Color.fromRGBO(0, 0, 0, 1));

  final OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.grey.shade300));

  int _selectedIndex = 0;
  bool isLoading = false; // Set to false for static data

  String userData = '';
  late String currentSessionId;
  String BillNo = '';
  double totalGrandAmnt = 0;
  double totalRows = 0;
  double totalPending = 0;
  late String fromDate;
  late String toDate;
  int? ledgerid;
  late String todaysDate;
  String salesPerson = '';

  List<Map<String, dynamic>> Invoices = [];
  Map<String, dynamic> selectedRange = {};

  final List<Map<String, dynamic>> quickLinks = [
    {'id': '1', 'name': 'Outstanding'},
    {'id': '2', 'name': 'Ageing Report'}
  ];
  List<dynamic> targetRangeList = [];

  @override
  void initState() {
    super.initState();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
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
          getTargetRange();
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

  getList() async {
    DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);

    String formattedToDate =
        DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    setState(() {
      isLoading = true;
    });

    try {
      var requestBody = {
        "ledgers": [ledgerid],
        "detailed": false,
        "includeChild": true,
        "toDate": formattedToDate,
        "isOverDueOnBillDate": false,
        "sessionId": currentSessionId
      };

      var response = await ledgerOutstandingReportListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);
          totalRows = 00;
          double refAmount = 00;
          double refPending = 00;
          totalGrandAmnt = 00;
          totalPending = 00;
          for (var invoice in Invoices) {
            totalRows++;

            totalGrandAmnt = totalGrandAmnt +
                (invoice['opening'] *
                    ((invoice['openingDrCr'] == invoice['ledgerDrCr'])
                        ? 1
                        : -1));
            // totalGrandAmnt += invoice['opening'];
            refPending = invoice['pending'] *
                (invoice['pendingDrCr'] == invoice['ledgerDrCr'] ? 1 : -1);
            totalPending = totalPending + refPending;
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

  getTargetRange() async {
    try {
      var requestBody = {"id": ledgerid, "sessionId": currentSessionId};

      var response = await salesTargetRangeListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          targetRangeList = decodedData;

          isLoading = false;
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onQuickLinkTapped(String id) {
    print(id);
    switch (id) {
      case '1':
        {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TargetReportScreen()),
          );
        }
        break;
      case '2':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OutstandingAgeingReportListScreen()),
          );
        }
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

  void billNoChange(String bill) {
    print('billNoChange' + bill);
    setState(() {
      BillNo = bill;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MLCOAppBar(),
      drawer: DealerDrawer(),
      body: Column(
        children: [
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
                      'Target Report',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                  labelText: 'Date Range',
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  focusedBorder: borderStyle),
              items: targetRangeList
                  .map((sp) => DropdownMenuItem<Map<String, dynamic>>(
                        child: Text(sp['Range']),
                        value: sp,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  print('value$value');
                  //stockPlace = nameToIdMap[value!]!;
                });
              },
            ),
          ),
          SizedBox(
            height: 10,
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
                      DateTime date = DateTime.parse(invoice['date']);
                      String formattedDate = formatDate(invoice['date']);
                      final amount =
                          CurrencyFormatter.format(invoice['opening']);
                      final pending =
                          CurrencyFormatter.format(invoice['pending']);

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        color: Color.fromRGBO(255, 255, 255, 1),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     ShaderMask(
                              //       shaderCallback: (bounds) =>
                              //           mlcoGradient.createShader(
                              //               Offset.zero & bounds.size),
                              //       child: Text(
                              //         invoice['party'],
                              //         style: GoogleFonts.inter(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w600,
                              //           color: Colors.white,
                              //         ),
                              //       ),
                              //     ),
                              //     GestureDetector(
                              //       onTap: () {
                              //         showDialog(
                              //           context: context,
                              //           builder: (BuildContext context) {
                              //             return InvoiceDialog(
                              //               sessionId: currentSessionId,
                              //               id: invoice['invCode'].toString(),
                              //               invType: 3,
                              //             );
                              //           },
                              //         );
                              //       },
                              //       child: Image.asset(
                              //         'assets/icons/Menubab.png',
                              //         height: 24,
                              //         width: 24,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Bill No - ',
                                        style: inter16,
                                      ),
                                      Text('${invoice['billNo']}',
                                          style: inter13),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Voucher - ',
                                        style: inter16,
                                      ),
                                      Text('${invoice['voucher']}',
                                          style: inter13),
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
                                      Text(
                                        'Date - ',
                                        style: inter16,
                                      ),
                                      Text('$formattedDate', style: inter13),
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
                                      Text(
                                        'Amount - ',
                                        style: inter16,
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          '$amount',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Over Due - ',
                                        style: inter16,
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          '${invoice['overDue']} Days',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    'Pending - ',
                                    style: inter16,
                                  ),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        mlcoGradient.createShader(
                                            Offset.zero & bounds.size),
                                    child: Text(
                                      '${pending}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
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
          outstadingBottomsheet(totalGrandAmnt, totalPending, totalRows),
          DealerBottomNavBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
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
  return Container(
    padding: EdgeInsets.all(16),
    height: 130,
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
                  ' $rows',
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
                  'Total :' + ' ${formattedTotal}',
                  style: inter14_w600,
                ),
                Text(
                  'Pending :' + ' ${formattedPending}',
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
