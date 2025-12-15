import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/norecordfound.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrialBalRegisterDetailsReport extends StatefulWidget {
  Map<String, dynamic> itemData = {};
  Map<String, dynamic> filterobject = {};
  TrialBalRegisterDetailsReport(
      {Key? key, required this.filterobject, required this.itemData})
      : super(key: key);
  @override
  _TrialBalLedgerRegisterReportState createState() =>
      _TrialBalLedgerRegisterReportState();
}

class _TrialBalLedgerRegisterReportState
    extends State<TrialBalRegisterDetailsReport> with TickerProviderStateMixin {
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
        _tabController.animateTo(mainTabs.length - 1);
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
    Invoices = widget.itemData['value'];
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
                      String formattedDate = '';
                      if (invoice['billDate'] != null) {
                        formattedDate = formatDateTime(invoice['billDate']);
                      }

                      double debit = 00;
                      if (invoice['debit'] != null) {
                        debit = invoice['debit'];
                      }

                      double credit = 00;
                      if (invoice['credit'] != null) {
                        credit = invoice['credit'];
                      }

                      var running = '00';
                      if (invoice['running'] != null) {
                        running = CurrencyFormatter.format(invoice['running']);
                      }
                      var perticular = '';
                      if (invoice['particular'] != null) {
                        perticular = invoice['particular'];
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
                                      Text('${invoice['billNo']}',
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
                                  Text(
                                    '$perticular',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
                                    child: Icon(
                                      Icons.remove_red_eye_sharp,
                                      color: Colors.green,
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
                                    child: Text('Type', style: inter16),
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
                                        '${invoice['type']}',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Running', style: inter16),
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
