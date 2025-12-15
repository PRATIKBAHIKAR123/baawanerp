import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/exportbutton.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/norecordfound.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/reports/ledgerRegisterFilter.dart';
import 'package:mlco/screens/reports/trialBalreports/trialBalRegisterDetails.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/reportdownloadservice.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../layouts/backbuttonappbar.dart';

class TrialBalLedgerRegisterReport extends StatefulWidget {
  Map<String, dynamic> filterobject = {};
  TrialBalLedgerRegisterReport({Key? key, required this.filterobject})
      : super(key: key);
  @override
  _TrialBalLedgerRegisterReportState createState() =>
      _TrialBalLedgerRegisterReportState();
}

class _TrialBalLedgerRegisterReportState
    extends State<TrialBalLedgerRegisterReport> with TickerProviderStateMixin {
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
  double openingAmountVal = 0;
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
  Map<String, dynamic> ledgersBalInfo = {};
  List<Map<String, dynamic>> Invoices = [];
  final ScrollController _scrollController = ScrollController();
  bool _isButtonVisible = true;

  List<Map<String, dynamic>> groupedData = [];
  late TabController _tabController;
  late List<Map<String, dynamic>> mainTabs;
  int counter = 1;

  final List<Map<String, dynamic>> parentReports = [
    {'id': '1', 'name': 'Test Project'},
    {'id': '2', 'name': 'Test Project Child'},
    {'id': '2', 'name': 'Test Project Child 2'}
  ];

  @override
  void initState() {
    super.initState();
    mainTabs = [];
    _tabController = TabController(length: mainTabs.length + 1, vsync: this);
    print('widget.filterobject${widget.filterobject}');
    _scrollController.addListener(_scrollListener);
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    todaysDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    loadUserData();
  }

  void add(Map<String, dynamic> item) {
    var existingTab = mainTabs.firstWhere(
      (tab) => tab['text'] == item['key'],
      orElse: () => {},
    );

    if (existingTab.isEmpty) {
      setState(() {
        mainTabs.add({'id': counter++, 'text': item['key'], 'record': item});
        _tabController =
            TabController(length: mainTabs.length + 1, vsync: this);
        _tabController.animateTo(mainTabs.length);
      });
    } else {
      _tabController.animateTo(existingTab['id']);
    }
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

  close(toRemove) {
    setState(() {
      mainTabs = mainTabs.where((x) => x['id'] != toRemove).toList();
      _tabController.animateTo(0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    // DateTime parsedFromDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(fromDate);
    // DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);
    // String formattedFromDate =
    //     DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    // String formattedToDate =
    //     DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    setState(() {
      isLoading = true;
    });

    try {
      print('widget.filterobject${widget.filterobject}');
      var requestBody = widget.filterobject;
      requestBody['sessionId'] = currentSessionId;
      var response = await ledgerRegisterReportListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData['list']);
          List<Map<String, dynamic>> tempInvoices = Invoices;
          openingAmount = decodedData['openingBal'] ?? 0.0;
          print('openingAmount$openingAmount');
          openingAmountVal = openingAmount;
          // Filter the list
          var filteredList = Invoices.where((entry) =>
              entry['type'] != "Closing Amount" &&
              entry['type'] != "Current Total" &&
              entry['type'] != "Opening Amount");

          // Calculate credit and debit sums
          var creditSum = filteredList.fold<double>(
              0.0,
              (total, entry) =>
                  entry['credit'] != null ? total + entry['credit'] : total);

          var debitSum = filteredList.fold<double>(
              0.0,
              (total, entry) =>
                  entry['debit'] != null ? total + entry['debit'] : total);

          // Calculate closing amount
          closingAmount = openingAmount - (creditSum - debitSum);

          // Create a new list with formatted shortDate
          var newArray = Invoices.where((v) => v['invVchId'] != null).map((v) {
            v['shortDate'] = formatDate_(v['billDate']);
            return v;
          }).toList();

          // Group the data by shortDate
          groupedData = groupBy(newArray, 'shortDate')!;
          print('groupedData$groupedData');
          // Process grouped data to calculate opening and closing amounts
          for (var item in groupedData) {
            getOpeningClosing(item);
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

  Future<void> getOpeningClosing(Map<String, dynamic> item) async {
    item['openingAmount'] = openingAmountVal;

    var filteredList = (item['value'] as List<Map<String, dynamic>>).where(
        (entry) =>
            entry['type'] != "Closing Amount" &&
            entry['type'] != "Current Total" &&
            entry['type'] != "Opening Amount");

    var creditSum = filteredList.fold<double>(
        0.0, (total, v) => v['credit'] != null ? total + v['credit'] : total);

    var debitSum = filteredList.fold<double>(
        0.0, (total, v) => v['debit'] != null ? total + v['debit'] : total);

    openingAmountVal = openingAmountVal - (creditSum - debitSum);
    item['closingAmount'] = openingAmountVal;
  }

  String formatDate_(String dateString) {
    DateTime date = DateTime.parse(dateString);
    String year = date.year
        .toString()
        .substring(2); // Get the last two digits of the year
    String month =
        _getMonthAbbreviation(date.month); // Get the abbreviated month name
    return '$month-$year';
  }

  String _getMonthAbbreviation(int month) {
    List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1]; // Subtract 1 to align with the index (0-11)
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
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: 'Report'),
              ...mainTabs.map((tab) => Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${tab['text']}'),
                        IconButton(
                            onPressed: () {
                              close(tab['id']);
                            },
                            icon: Icon(Icons.close))
                      ],
                    ),
                  ))
            ],
            labelColor: mlco_green,
            unselectedLabelColor: Colors.grey,
          ),
          Expanded(
            //height: MediaQuery.of(context).size.height * 0.02,
            child: TabBarView(controller: _tabController, children: [
              reportTab(),
              ...mainTabs.map((tab) => TrialBalRegisterDetailsReport(
                  filterobject: tab['filterobj'] ?? {},
                  itemData: tab['record']))
            ]),
          ),
        ],
      ),
    );
  }

  Widget reportTab() {
    return Column(
      children: [
        if (groupedData == null || groupedData!.isEmpty)
          !isLoading ? noRecordsFound() : Container(),
        isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: groupedData.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    var invoice = groupedData[index];
                    String formattedDate = '';
                    if (invoice['billDate'] != null) {
                      formattedDate = formatDateTime(invoice['billDate']);
                    }

                    double debit = 00;
                    if (invoice['value'] != null) {
                      debit = sumOfArrayProperty(invoice['value'], 'debit');
                    }

                    double credit = 00;
                    if (invoice['value'] != null) {
                      credit = sumOfArrayProperty(invoice['value'], 'credit');
                    }

                    var running = '00';
                    if (invoice['closingAmount'] != null) {
                      running =
                          CurrencyFormatter.format(invoice['closingAmount']);
                    }
                    var perticular = '';
                    if (invoice['particular'] != null) {
                      perticular = invoice['particular'];
                    }
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      color: Color.fromRGBO(255, 255, 255, 1),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // Text(
                                    //   'Bill No - ',
                                    //   style: inter16,
                                    // ),
                                    Text('${invoice['key']}', style: inter13),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$perticular',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    add(invoice);
                                  },
                                  child: Icon(
                                    Icons.remove_red_eye_sharp,
                                    color: Colors.green,
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
                                  child: Text('Opening', style: inter16),
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
                                      '${CurrencyFormatter.format(invoice['openingAmount'])}',
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
                                      '${CurrencyFormatter.format(credit)}',
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
                                      '${CurrencyFormatter.format(debit)}',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text('Closing', style: inter16),
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Opening Amount :' + ' ${formattedTotal}',
                  style: inter14_w600,
                ),
              ],
            ),

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
