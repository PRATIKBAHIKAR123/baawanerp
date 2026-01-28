import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/addledgerpopup.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/invoicemenulist.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/global/styles.dart';
import 'package:http/http.dart' as http;
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/masters/ledgers/ledgerfilterpopup.dart';
import 'package:mlco/services/apiServices.dart';
import 'package:mlco/services/companyFetch.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/sessionCheckService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mlco/widgets/permission_aware_widget.dart';
import 'package:mlco/config/app_permissions.dart';

class LedgersListScreen extends StatefulWidget {
  const LedgersListScreen({super.key});
  @override
  State<LedgersListScreen> createState() => _LedgersListScreenState();
}

class _LedgersListScreenState extends State<LedgersListScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;
  Map<String, dynamic>? company;

  String userData = '';
  late String currentSessionId;
  String BillNo = '';
  String? ledgername;
  int? ledgerid;
  double totalGrandAmnt = 0;
  late String fromDate;
  late String toDate;
  String city = '';
  int? grpId;

  List<Map<String, dynamic>>? Invoices;

  @override
  void initState() {
    super.initState();
    isValidSession();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    loadUserData();
  }

  void updateDates(String _city, int? grpid) {
    setState(() {
      city = _city;
      grpId = grpid;
    });
    getList();
  }

  getList() async {
    setState(() {
      isLoading = true;
    });
    final Map<String, dynamic> jsonBody = {
      "isSync": false,
      "name": ledgername,
      "city": city,
      "groups": grpId != null ? [grpId] : null,
      "includeChildGroups": true,
      "sessionId": currentSessionId,
    };
    print('jsonBody: ${jsonBody}');
    try {
      var response = await ledgerListService(jsonBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData['list']);
          //totalRows = 00;
          totalGrandAmnt = 00;
          for (var invoice in Invoices!) {
            //totalRows++;
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

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');
    company = await CompanyDataUtil.getCompanyFromLocalStorage();
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

  ledgerSelect(Map<String, dynamic> ledger) {
    print('ledger' + ledger.toString());
    ledgerid = ledger['id'];
    if (ledgerid != null) {
      ledgername = ledger['name'];
      getList();
    } else {
      ledgername = null;
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
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            child: PermissionAwareWidget(
              permissionId: AppPermissions.can_search_ledgers,
              child: SearchLedger(
                onTextChanged: billNoChange,
                onledgerSelects: ledgerSelect,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ledger Listings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                PermissionAwareWidget(
                  permissionId: AppPermissions.can_utility_ledgers,
                  child: Container(
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
                                  child: LedgerFilterPopup(
                                    onSubmit: updateDates,
                                    initialValues: {
                                      'city': city,
                                      'group': grpId
                                    },
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
                ),
                PermissionAwareWidget(
                  permissionId: AppPermissions.can_create_ledgers,
                  child: Container(
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
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Text(
                              'Add Ledger',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return addLedgerPopup(
                                    onSubmit: (String, Object) {},
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: Invoices?.length ?? 0,
                    itemBuilder: (context, index) {
                      if (Invoices == null || Invoices!.isEmpty) {
                        return Center(
                          child: Text('No invoices found'),
                        );
                      }
                      var invoice = Invoices![index];
                      DateTime date = DateTime.parse(invoice['modified_Date']);
                      String formattedDate = formatDateTime(date.toString());
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${invoice['name']}',
                                    style: inter600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              'Group: ${invoice['group']}',
                              style: inter_13_500,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              'Contact Info: ${invoice['contactInfo']}',
                              style: inter_13_500,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PAN: ${invoice['panNo'] ?? ''}',
                                    style: inter_13_500,
                                  ),
                                  Text(
                                    '${company!.taxLabel}: ${invoice['gstNo'] ?? ''}',
                                    style: inter_13_500,
                                  ),
                                ]),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              'Address: ${invoice['address']}',
                              style: inter11400,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            if (invoice['state'] != null)
                              Text(
                                'State: ${getStateNameById(int.tryParse(invoice['state']) ?? 0)}',
                                style: inter_13_500,
                              ),
                            SizedBox(
                              height: 2,
                            ),
                            Divider()
                          ],
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
          totalRowsBottomBar(
            rows: Invoices?.length.toString() ?? '0',
          ),
          CustomBottomNavBar(
              currentIndex: _selectedIndex, onTap: _onItemTapped),
        ],
      ),
    );
  }
}

class totalRowsBottomBar extends StatelessWidget {
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
  final String rows;

  totalRowsBottomBar({required this.rows});

  @override
  Widget build(BuildContext context) {
    // Format the total amount with commas
    return Container(
      padding: EdgeInsets.all(16),
      height: 156,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(gradient: mlcoGradient2),
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
              )
            ],
          );
        },
      ),
    );
  }
}
