import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/exportbutton.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/norecordfound.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/backbuttonappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/services/reportdownloadservice.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalSheetReportScreen extends StatefulWidget {
  @override
  _BalSheetReportScreenState createState() => _BalSheetReportScreenState();
}

class _BalSheetReportScreenState extends State<BalSheetReportScreen> {
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
  double totalPending = 0;
  late String fromDate;
  late String toDate;
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  int? ledgerid;
  late String todaysDate;
  String salesPerson = '';
  String selectedParent = '1';
  List<int> uniqueLedgerIds = [];
  List<Map<String, dynamic>> tabs = [
    {'id': '1', 'name': 'Liabilities'},
    {'id': '2', 'name': 'Assets'},
  ];
  List<dynamic> liabilities = [];
  List<dynamic> assets = [];
  Map<String, dynamic> Invoices = {};
  Map<String, dynamic> expense = {};
  Map<String, dynamic> income = {};

  final List<Map<String, dynamic>> parentReports = [
    {'id': '1', 'name': 'Test Project'},
    {'id': '2', 'name': 'Test Project Child'},
    {'id': '2', 'name': 'Test Project Child 2'}
  ];

  @override
  void initState() {
    super.initState();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
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
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "withStock": false,
        "sessionId": currentSessionId
      };

      var response = await balSheetReportService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = Map<String, dynamic>.from(decodedData);

          liabilities = Invoices['liabilities'];
          List<Map<String, dynamic>> liabilities_ =
              List<Map<String, dynamic>>.from(liabilities);
          liabilities.add({
            'NAME': 'TOTAL',
            'Amount': sumOfArrayProperty(liabilities_, 'Amount'),
          });
          assets = Invoices['assets'];
          List<Map<String, dynamic>> assets_ =
              List<Map<String, dynamic>>.from(assets);
          assets.add({
            'NAME': 'TOTAL',
            'Amount': sumOfArrayProperty(assets_, 'Amount'),
          });
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

  void _onQuickLinkTapped(id) {
    print(id);

    setState(() {
      selectedParent = id;
    });
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
        "ledgers": [ledgerid],
        "includeChild": true,
        "toDate": formattedToDate,
        "sessionId": currentSessionId
      };

      var response = await ledgerOutstandingReportExportService(requestBody);

      if (response.statusCode == 200) {
        await downloadreport(
            context, response.bodyBytes, 'ledger-child-outstandingReport');
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance Sheet',
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
                                initialFromDate: fromDate,
                                initialToDate: toDate,
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
                exportButton(context, export)
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
              children: tabs.map((link) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                      onTap: () => {_onQuickLinkTapped(link['id'])},
                      child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: 164,
                          decoration: BoxDecoration(
                              gradient: link['id'] == selectedParent
                                  ? mlcoGradient
                                  : inactivelinksgradient,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24))),
                          child: Text(
                            link['name'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: link['id'] == selectedParent
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ))),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          if (selectedParent == '1') ...[
            if (Invoices == null || Invoices!.isEmpty)
              !isLoading ? noRecordsFound() : Container(),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      color: Color.fromRGBO(255, 255, 255, 1),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Adjust the height of the list dynamically
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.all(0),
                                itemCount: liabilities.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Map<String, dynamic> option =
                                      liabilities.elementAt(index);
                                  return ListTile(
                                    minLeadingWidth: 10,
                                    trailing: Text(
                                      '${CurrencyFormatter.format(option['Amount'])}',
                                      style: inter13,
                                    ),
                                    title: Text(option['NAME'],
                                        style: TextStyle(
                                            fontWeight:
                                                option['NAME'] == 'TOTAL'
                                                    ? FontWeight.w600
                                                    : FontWeight.w400)),
                                    onTap: () {
                                      print('Selected: ${option['name']}');
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
          ],
          if (selectedParent == '2') ...[
            if (Invoices == null || Invoices!.isEmpty)
              !isLoading ? noRecordsFound() : Container(),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(children: [
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      color: Color.fromRGBO(255, 255, 255, 1),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height:
                                    MediaQuery.of(context).size.height - 520,
                                child: ListView.builder(
                                  padding: EdgeInsets.all(10.0),
                                  itemCount: assets.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final Map<String, dynamic> option =
                                        assets.elementAt(index);
                                    return ListTile(
                                      minVerticalPadding: 5,
                                      minTileHeight: 10,
                                      trailing: Text(
                                          '${CurrencyFormatter.format(option['Amount'])}',
                                          style: inter13),
                                      title: Text(option['NAME'],
                                          style: TextStyle(
                                              fontWeight:
                                                  option['NAME'] == 'TOTAL'
                                                      ? FontWeight.w600
                                                      : FontWeight.w400)),
                                      onTap: () {
                                        print('Selected: ${option['name']}');
                                      },
                                    );
                                  },
                                )),
                          ],
                        ),
                      ),
                    ),
                  ])
          ],
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

String formatAmountforString(double amount) {
  try {
    final NumberFormat numberFormat = NumberFormat("#,##,##0.00", "en_IN");
    return numberFormat.format(amount);
  } catch (e) {
    return amount.toString() ??
        '00.0'; // Return the original value if parsing fails
  }
}
