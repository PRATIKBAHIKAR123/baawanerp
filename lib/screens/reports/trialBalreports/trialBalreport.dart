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
import 'package:mlco/screens/reports/groupsummaryreport.dart';
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

  List<UpdateAddressModel> trialBalanceList = [];
  Map<int, List<UpdateAddressModel>> expandedItems = {};

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
    UpdateAddressModel selecteditem = item;
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
        requestBody['groupId'] = item.id.toString();
      }

      var response = await trailBalReportService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);

          if (Invoices.isNotEmpty) {
            var parentGroup = item != null ? item['groupInfo'] : null;
            for (var v in Invoices) {
              if (v['ISGROUP'] != null && v['ISGROUP']) {
                var rec = grpList.firstWhere(
                  (x) => x['id'] == v['ID'],
                  orElse: () => <String, dynamic>{},
                );
                if (rec.isNotEmpty) {
                  if (rec['nature'] == 2 || rec['nature'] == 3) {
                    v['nature'] = 'Liabilities';
                  } else if (rec['nature'] == 1 || rec['nature'] == 4) {
                    v['nature'] = 'Assets';
                  }
                  v['groupInfo'] = rec;
                  processTrialBalanceItem(v, rec);
                }
              } else {
                // For non-group items (ledgers), find parent group
                var group = parentGroup;
                if (group == null && v['groupId'] != null) {
                  group = grpList.firstWhere((x) => x['id'] == v['groupId'],
                      orElse: () => {});
                }
                if (group != null && group.isNotEmpty) {
                  // Propagate nature from parent group so grouping/sorting matches Angular
                  if (group['nature'] == 2 || group['nature'] == 3) {
                    v['nature'] = 'Liabilities';
                  } else if (group['nature'] == 1 || group['nature'] == 4) {
                    v['nature'] = 'Assets';
                  }
                  v['groupInfo'] = group;
                  processTrialBalanceItem(v, group);
                } else {
                  // Fallback or error
                  processTrialBalanceItem(v, {});
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
              netAmount = getNetAmount(lst);
              tabs = groupBy(lst, 'nature') ?? [];
              if (tabs.isNotEmpty) {
                _onQuickLinkTapped(tabs.first['key']);
              }
              _isExpanded = List<bool>.filled(Invoices.length, false);
            } else {
              final List<UpdateAddressModel> fetchedItems =
                  updateAddressModelFromJson(Invoices);
              expandedItems[item.id] = fetchedItems;
              item['isChildDataLoaded'] = true;
              item['childNodeData'] = Invoices;
              if (Invoices.isNotEmpty) {
                _isChildExpanded = List.generate(
                  growable: true,
                  Invoices.length,
                  (index) => List<bool>.filled(
                      item['childNodeData'] != null ? Invoices.length : 0,
                      false,
                      growable: true),
                );
              } else {
                _isChildExpanded = [];
              }
            }
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
    List<UpdateAddressModel> fetchedItems = [];
    setState(() {
      selectedParent = id;
      var filteredvalue = tabs.where((test) => test['key'] == id).toList();
      value = filteredvalue.first['value'];
      fetchedItems = updateAddressModelFromJson(filteredvalue.first['value']);
      trialBalanceList = fetchedItems;
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

  double getNetAmountWithSign(List<Map<String, dynamic>> lst) {
    if (lst == null) return 0.0;

    return lst.fold(0.0, (sum, obj) {
      // Use calculated closing when available
      if (obj['originalClosingBalance'] != null) {
        return sum + (obj['originalClosingBalance'] as num).toDouble();
      }

      // Fallback: calculate from raw values based on group nature (matches Angular)
      final opening =
          (obj['originalOpeningBalance'] ?? obj['OPENINGBAL'] ?? 0.0)
              .toDouble();
      final debit = (obj['originalDebit'] ?? obj['DEBIT'] ?? 0.0).toDouble();
      final credit = (obj['originalCredit'] ?? obj['CREDIT'] ?? 0.0).toDouble();
      final groupInfo = obj['groupInfo'];
      final isCr = groupInfo != null ? groupInfo['isCr'] : obj['isCr'];

      if (isCr == true) {
        return sum + (opening - debit + credit);
      } else if (isCr == false) {
        return sum + (opening + debit - credit);
      }

      return sum + (opening + debit + credit);
    });
  }

  double getNetAmount(List<Map<String, dynamic>> lst) {
    return getNetAmountWithSign(lst).abs();
  }

  Map<String, dynamic> formatDrCr(double amount, bool isCreditNature) {
    if (amount == 0) {
      return {'value': 0.0, 'type': ''};
    }
    if (isCreditNature) {
      return amount >= 0
          ? {'value': amount.abs(), 'type': 'Cr'}
          : {'value': amount.abs(), 'type': 'Dr'};
    } else {
      return amount >= 0
          ? {'value': amount.abs(), 'type': 'Dr'}
          : {'value': amount.abs(), 'type': 'Cr'};
    }
  }

  void processTrialBalanceItem(
      Map<String, dynamic> item, Map<String, dynamic> group) {
    // Resolve group info from cached grpList first, then fallback heuristic
    final resolvedGroup = _resolveGroupInfo(item, group);
    item['groupInfo'] = resolvedGroup;

    bool isCr = resolvedGroup['isCr'] == true;
    item['isCr'] = isCr;

    double opening = item['OPENINGBAL']?.toDouble() ?? 0.0;
    double debit = item['DEBIT']?.toDouble() ?? 0.0;
    double credit = item['CREDIT']?.toDouble() ?? 0.0;

    double closing;
    if (isCr) {
      closing = opening - debit + credit;
    } else {
      closing = opening + debit - credit;
    }

    var openingDisplay = formatDrCr(opening, isCr);
    var closingDisplay = formatDrCr(closing, isCr);

    item['processedOpeningBalance'] = openingDisplay['value'];
    item['openingDrCr'] = openingDisplay['type'];
    item['processedDebit'] = debit.abs();
    item['processedCredit'] = credit.abs();
    item['processedClosingBalance'] = closingDisplay['value'];
    item['closingDrCr'] = closingDisplay['type'];

    item['originalOpeningBalance'] = opening;
    item['originalDebit'] = debit;
    item['originalCredit'] = credit;
    item['originalClosingBalance'] = closing;
  }

  Map<String, dynamic> _resolveGroupInfo(
      Map<String, dynamic> item, Map<String, dynamic> incomingGroup) {
    // 1) If incoming group is valid (has isCr), use it
    if (incomingGroup.isNotEmpty && incomingGroup['isCr'] != null) {
      return incomingGroup;
    }

    // 2) Try from grpList by direct id
    Map<String, dynamic>? fromId =
        grpList.firstWhere((g) => g['id'] == item['ID'], orElse: () => {});
    if (fromId.isNotEmpty && fromId['isCr'] != null) {
      _attachNatureLabel(fromId);
      return fromId;
    }

    // 3) Try from grpList by groupId/parentId
    final parentKey = item['groupId'] ?? item['parentId'];
    if (parentKey != null) {
      Map<String, dynamic>? parent =
          grpList.firstWhere((g) => g['id'] == parentKey, orElse: () => {});
      if (parent.isNotEmpty && parent['isCr'] != null) {
        _attachNatureLabel(parent);
        return parent;
      }
    }

    // 4) Fallback heuristic (name-based)
    final derived = _deriveGroupInfo(item);
    _attachNatureLabel(derived);
    return derived;
  }

  void _attachNatureLabel(Map<String, dynamic> group) {
    if (group['nature'] != null && group['natureLabel'] != null) return;
    final nature = group['nature'];
    if (nature == 2 || nature == 3) {
      group['natureLabel'] = 'Liabilities';
    } else if (nature == 1 || nature == 4) {
      group['natureLabel'] = 'Assets';
    }
  }

  // Derive group info when not provided from cache (guards against missing grpList)
  Map<String, dynamic> _deriveGroupInfo(Map<String, dynamic> item) {
    final name = (item['NAME'] ?? '').toString().toLowerCase();

    // Heuristic: credit-nature groups
    final isCr = (name.contains('capital') ||
            name.contains('liabil') ||
            name.contains('sales') ||
            name.contains('income'))
        ? true
        : false;

    final nature = isCr ? 'Liabilities' : 'Assets';

    return {'isCr': isCr, 'nature': nature};
  }

  // ---------- Helpers mirrored from Angular logic ----------
  double getProcessedOpeningBalance(Map<String, dynamic> item) {
    if (item['processedOpeningBalance'] != null) {
      return (item['processedOpeningBalance'] as num).toDouble();
    }
    final isCr =
        item['groupInfo'] != null ? item['groupInfo']['isCr'] : item['isCr'];
    if (isCr != null) {
      final display = formatDrCr((item['OPENINGBAL'] ?? 0).toDouble(), isCr);
      item['processedOpeningBalance'] = display['value'];
      item['openingDrCr'] = display['type'];
      return (display['value'] as num).toDouble();
    }
    return (item['OPENINGBAL'] ?? 0).abs().toDouble();
  }

  double getProcessedDebit(Map<String, dynamic> item) {
    if (item['processedDebit'] != null) {
      return (item['processedDebit'] as num).toDouble();
    }
    return (item['DEBIT'] ?? 0).abs().toDouble();
  }

  double getProcessedCredit(Map<String, dynamic> item) {
    if (item['processedCredit'] != null) {
      return (item['processedCredit'] as num).toDouble();
    }
    return (item['CREDIT'] ?? 0).abs().toDouble();
  }

  double getProcessedClosingBalanceValue(Map<String, dynamic> item) {
    if (item['processedClosingBalance'] != null) {
      return (item['processedClosingBalance'] as num).toDouble();
    }
    return ((item['OPENINGBAL'] ?? 0) +
            (item['DEBIT'] ?? 0) +
            (item['CREDIT'] ?? 0))
        .abs()
        .toDouble();
  }

  String getClosingDrCr(Map<String, dynamic> item) {
    if (item['closingDrCr'] != null) {
      return item['closingDrCr'];
    }

    final isCr =
        item['groupInfo'] != null ? item['groupInfo']['isCr'] : item['isCr'];
    final opening =
        (item['originalOpeningBalance'] ?? item['OPENINGBAL'] ?? 0.0)
            .toDouble();
    final debit = (item['originalDebit'] ?? item['DEBIT'] ?? 0.0).toDouble();
    final credit = (item['originalCredit'] ?? item['CREDIT'] ?? 0.0).toDouble();

    double closing;
    if (isCr == true) {
      closing = opening - debit + credit;
    } else if (isCr == false) {
      closing = opening + debit - credit;
    } else {
      closing = opening + debit + credit;
    }

    return formatDrCr(closing, isCr == true)['type'] ?? '';
  }

  double getTotalProcessedOpeningBalance(List<Map<String, dynamic>> lst) {
    final totalOpening = lst.fold<double>(
        0.0,
        (sum, obj) =>
            sum +
            ((obj['originalOpeningBalance'] ?? obj['OPENINGBAL'] ?? 0.0)
                .toDouble()));

    final firstItem = lst.isNotEmpty ? lst.first : null;
    final isCr = firstItem != null && firstItem['groupInfo'] != null
        ? firstItem['groupInfo']['isCr']
        : firstItem?['isCr'];
    if (isCr != null) {
      final display = formatDrCr(totalOpening, isCr);
      return (display['value'] as num).toDouble();
    }
    return totalOpening.abs();
  }

  double getTotalOpeningBalanceWithSign(List<Map<String, dynamic>> lst) {
    return lst.fold<double>(
        0.0,
        (sum, obj) =>
            sum +
            ((obj['originalOpeningBalance'] ?? obj['OPENINGBAL'] ?? 0.0)
                .toDouble()));
  }

  String getOpeningDrCrForGroup(List<Map<String, dynamic>> lst) {
    if (lst.isEmpty) return '';

    Map<String, dynamic>? groupInfo = lst.firstWhere(
        (item) => item['groupInfo'] != null,
        orElse: () => <String, dynamic>{})['groupInfo'];

    if (groupInfo == null) {
      groupInfo = lst.firstWhere((item) => item['isCr'] != null,
          orElse: () => <String, dynamic>{});
    }

    if (groupInfo == null) return '';
    final isCr = groupInfo['isCr'] ?? groupInfo['iscr'] ?? groupInfo['isCr'];
    final totalOpening = getTotalOpeningBalanceWithSign(lst);
    if (totalOpening >= 0) {
      return isCr == true ? 'Cr' : 'Dr';
    }
    return isCr == true ? 'Dr' : 'Cr';
  }

  double getTotalProcessedDebit(List<Map<String, dynamic>> lst) {
    return lst.fold<double>(
        0.0,
        (sum, obj) =>
            sum +
            ((obj['originalDebit'] ?? obj['DEBIT'] ?? 0.0).abs().toDouble()));
  }

  double getTotalProcessedCredit(List<Map<String, dynamic>> lst) {
    return lst.fold<double>(
        0.0,
        (sum, obj) =>
            sum +
            ((obj['originalCredit'] ?? obj['CREDIT'] ?? 0.0).abs().toDouble()));
  }

  // Determine Dr/Cr for a group based on net closing balance and group nature (matches Angular)
  String getClosingDrCrForGroup(List<Map<String, dynamic>> lst) {
    if (lst.isEmpty) return '';

    Map<String, dynamic>? groupInfo;
    for (var item in lst) {
      if (item['groupInfo'] != null) {
        groupInfo = item['groupInfo'];
        break;
      }
    }

    groupInfo ??= lst.firstWhere((item) => item['isCr'] != null,
        orElse: () => <String, dynamic>{});

    if (groupInfo == null || groupInfo['isCr'] == null) return '';
    final isCr = groupInfo['isCr'] as bool;
    final netAmt = getNetAmountWithSign(lst);
    if (netAmt >= 0) {
      return isCr ? 'Cr' : 'Dr';
    }
    return isCr ? 'Dr' : 'Cr';
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
              : Expanded(child: accordianList(context))
        ],
      ],
    );
  }

  Widget customHeader(
      int index, Map<String, dynamic> item, bool isExpanded, String type) {
    final closingVal = getProcessedClosingBalanceValue(item);
    final closingDrCr = getClosingDrCr(item);
    final openingVal = getProcessedOpeningBalance(item);
    final openingDrCr = item['openingDrCr'] ??
        formatDrCr(
            (item['originalOpeningBalance'] ?? item['OPENINGBAL'] ?? 0.0)
                .toDouble(),
            (item['groupInfo'] != null
                    ? item['groupInfo']['isCr']
                    : item['isCr']) ==
                true)['type'];
    final debitVal = getProcessedDebit(item);
    final creditVal = getProcessedCredit(item);
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${CurrencyFormatter.format(closingVal)} ${closingDrCr}',
                          style: inter600,
                        ),
                        const SizedBox(height: 2),
                        Text(
                            'Opening: ${CurrencyFormatter.format(openingVal)} ${openingDrCr ?? ''}',
                            style: inter400),
                        Text('Debit: ${CurrencyFormatter.format(debitVal)}',
                            style: inter400),
                        Text('Credit: ${CurrencyFormatter.format(creditVal)}',
                            style: inter400),
                      ],
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
                      '${CurrencyFormatter.format(getNetAmount(value))} ${getClosingDrCrForGroup(value)}',
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
                        '${CurrencyFormatter.format(getTotalProcessedOpeningBalance(value))} ${getOpeningDrCrForGroup(value)}',
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
                        '${CurrencyFormatter.format(getTotalProcessedDebit(value))}',
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
                        '${CurrencyFormatter.format(getTotalProcessedCredit(value))}',
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

  Widget accordianList(BuildContext context) {
    return ListView.builder(
      itemCount: trialBalanceList.length,
      itemBuilder: (context, index) {
        final item = trialBalanceList[index];
        final subtitleText =
            'Opening: ${item.processedOpeningBalance} ${item.openingDrCr}, Debit: ${item.processedDebit}, Credit: ${item.processedCredit}';
        if (item.isgroup) {
          return ExpansionTile(
            title: Text(item.name),
            subtitle: Text(subtitleText),
            children: [
              if (expandedItems.containsKey(item.id))
                ...expandedItems[item.id]!
                    .map((subItem) => subItem.isgroup // Check if nested group
                        ? ExpansionTile(
                            title: Text(subItem.name),
                            subtitle: Text(
                                'Opening: ${subItem.processedOpeningBalance} ${subItem.openingDrCr}, Debit: ${subItem.processedDebit}, Credit: ${subItem.processedCredit}'),
                            children: [
                              if (expandedItems.containsKey(subItem.id))
                                ...expandedItems[subItem.id]!.map(
                                  (innerItem) => ListTile(
                                    title: Text(innerItem.name),
                                    subtitle: Text(
                                        'Opening: ${innerItem.processedOpeningBalance} ${innerItem.openingDrCr}, Debit: ${innerItem.processedDebit}, Credit: ${innerItem.processedCredit}'),
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: () => getList(item),
                                  child: const Text("Load Sub Items"),
                                )
                            ],
                          )
                        : ListTile(
                            title: Text(subItem.name),
                            subtitle: Text(
                                'Opening: ${subItem.processedOpeningBalance} ${subItem.openingDrCr}, Debit: ${subItem.processedDebit}, Credit: ${subItem.processedCredit}'),
                          ))
              else
                TextButton(
                  onPressed: () => getList(item),
                  child: const Text("Load Sub Items"),
                )
            ],
          );
        } else {
          return ListTile(
            title: Text(item.name),
            subtitle: Text(subtitleText),
          );
        }
      },
    );
  }
}

List<UpdateAddressModel> updateAddressModelFromJson(
        List<Map<String, dynamic>> str) =>
    List<UpdateAddressModel>.from(
        str.map((x) => UpdateAddressModel.fromJson(x)));

class UpdateAddressModel {
  int id;
  bool isgroup;
  String name;

  double processedOpeningBalance;
  String openingDrCr;
  double processedDebit;
  double processedCredit;
  double processedClosingBalance;
  String closingDrCr;

  double originalOpeningBalance;
  double originalDebit;
  double originalCredit;
  double originalClosingBalance;

  bool iscr;

  UpdateAddressModel({
    required this.id,
    required this.isgroup,
    required this.name,
    required this.processedOpeningBalance,
    required this.openingDrCr,
    required this.processedDebit,
    required this.processedCredit,
    required this.processedClosingBalance,
    required this.closingDrCr,
    required this.originalOpeningBalance,
    required this.originalDebit,
    required this.originalCredit,
    required this.originalClosingBalance,
    required this.iscr,
  });

  factory UpdateAddressModel.fromJson(Map<String, dynamic> json) =>
      UpdateAddressModel(
        id: json["ID"],
        isgroup: json["ISGROUP"],
        name: json["NAME"],
        processedOpeningBalance: json['processedOpeningBalance'] ?? 0.0,
        openingDrCr: json['openingDrCr'] ?? '',
        processedDebit: json['processedDebit'] ?? 0.0,
        processedCredit: json['processedCredit'] ?? 0.0,
        processedClosingBalance: json['processedClosingBalance'] ?? 0.0,
        closingDrCr: json['closingDrCr'] ?? '',
        originalOpeningBalance: json['originalOpeningBalance'] ?? 0.0,
        originalDebit: json['originalDebit'] ?? 0.0,
        originalCredit: json['originalCredit'] ?? 0.0,
        originalClosingBalance: json['originalClosingBalance'] ?? 0.0,
        iscr: json['isCr'] ?? true,
      );
}

// class TrialBalanceScreen extends StatefulWidget {
//   @override
//   _TrialBalanceScreenState createState() => _TrialBalanceScreenState();
// }

// class _TrialBalanceScreenState extends State<TrialBalanceScreen> {
//   List<UpdateAddressModel> trialBalanceList = [];
//   Map<int, List<UpdateAddressModel>> expandedItems = {};

//   @override
//   void initState() {
//     super.initState();
//     fetchTrialBalance(); // Fetch initial data without a group ID
//   }

//   Future<void> fetchTrialBalance({int? groupId}) async {
//     const url = 'https://erpapi.mlco.in/api/Report/TrialBalanceReport';
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         "fromDate": "01/01/2025 00:00:00",
//         "toDate": "14/01/2025 23:59:59",
//         "sessionId": "0ffab8af-e617-4cb0-a7b4-d24ec2ac8b49,1",
//         "groupId": groupId ?? 0,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final List<UpdateAddressModel> fetchedItems =
//           updateAddressModelFromJson(response.body);
//       setState(() {
//         if (groupId == null) {
//           trialBalanceList = fetchedItems; // Initial list
//         } else {
//           expandedItems[groupId] = fetchedItems; // Store sub-items
//         }
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }


