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
import 'package:mlco/screens/reports/trialBalreports/trialballedgerregister.dart';
import 'package:mlco/services/reportdownloadservice.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrialBalReportScreen extends StatefulWidget {
  @override
  _TrialBalReportScreenState createState() => _TrialBalReportScreenState();
}

class _TrialBalReportScreenState extends State<TrialBalReportScreen>
    with TickerProviderStateMixin {
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
    {'id': '1', 'name': 'Expense'},
    {'id': '2', 'name': 'INCOME'},
  ];
  List<Map<String, dynamic>> purchaseAccountsDetails = [];
  List<Map<String, dynamic>> directExpensesDetails = [];
  List<Map<String, dynamic>> indirectExpensesDetails = [];
  List<Map<String, dynamic>> salesAccountsDetails = [];
  List<Map<String, dynamic>> directIncomesDetails = [];
  List<Map<String, dynamic>> indirectIncomesDetails = [];
  List<Map<String, dynamic>> Invoices = [];
  List<Map<String, dynamic>> value = [];
  Map<String, dynamic> income = {};
  bool showOpeningBal = false;
  bool showDebit = false;
  bool showCredit = false;
  bool salesAccountsLoaded = false;
  bool directIncomesLoaded = false;
  bool indirectIncomesLoaded = false;
  late TabController _tabController;
  List<Map<String, dynamic>> grpList = [
    // Add your grpList here
  ];
  List<Map<String, dynamic>> lst = [];
  double netAmount = 0;
  late List<bool> _isExpanded;
  late List<List<bool>> _isChildExpanded;
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
    getGroups();

    mainTabs = [];
    _tabController = TabController(length: mainTabs.length + 1, vsync: this);
    fromDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    todaysDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    loadUserData();
  }

  void updateDates(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    getList(null);
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
          getList(null); // Call getList() after loading user data
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

  getGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? groupList = prefs.getStringList('group-list');
    if (groupList != null) {
      grpList = groupList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    }
    setState(() {}); // Trigger a rebuild to update the UI
  }

  getList(item) async {
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
        "sessionId": currentSessionId
      };
      if (item != null) {
        requestBody['groupId'] = item['ID'].toString();
      }

      var response = await trailBalReportService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);
          if (Invoices.isNotEmpty) {
            for (var v in Invoices) {
              if (v['ISGROUP'] != null && v['ISGROUP']) {
                var rec = grpList.firstWhere(
                  (x) => x['id'] == v['ID'],
                  orElse: () => <String, dynamic>{},
                );
                if (rec != null) {
                  if (rec['nature'] == 2 || rec['nature'] == 3) {
                    v['nature'] = 'Liabilities';
                  } else if (rec['nature'] == 1 || rec['nature'] == 4) {
                    v['nature'] = 'Assets';
                  }
                }
              }
            }

            // Sort the data so Liabilities come first
            Invoices.sort((a, b) {
              if (a['nature'] == 'Liabilities' && b['nature'] == 'Assets') {
                return -1;
              }
              if (a['nature'] == 'Assets' && b['nature'] == 'Liabilities') {
                return 1;
              }
              return 0;
            });

            if (item == null) {
              lst = Invoices;
              netAmount = lst.fold(
                0.0,
                (sum, obj) =>
                    sum +
                    (obj['OPENINGBAL'] ?? 0) +
                    (obj['DEBIT'] ?? 0) +
                    (obj['CREDIT'] ?? 0),
              );
              tabs = groupBy(lst, 'nature') ?? [];
              _onQuickLinkTapped(tabs.first['key']);
              _isExpanded = List<bool>.filled(Invoices!.length, false);
              _isChildExpanded = List.generate(Invoices!.length, (index) => []);
              print('_isExpanded: $_isExpanded');
            } else {
              var childdata = [];
              childdata = Invoices;
              print('childdata$childdata');
              item['isChildDataLoaded'] = true;
              item['childNodeData'] = childdata;
              if (childdata.isNotEmpty) {
                int index = value.indexOf(item);
                if (index != -1 && index < _isChildExpanded.length) {
                  _isChildExpanded[index] =
                      List<bool>.filled(childdata.length, false);
                }
                print('_isChildExpanded updated');
              }
            }

            if (item != null && item['childNodeData'].isNotEmpty) {}
          } else {
            lst = [];
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

  toggleItem(item) {
    print('item$item');
    if (item['ISGROUP']) {
      if (item['isChildDataLoaded'] == null) {
        getList(item);
      }
    } else {
      addNewTab(item);
    }
  }

  close(toRemove) {
    setState(() {
      mainTabs = mainTabs.where((x) => x['id'] != toRemove).toList();
      _tabController.animateTo(0);
    });
  }

  void _onQuickLinkTapped(id) {
    print(id);

    setState(() {
      selectedParent = id;
      var filteredvalue = tabs.where((test) => test['key'] == id).toList();
      value = filteredvalue.first['value'];
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

  addNewTab(item) {
    item['filterobj'] = {};
    item['filterobj'] = {
      'from': fromDate,
      'to': toDate,
      'ledgerId': item['ID'],
      'runningBalance': true,
      'openingBalance': true,
      'billDetails': false,
      'bankDetails': false,
      'isPdc': false,
      'includeChildLedgers': true,
      'monthWise': true
    };
    item['ledgerName'] = item['NAME'];
    add(item);
  }

  void add(Map<String, dynamic> item) {
    var existingTab = mainTabs.firstWhere(
      (tab) => tab['text'] == item['ledgerName'],
      orElse: () => {},
    );

    if (existingTab.isEmpty) {
      setState(() {
        mainTabs.add({
          'id': counter++,
          'text': item['ledgerName'],
          'filterobj': item['filterobj']
        });
        _tabController =
            TabController(length: mainTabs.length + 1, vsync: this);
        _tabController.animateTo(mainTabs.length);
      });
    } else {
      _tabController.animateTo(existingTab['id']);
    }
  }

  double getNetAmount(List<Map<String, dynamic>> lst) {
    double sumOpeningBal =
        lst.fold(0.0, (sum, obj) => sum + (obj['OPENINGBAL'] ?? 0.0));
    double sumDebit = lst.fold(0.0, (sum, obj) => sum + (obj['DEBIT'] ?? 0.0));
    double sumCredit =
        lst.fold(0.0, (sum, obj) => sum + (obj['CREDIT'] ?? 0.0));
    return sumOpeningBal + sumDebit + sumCredit;
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
                      'Trial Balance',
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
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: 'Trial Balance'),
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
              trialBalTab(),
              ...mainTabs.map((tab) => TrialBalLedgerRegisterReport(
                    filterobject: tab['filterobj'] ?? {},
                  ))
            ]),
          ),
        ],
      ),
      bottomSheet: outstadingBottomsheet(netAmount),
    );
  }

  Widget trialBalTab() {
    return Column(
      children: [
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
                        child: Text(
                          link['key'] ?? '',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: link['key'] == selectedParent
                                ? Colors.white
                                : Colors.black,
                            fontSize: 14,
                          ),
                        ))),
              );
            }).toList(),
          ),
        ),
        checkboxes(),
        SizedBox(
          height: 10,
        ),
        if (selectedParent == selectedParent) ...[
          if (Invoices == null || Invoices!.isEmpty)
            !isLoading ? noRecordsFound() : Container(),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: value?.length ?? 0,
                    itemBuilder: (context, index) {
                      if (value == null || value!.isEmpty) {
                        return Center(
                          child: Text('No invoices found'),
                        );
                      }
                      var invoice = value![index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   '${formattedDate} ',
                            //   style: inter400,
                            // ),

                            SizedBox(
                              height: 6,
                            ),
                            customHeader(
                                index, invoice, _isExpanded[index], "parent"),
                            if (showOpeningBal)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Opening Balance',
                                      style: inter600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      ':',
                                      style: inter600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      '₹${formatAmount(invoice['OPENINGBAL'])}',
                                      style: inter400,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                            SizedBox(
                              height: 6,
                            ),
                            if (showDebit)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Debit',
                                      style: inter600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      ':',
                                      style: inter600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      '₹${formatAmount(invoice['DEBIT'])}',
                                      style: inter400,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 6,
                            ),
                            if (showCredit)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Credit',
                                      style: inter600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      ':',
                                      style: inter600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      '₹${formatAmount(invoice['CREDIT'])}',
                                      style: inter400,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 2,
                            ),
                            if (_isExpanded[index] &&
                                invoice['childNodeData'] != null) ...[
                              Container(
                                  height: 120,
                                  child: ListView.builder(
                                      itemCount:
                                          invoice['childNodeData']?.length ?? 0,
                                      itemBuilder: (context, childindex) {
                                        if (invoice['childNodeData'] == null ||
                                            invoice['childNodeData'].isEmpty) {
                                          return SizedBox.shrink();
                                        }
                                        var groupchildData = invoice[
                                            'childNodeData']![childindex];
                                        return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 6,
                                                  ),
                                                  customHeader(
                                                      childindex,
                                                      groupchildData,
                                                      _isChildExpanded[index]
                                                          [childindex],
                                                      "child"),
                                                  if (showOpeningBal)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            'Opening Balance',
                                                            style: inter600,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            ':',
                                                            style: inter600,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            '₹${formatAmount(groupchildData['OPENINGBAL'])}',
                                                            style: inter400,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  SizedBox(
                                                    height: 6,
                                                  ),
                                                  if (showDebit)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            'Debit',
                                                            style: inter600,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            ':',
                                                            style: inter600,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            '₹${formatAmount(groupchildData['DEBIT'])}',
                                                            style: inter400,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  SizedBox(
                                                    height: 6,
                                                  ),
                                                  if (showCredit)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            'Credit',
                                                            style: inter600,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            ':',
                                                            style: inter600,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            '₹${formatAmount(groupchildData['CREDIT'])}',
                                                            style: inter400,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  if (_isChildExpanded[index]
                                                      [childindex]) ...[
                                                    SingleChildScrollView(
                                                      child: Column(
                                                        children: List.generate(
                                                          groupchildData[
                                                                      'childNodeData']
                                                                  ?.length ??
                                                              0,
                                                          (childindex) {
                                                            var childgroupchildData =
                                                                groupchildData[
                                                                        'childNodeData']![
                                                                    childindex];
                                                            return Container(
                                                              decoration: BoxDecoration(
                                                                  border: Border(
                                                                      left: BorderSide(
                                                                          color:
                                                                              Colors.grey))),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8.0),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 3,
                                                                        child:
                                                                            Text(
                                                                          '${childgroupchildData['NAME']}',
                                                                          style:
                                                                              inter600,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 8.0),
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                toggleItem(childgroupchildData);
                                                                              },
                                                                              child: Icon(
                                                                                Icons.folder,
                                                                              ),
                                                                            ),
                                                                          )),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 6,
                                                                  ),
                                                                  if (showOpeningBal)
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Text(
                                                                            'Opening Balance',
                                                                            style:
                                                                                inter600,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Text(
                                                                            ':',
                                                                            style:
                                                                                inter600,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              4,
                                                                          child:
                                                                              Text(
                                                                            '₹${formatAmount(childgroupchildData['OPENINGBAL'])}',
                                                                            style:
                                                                                inter400,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  SizedBox(
                                                                    height: 6,
                                                                  ),
                                                                  if (showDebit)
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Text(
                                                                            'Debit',
                                                                            style:
                                                                                inter600,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Text(
                                                                            ':',
                                                                            style:
                                                                                inter600,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              4,
                                                                          child:
                                                                              Text(
                                                                            '₹${formatAmount(childgroupchildData['DEBIT'])}',
                                                                            style:
                                                                                inter400,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  SizedBox(
                                                                    height: 6,
                                                                  ),
                                                                  if (showCredit)
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Text(
                                                                            'Credit',
                                                                            style:
                                                                                inter600,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Text(
                                                                            ':',
                                                                            style:
                                                                                inter600,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              4,
                                                                          child:
                                                                              Text(
                                                                            '₹${formatAmount(childgroupchildData['CREDIT'])}',
                                                                            style:
                                                                                inter400,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ]));
                                      }))
                            ],
                            Divider()
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ],
    );
  }

  Widget customHeader(
      int index, Map<String, dynamic> item, bool isExpanded, String type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Text(
                      '${item['NAME']}',
                      style: inter600,
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      '₹${formatAmount(item['OPENINGBAL'] + item['DEBIT'] + item['CREDIT'])}',
                      style: inter600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () {
                toggleItem(item);
                setState(() {
                  if (type == "parent") {
                    if (index < _isExpanded.length) {
                      _isExpanded[index] = !_isExpanded[index];
                      // _isChildExpanded[index] = List<bool>.filled(
                      //   item['childNodeData']?.length ?? 0,
                      //   false,
                      // );
                    }
                  } else {
                    final parentIndex = _isExpanded.indexOf(true);
                    if (parentIndex < _isChildExpanded.length &&
                        index < _isChildExpanded[parentIndex].length) {
                      _isChildExpanded[parentIndex][index] =
                          !_isChildExpanded[parentIndex][index];
                    }
                  }
                });
              },
              child: Icon(
                isExpanded ? Icons.remove_circle : Icons.add_circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget checkboxes() {
    return Row(
      children: [
        Checkbox(
          value: showOpeningBal,
          onChanged: (value) {
            setState(() {
              showOpeningBal = value!;
            });
          },
        ),
        Text('Opening Balance'),
        Checkbox(
          value: showDebit,
          onChanged: (value) {
            setState(() {
              showDebit = value!;
            });
          },
        ),
        Text('Debit'),
        Checkbox(
          value: showCredit,
          onChanged: (value) {
            setState(() {
              showCredit = value!;
            });
          },
        ),
        Text('Credit'),
      ],
    );
  }

  Widget outstadingBottomsheet(totalamount) {
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
    return Container(
      padding: EdgeInsets.all(16),
      //height: 120,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(gradient: mlcoGradient),
      child: BottomSheet(
        backgroundColor: Colors.transparent,
        onClosing: () {},
        builder: (BuildContext context) {
          return Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total',
                      style: inter600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      ':',
                      style: inter600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      '₹${formatAmount(getNetAmount(value))}',
                      style: inter14_w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (showOpeningBal)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Opening Balance',
                        style: inter600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        ':',
                        style: inter600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        '₹${sumOfArrayProperty(value, 'OPENINGBAL')}',
                        style: inter14_w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 6,
              ),
              if (showDebit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Debit',
                        style: inter600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        ':',
                        style: inter600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        '₹${sumOfArrayProperty(value, 'DEBIT')}',
                        style: inter14_w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 6,
              ),
              if (showCredit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Credit',
                        style: inter600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        ':',
                        style: inter600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        '₹${sumOfArrayProperty(value, 'CREDIT')}',
                        style: inter14_w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
            ],
          );
        },
      ),
    );
  }
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
