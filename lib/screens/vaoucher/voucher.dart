import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/common-widgets/voucher-dialog.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/global/styles.dart';
import 'package:http/http.dart' as http;
import 'package:mlco/global/utils.dart';
import 'package:mlco/global/voucherTypes.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/services/apiServices.dart';
import 'package:mlco/services/sessionCheckService.dart';
import 'package:mlco/services/voucherService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoucherScreen extends StatefulWidget {
  final VoucherType voucherType;

  const VoucherScreen({super.key, required this.voucherType});
  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;
  int? ledgerid;
  String userData = '';
  late String currentSessionId;
  String BillNo = '';
  double totalRows = 0;
  double totalGrandAmnt = 0;
  late String fromDate;
  late String toDate;
  int? voucher_TypeId;

  List<Map<String, dynamic>>? Invoices;

  @override
  void initState() {
    super.initState();
    isValidSession();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    voucher_TypeId = widget.voucherType.id;
    loadUserData();
  }

  String getInvoiceDescription(InvoiceType? invoiceType) {
    return InvoiceVoucherTypesObjByte[invoiceType] ?? 'Unknown Invoice Type';
  }

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
    try {
      var requestBody = {
        "invType": voucher_TypeId,
        "spIds": [0, 1, 2, 3],
        "isSync": false,
        "bill_No": null,
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "text": BillNo == '' ? null : BillNo,
        "ledger_ID": ledgerid,
        "sessionId": currentSessionId
      };

      var response = await getVoucherListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData['list']);
          totalRows = 00;
          totalGrandAmnt = 00;
          for (var invoice in Invoices!) {
            totalRows++;
            if (invoice['amount'] != null) {
              totalGrandAmnt = totalGrandAmnt += invoice['amount'];
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
                  '${widget.voucherType.description}',
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
                ),
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
                      String formattedDate = formatDateTime(invoice['date']);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${invoice['bill_No']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${formattedDate}',
                                  style: inter400,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        mlcoGradient.createShader(
                                            Offset.zero & bounds.size),
                                    child: Text(
                                      '${invoice['partyName']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(children: [
                                  Text(
                                    CurrencyFormatter.format(invoice['amount']),
                                    style: mlco_gradient_text2,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return VoucherDialog(
                                            sessionId: currentSessionId,
                                            id: invoice['invCode'].toString(),
                                            invType: voucher_TypeId,
                                            invoice: invoice,
                                            voucherType: widget.voucherType,
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
          outstadingBottomsheet(totalGrandAmnt, totalRows),
          CustomBottomNavBar(
              currentIndex: _selectedIndex, onTap: _onItemTapped),
        ],
      ),
    );
  }
}

Widget outstadingBottomsheet(totalamount, rows) {
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
                  'Total Taxable Value :' + ' ${formattedTotal}',
                  style: inter14_w600,
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
