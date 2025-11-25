import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/searchItem.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/reports/itemRegisterReports/itemRegisterFilter.dart';
import 'package:mlco/screens/reports/ledgerRegisterFilter.dart';
import 'package:mlco/screens/reports/toDatefilterPopup.dart';
import 'package:mlco/services/itemService.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemRegisterReportScreen extends StatefulWidget {
  @override
  _ItemRegisterReportScreenState createState() =>
      _ItemRegisterReportScreenState();
}

class _ItemRegisterReportScreenState extends State<ItemRegisterReportScreen> {
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
  double openingAmount = 0;
  double closingAmount = 0;
  double totalPending = 0;
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  late String fromDate;
  late String toDate;
  bool isAllStockPlaces = false;
  bool isStockBalDetails = false;
  int? stockPlace;
  int? itemid;
  late String todaysDate;
  String salesPerson = '';
  int? selectedParent;
  List<int> uniqueLedgerIds = [];
  List<Map<String, dynamic>> parentOutstandings = [];
  List<Map<String, dynamic>> childOutstandings = [];
  Map<String, dynamic> itemsInfo = {};
  Map<String, dynamic> itemsBalInfo = {};
  List<Map<String, dynamic>> Invoices = [];

  @override
  void initState() {
    super.initState();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    todaysDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    loadUserData();
  }

  updateDates(String from, String to, int stockPlaceId, bool isallStockPlaces,
      bool isStockDeatails) {
    setState(() {
      fromDate = from;
      toDate = to;
      isAllStockPlaces = isallStockPlaces;
      isStockBalDetails = isStockDeatails;
      stockPlace = stockPlaceId;
    });
    print('isAllStockPlaces$isAllStockPlaces');
    print('isStockBalDetails$isStockBalDetails');
    getList();
  }

  void itemChange(String item) {
    //getList();
  }

  itemSelect(Map<String, dynamic> item) {
    print('item' + item.toString());
    itemid = item['iid'];
    if (itemid != null) {
      getList();
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
    var SP = stockPlace != 001 ? stockPlace : null;
    var spId = SP != null ? [SP] : null;
    try {
      var requestBody = {
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "isOpeningStock": isAllStockPlaces,
        "stockDetail": isStockBalDetails,
        "spIds": isAllStockPlaces ? null : spId,
        "itemId": itemid,
        "sessionId": currentSessionId
      };

      var response = await itemRegisterReportListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);
          List<Map<String, dynamic>> tempInvoices = Invoices;
          totalRows = 00;
          double refAmount = 00;
          double refPending = 00;
          totalGrandAmnt = 00;
          totalPending = 00;
          openingAmount = 00;
          closingAmount = 00;
          for (var invoice in tempInvoices) {
            if (invoice['Type'] == "Opening" && invoice['Balance'] != 0) {
              openingAmount = invoice['Balance'];
            }
            if (invoice['Type'] == "Closing" && invoice['Balance'] != 0) {
              closingAmount = invoice['Balance'];
            }
          }
          int firstIndex = 0; // The first element's index
          int lastIndex = Invoices.length - 1; // The last element's index

          // Remove the entries from the array
          Invoices.removeAt(
              lastIndex); // Remove last index first to avoid shifting issues
          if (firstIndex != lastIndex) {
            Invoices.removeAt(
                firstIndex); // Remove first index if it's different
          }
          for (var invoice in Invoices) {
            totalRows++;
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

  void billNoChange(String bill) {
    print('billNoChange' + bill);
    setState(() {
      BillNo = bill;
    });
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
      appBar: MLCOAppBar(),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: SearchItem(
              onTextChanged: itemChange,
              onitemSelects: itemSelect,
            ),
          ),
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
                      'Item Register',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
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
                                child: ItemRegisterFilterPopup(
                                  onSubmit: updateDates,
                                  initialFromDate: fromDate,
                                  initialToDate: toDate,
                                  isAllSPs: isAllStockPlaces,
                                  isStockBalDetail: isStockBalDetails,
                                  stockPlace: stockPlace,
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
          SizedBox(
            height: 4,
          ),
          SizedBox(
            height: 2,
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              color: Color.fromRGBO(255, 255, 255, 1),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Opening Amount',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          mlcoGradient.createShader(Offset.zero & bounds.size),
                      child: Text(
                        CurrencyFormatter.format(openingAmount),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              )),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: Invoices.length,
                    itemBuilder: (context, index) {
                      var invoice = Invoices[index];
                      String formattedDate = '';
                      if (invoice['BillDate'] != null) {
                        DateTime date = DateTime.parse(invoice['BillDate']);
                        formattedDate = formatDateTime(invoice['BillDate']);
                      }

                      var debit = '00';
                      if (invoice['Received'] != null) {
                        debit = CurrencyFormatter.format(invoice['Received']);
                      }

                      var credit = '00';
                      if (invoice['Issued'] != null) {
                        credit = CurrencyFormatter.format(invoice['Issued']);
                      }

                      var running = '00';
                      if (invoice['Balance'] != null) {
                        running = CurrencyFormatter.format(invoice['Balance']);
                      }
                      var rate = '00';
                      if (invoice['NetRate'] != null) {
                        rate = CurrencyFormatter.format(invoice['NetRate']);
                      }
                      var perticular = '';
                      if (invoice['Party'] != null) {
                        perticular = invoice['Party'];
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
                                      Text('${invoice['billNo'] ?? ''}',
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
                                  Expanded(
                                    child: Text(
                                      '$perticular',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return InvoiceDialog(
                                            sessionId: currentSessionId,
                                            id: invoice['Invcode'].toString(),
                                            invType: 1,
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
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    'Type - ',
                                    style: inter16,
                                  ),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        mlcoGradient.createShader(
                                            Offset.zero & bounds.size),
                                    child: Text(
                                      '${invoice['Type']}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    'Stock Place - ',
                                    style: inter16,
                                  ),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        mlcoGradient.createShader(
                                            Offset.zero & bounds.size),
                                    child: Text(
                                      '${invoice['StockPlace'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
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
                                  Row(
                                    children: [
                                      Text(
                                        'Received - ',
                                        style: inter16,
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          '$debit',
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
                                        'Issued - ',
                                        style: inter16,
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          '$credit',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Balance - ',
                                        style: inter16,
                                      ),
                                      ShaderMask(
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
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Rate - ',
                                        style: inter16,
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          '${rate ?? ''}',
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
          outstadingBottomsheet(openingAmount, closingAmount, totalRows),
          CustomBottomNavBar(
              currentIndex: _selectedIndex, onTap: _onItemTapped),
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
