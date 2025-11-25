import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/invoicemenulist.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/global/styles.dart';
import 'package:http/http.dart' as http;
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/services/apiServices.dart';
import 'package:mlco/services/sessionCheckService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesReturnScreen extends StatefulWidget {
  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isValidSession();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    loadUserData();
  }

  String userData = '';
  late String currentSessionId;
  int? ledgerid;
  String BillNo = '';
  double totalGrandAmnt = 0;

  List<Map<String, dynamic>>? Invoices;
  late String fromDate;
  late String toDate;

  void updateDates(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    getList();
  }

  getList() async {
    String? formattedFromDate;
    String? formattedToDate;
    if (fromDate != '') {
      DateTime parsedFromDate =
          DateFormat('dd/MM/yyyy HH:mm:ss').parse(fromDate);
      formattedFromDate =
          DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    }
    if (toDate != '') {
      DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);
      formattedToDate = DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    }
    setState(() {
      isLoading = true;
    });
    final Map<String, dynamic> jsonBody = {
      "invType": 3,
      "spIds": [],
      "isSync": false,
      "bill_No": BillNo,
      "fromDate": formattedFromDate,
      "toDate": formattedToDate,
      "text": BillNo == '' ? null : BillNo,
      "ledger_ID": ledgerid,
      "sessionId": currentSessionId,
    };
    print('jsonBody: ${jsonBody}');
    var client = http.Client();
    try {
      http.Response response = await client
          .post(
            Uri.parse(invoiceurl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 50));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);
        if (decodedData.containsKey('list')) {
          setState(() {
            Invoices = List<Map<String, dynamic>>.from(decodedData['list']);
            totalGrandAmnt = 0; // Reset the total amount before summing up
            for (var invoice in Invoices!) {
              totalGrandAmnt += invoice['grandTotal'];
            }
            isLoading = false;
          });
          print('totalGrandAmnt: $totalGrandAmnt');
        } else {
          print('List not found in response body');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print(response.body);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    } finally {
      client.close();
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
      BillNo = '';
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
            child: SearchLedger(
              onTextChanged: billNoChange,
              onledgerSelects: ledgerSelect,
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
                  'Sales Return',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      DateTime date = DateTime.parse(invoice['date']);
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
                                    '${invoice['partyName']}',
                                    style: inter600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(children: [
                                  Text(
                                    CurrencyFormatter.format(
                                        invoice['grandTotal']),
                                    style: mlco_gradient_text2,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return InvoiceDialog(
                                            sessionId: currentSessionId,
                                            id: invoice['invCode'].toString(),
                                            invType: 3,
                                            invoice: invoice,
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
                                ]),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              '${invoice['bill_No']}',
                              style: inter_13_500,
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
          totalBottomBar(
            total: totalGrandAmnt,
            rows: Invoices?.length.toString() ?? '0',
          ),
          CustomBottomNavBar(
              currentIndex: _selectedIndex, onTap: _onItemTapped),
        ],
      ),
    );
  }
}
