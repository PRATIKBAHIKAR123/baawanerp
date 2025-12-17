import 'dart:convert';
import 'dart:math';

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
  bool showOpeningBal = true;
  bool showDebit = true;
  bool showCredit = true;
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
    await getGroups(); // Wait for groups to load first
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
          getList(null); // Call getList() after loading user data and groups
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

  // Helper function to determine Dr/Cr based on group nature and sign
  Map<String, dynamic> _formatDrCr(double amount, bool isCreditNature) {
    if (amount == 0) {
      return {'value': 0.0, 'type': ''};
    }

    if (isCreditNature) {
      // Liabilities / Capital / Sales (isCr = true)
      return amount >= 0
          ? {'value': amount.abs(), 'type': 'Cr'}
          : {'value': amount.abs(), 'type': 'Dr'};
    } else {
      // Assets / Expenses / Purchases (isCr = false)
      return amount >= 0
          ? {'value': amount.abs(), 'type': 'Dr'}
          : {'value': amount.abs(), 'type': 'Cr'};
    }
  }

// Main processing function
  void _processTrialBalanceItem(
      Map<String, dynamic> item, Map<String, dynamic> group) {
    if (group['isCr'] == null) {
      print(
          'processTrialBalanceItem: Missing or invalid group info for item: $item, group: $group');
      item['nature'] = 'Others';
      // Set default values to avoid null errors, assuming debit nature
      bool isCr = false;
      double opening = (item['OPENINGBAL'] ?? 0.0).toDouble();
      double debit = (item['DEBIT'] ?? 0.0).toDouble();
      double credit = (item['CREDIT'] ?? 0.0).toDouble();
      double closing = opening + debit - credit;

      var openingDisplay = _formatDrCr(opening, isCr);
      var closingDisplay = _formatDrCr(closing, isCr);

      item['processedOpeningBalance'] = openingDisplay['value'];
      item['openingDrCr'] = openingDisplay['type'];
      item['processedDebit'] = debit.abs();
      item['processedCredit'] = credit.abs();
      item['processedClosingBalance'] = closingDisplay['value'];
      item['closingDrCr'] = closingDisplay['type'];
      item['originalOpeningBalance'] = opening;
      item['originalClosingBalance'] = closing;
      item['groupInfo'] = group;
      return;
    }

    bool isCr = group['isCr'] as bool;

    // Step 1: Get raw signed values from API
    double opening = (item['OPENINGBAL'] ?? 0.0).toDouble();
    double debit = (item['DEBIT'] ?? 0.0).toDouble();
    double credit = (item['CREDIT'] ?? 0.0).toDouble();

    // Step 2: Calculate closing balance based on group nature
    double closing;
    if (isCr) {
      // Credit nature: opening - debit + credit = closing
      closing = opening - debit + credit;
    } else {
      // Debit nature: opening + debit - credit = closing
      closing = opening + debit - credit;
    }

    // Step 3: Determine Dr/Cr for display
    var openingDisplay = _formatDrCr(opening, isCr);
    var closingDisplay = _formatDrCr(closing, isCr);

    // Step 4: Store values for display
    item['processedOpeningBalance'] = openingDisplay['value'];
    item['openingDrCr'] = openingDisplay['type'];

    item['processedDebit'] = debit.abs();
    item['processedCredit'] = credit.abs();

    item['processedClosingBalance'] = closingDisplay['value'];
    item['closingDrCr'] = closingDisplay['type'];

    // Store original signed values for reference
    item['originalOpeningBalance'] = opening;
    item['originalDebit'] = debit;
    item['originalCredit'] = credit;
    item['originalClosingBalance'] = closing;
    item['groupInfo'] = group; // Store group info for later use in totals
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
          var data = List<Map<String, dynamic>>.from(decodedData);

          if (data.isNotEmpty) {
            for (var v in data) {
              Map<String, dynamic> group = {};
              if (v['ISGROUP'] == true) {
                group = grpList.firstWhere(
                  (g) => g['id'].toString() == v['ID'].toString(),
                  orElse: () => {},
                );
              } else {
                var groupId = v['groupId'] ?? v['parentId'];
                if (groupId != null) {
                  group = grpList.firstWhere(
                    (g) => g['id'].toString() == groupId.toString(),
                    orElse: () => {},
                  );
                }
              }

              if (group.isNotEmpty) {
                 if (group['nature'] == 2 || group['nature'] == 3) {
                    v['nature'] = 'Liabilities';
                  } else if (group['nature'] == 1 || group['nature'] == 4) {
                    v['nature'] = 'Assets';
                  }
                _processTrialBalanceItem(v, group);
              } else {
                 _processTrialBalanceItem(v, {});
              }
            }

            // Sort the data so Liabilities come first
            data.sort((a, b) {
              if (a['nature'] == 'Liabilities' && b['nature'] == 'Assets') {
                return -1;
              }
              if (a['nature'] == 'Assets' && b['nature'] == 'Liabilities') {
                return 1;
              }
              return 0;
            });

            if (item == null) {
              lst = data;
              netAmount = getNetAmount(lst);
              tabs = groupBy(lst, 'nature') ?? [];
              if (tabs.isNotEmpty) {
                _onQuickLinkTapped(tabs.first['key']);
              } else {
                value = [];
              }
              _isExpanded = List<bool>.filled(lst.length, false);
              _isChildExpanded = List.generate(lst.length, (index) => []);
            } else {
              item['isChildDataLoaded'] = true;
              item['childNodeData'] = data;
              if (data.isNotEmpty) {
                int index = value.indexOf(item);
                if (index != -1 && index < _isChildExpanded.length) {
                  _isChildExpanded[index] =
                      List<bool>.filled(data.length, false);
                }
              }
            }
          } else {
            if (item == null) {
              lst = [];
              tabs = [];
              value = [];
            } else {
              item['childNodeData'] = [];
            }
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
    if (id == null) return;
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

  double _getNetAmountWithSign(List<dynamic> list) {
    if (list == null) return 0.0;
    return list.fold(0.0, (sum, obj) {
      return sum + (obj['originalClosingBalance'] ?? 0.0);
    });
  }

  double getTotalProcessedOpeningBalance(List<dynamic> list) {
    if (list == null) return 0.0;
    double totalOpening = list.fold(0.0, (sum, obj) => sum + (obj['originalOpeningBalance'] ?? 0.0));
    return totalOpening.abs();
  }

  double getTotalProcessedDebit(List<dynamic> list) {
    if (list == null) return 0.0;
    return list.fold(0.0, (sum, obj) => sum + (obj['processedDebit'] ?? 0.0));
  }

  double getTotalProcessedCredit(List<dynamic> list) {
    if (list == null) return 0.0;
    return list.fold(0.0, (sum, obj) => sum + (obj['processedCredit'] ?? 0.0));
  }

  double getNetAmount(List<dynamic> list) {
    if (list == null) return 0.0;
    return _getNetAmountWithSign(list).abs();
  }

  String _getOpeningDrCrForGroup(List<dynamic> list) {
    if (list == null || list.isEmpty) return '';

    var firstItem = list.first;
    var groupInfo = firstItem['groupInfo'];

    if (groupInfo == null || groupInfo['isCr'] == null) {
      return '';
    }

    bool isCr = groupInfo['isCr'] as bool;
    double totalOpening = list.fold(
        0.0, (sum, obj) => sum + (obj['originalOpeningBalance'] ?? 0.0));

    var display = _formatDrCr(totalOpening, isCr);
    return display['type'];
  }

  String _getClosingDrCrForGroup(List<dynamic> list) {
    if (list == null || list.isEmpty) return '';

    var firstItem = list.first;
    var groupInfo = firstItem['groupInfo'];
    if (groupInfo == null || groupInfo['isCr'] == null) {
       for (var item in list) {
        if (item['groupInfo'] != null && item['groupInfo']['isCr'] != null) {
          bool isCr = item['groupInfo']['isCr'] as bool;
          double netAmount = _getNetAmountWithSign(list);
          return _formatDrCr(netAmount, isCr)['type'];
        }
      }
      return ''; // Fallback
    }

    bool isCr = groupInfo['isCr'] as bool;
    double netAmount = _getNetAmountWithSign(list);
    return _formatDrCr(netAmount, isCr)['type'];
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
          if (value == null || value!.isEmpty)
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
                                      '${CurrencyFormatter.format(invoice['processedOpeningBalance'] ?? 0.0)} ${invoice['openingDrCr'] ?? ''}',
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
                                      '${CurrencyFormatter.format(invoice['processedDebit'] ?? 0.0)}',
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
                                      '${CurrencyFormatter.format(invoice['processedCredit'] ?? 0.0)}',
                                      style: inter400,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 2,
                            ),
                            if (_isExpanded.length > index && _isExpanded[index] &&
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
                                                        _isChildExpanded.length > index && _isChildExpanded[index] != null && _isChildExpanded[index].length > childindex ? _isChildExpanded[index][childindex] : false,
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
                                                            '${CurrencyFormatter.format(groupchildData['processedOpeningBalance'] ?? 0.0)} ${groupchildData['openingDrCr'] ?? ''}',
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
                                                            '${CurrencyFormatter.format(groupchildData['processedDebit'] ?? 0.0)}',
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
                                                            '${CurrencyFormatter.format(groupchildData['processedCredit'] ?? 0.0)}',
                                                            style: inter400,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  if (_isChildExpanded.length > index &&_isChildExpanded[index]
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
                                                                            '${CurrencyFormatter.format(childgroupchildData['processedOpeningBalance'] ?? 0.0)} ${childgroupchildData['openingDrCr'] ?? ''}',
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
                                                                            '${CurrencyFormatter.format(childgroupchildData['processedDebit'] ?? 0.0)}',
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
                                                                            '${CurrencyFormatter.format(childgroupchildData['processedCredit'] ?? 0.0)}',
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
                      '${CurrencyFormatter.format(item['processedClosingBalance'] ?? 0.0)} ${item['closingDrCr'] ?? ''}',
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
                    }
                  } else {
                    final parentIndex = _isExpanded.indexOf(true);
                    if (parentIndex !=-1 && parentIndex < _isChildExpanded.length &&
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
    
    return Container(
      padding: EdgeInsets.all(16),
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
                      'Total Closing',
                      style: inter14_w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      ':',
                      style: inter14_w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      '${CurrencyFormatter.format(getNetAmount(lst))} ${_getClosingDrCrForGroup(lst)}',
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
                        'Total Opening',
                        style: inter14_w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        ':',
                        style: inter14_w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        '${CurrencyFormatter.format(getTotalProcessedOpeningBalance(lst))} ${_getOpeningDrCrForGroup(lst)}',
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
                        'Total Debit',
                        style: inter14_w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        ':',
                        style: inter14_w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        '${CurrencyFormatter.format(getTotalProcessedDebit(lst))}',
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
                        'Total Credit',
                        style: inter14_w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        ':',
                        style: inter14_w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        '${CurrencyFormatter.format(getTotalProcessedCredit(lst))}',
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
    return amount.toString();
  }
}
