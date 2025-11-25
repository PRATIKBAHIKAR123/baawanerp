import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/searchItemcode.dart';
import 'package:mlco/common-widgets/searchLedger.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/reports/itemFIlter.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/ageing.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockValuationReportListScreen extends StatefulWidget {
  @override
  _StockValuationReportListScreenState createState() =>
      _StockValuationReportListScreenState();
}

class _StockValuationReportListScreenState
    extends State<StockValuationReportListScreen> {
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
  int? itemid;
  String itemName = '';
  String itemCode = '';
  String itemBrand = '';
  String itemCat = '';
  String itemSubCat = '';
  String itemType = '';
  String itemBrandCode = '';
  late String todaysDate;
  String salesPerson = '';
  int? spid;
  final ScrollController _scrollController = ScrollController();
  bool _isButtonVisible = true;

  List<Map<String, dynamic>> Invoices = [];
  late List<bool> _isExpanded;

  final List<Map<String, dynamic>> quickLinks = [
    {'id': '1', 'name': 'Outstanding'},
    {'id': '2', 'name': 'Ageing Report'}
  ];

  @override
  void initState() {
    super.initState();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    todaysDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onFilter(String _itemCode, String _itemBrand, String _itemCat,
      String _ItemSubCat, String _itemType, String _itemBrandCode, int spId) {
    setState(() {
      itemCode = _itemCode;
      itemBrand = _itemBrand;
      itemCat = _itemCat;
      itemSubCat = _ItemSubCat;
      itemType = _itemType;
      itemBrandCode = _itemBrandCode;
      spid = spId;
      print('spId$spId');
    });
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

  itemCodeSelect(Map<String, dynamic> item) {
    print('itemCode' + item.toString());
    itemCode = item['name'];
    if (itemCode != null) {
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
          //getList(); // Call getList() after loading user data
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
    setState(() {
      isLoading = true;
    });
    try {
      var requestBody = {
        "brand": itemBrand == '' ? null : itemBrand,
        "category": itemCat == '' ? null : itemCat,
        "sizes": itemSubCat == '' ? null : itemSubCat,
        "type": itemType == '' ? null : itemType,
        "itemGroup": itemBrandCode == '' ? null : itemBrandCode,
        "item_CodeTxt": itemCode == '' ? null : itemCode,
        "name": itemName == '' ? null : itemName,
        "itemId": itemid,
        "spId": spid == 0 ? null : spid,
        "sessionId": currentSessionId
      };

      var response = await stockValuationReportListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);
          _isExpanded = List<bool>.filled(Invoices.length, false);
          totalRows = 00;
          double refAmount = 00;
          double refPending = 00;
          totalGrandAmnt = 00;
          totalPending = 00;
          for (var invoice in Invoices) {
            totalRows++;

            totalGrandAmnt += invoice['Last_Purchase_Value'];

            totalPending += invoice['Avg_Purchase_Value'];
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

  void _onQuickLinkTapped(String id) {
    print(id);
    switch (id) {
      case '1':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StockValuationReportListScreen()),
          );
        }
        break;
      case '2':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OutstandingAgeingReportListScreen()),
          );
        }
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
    return Scaffold(
      appBar: MLCOAppBar(),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SizedBox(height: 10),
          // Container(
          //   padding: EdgeInsets.only(left: 20, right: 20),
          //   child: SearchItem(
          //     onTextChanged: itemChange,
          //     onitemSelects: itemSelect,
          //   ),
          // ),
          // SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: SearchItemCode(
              onTextChanged: itemChange,
              onitemSelects: itemCodeSelect,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Valuation',
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
                                child: ItemFilterPopup(
                                  onSubmit: onFilter,
                                  initialValues: {
                                    'itemName': itemName,
                                    'itemCode': itemCode,
                                    'brand': itemBrand,
                                    'category': itemCat,
                                    'subCategory': itemSubCat,
                                    'type': itemType,
                                    'brandCode': itemBrandCode,
                                    'stockPlace': spid,
                                  },
                                  filterType: 'valuation',
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
          SizedBox(height: 10),

          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: Invoices.length,
                    itemBuilder: (context, index) {
                      var invoice = Invoices[index];
                      String category = '';
                      if (invoice['Category'] != null) {
                        category = invoice['Category'];
                      }
                      String subcategory = '';
                      if (invoice['Sizes'] != null) {
                        subcategory = invoice['Sizes'];
                      }
                      String type = '';
                      if (invoice['Type'] != null) {
                        type = invoice['Type'];
                      }
                      String brand = '';
                      if (invoice['Brand'] != null) {
                        brand = invoice['Brand'];
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
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(invoice['Item_CodeTxt'],
                                            style: inter13),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ShaderMask(
                                            shaderCallback: (bounds) =>
                                                mlcoGradient.createShader(
                                                    Offset.zero & bounds.size),
                                            child: Expanded(
                                              child: Text(
                                                invoice['Name'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Category - ', style: inter16),
                                            Text('$category', style: inter13),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Sub Category - ',
                                                style: inter16),
                                            Text('$subcategory',
                                                style: inter13),
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
                                            Text('Type - ', style: inter16),
                                            Text('$type', style: inter13),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Brand - ', style: inter16),
                                            Text('$brand', style: inter13),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text('Total Stock- ', style: inter16),
                                        Text('${invoice['Stock'].toInt()}',
                                            style: inter13),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text('Last Purch. Rate - ',
                                            style: inter16),
                                        Text(
                                            '₹${formatAmount(invoice['Last_Purchaserate'])}',
                                            style: inter13),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text('Last Purch. Value - ',
                                            style: inter16),
                                        Text(
                                            '₹${formatAmount(invoice['Last_Purchase_Value'])}',
                                            style: inter13),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text('Avg Purch. Rate - ',
                                            style: inter16),
                                        Text(
                                            '₹${formatAmount(invoice['Avg_Purchaserate'])}',
                                            style: inter13),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text('Avg Purch. Value - ',
                                            style: inter16),
                                        Text(
                                            '₹${formatAmount(invoice['Avg_Purchase_Value'])}',
                                            style: inter13),
                                      ],
                                    ),
                                  ],
                                ),
                              )
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
          outstadingBottomsheet(totalGrandAmnt, totalPending, totalRows),
          CustomBottomNavBar(
              currentIndex: _selectedIndex, onTap: _onItemTapped),
        ],
      ),
      // floatingActionButton: _isButtonVisible
      //     ? FloatingActionButton(
      //         backgroundColor: Colors.green[100],
      //         mini: true,
      //         onPressed: () {
      //           _scrollToBottom();
      //         },
      //         child: const Icon(
      //           Icons.arrow_downward,
      //           color: Colors.green,
      //         ),
      //       )
      //     : null,
    );
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
      height: 186,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last Purch. Value Total  :' + ' ${formattedTotal}',
                    style: inter14_w600,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg Purch. Value Total  :' + ' ${formattedPending}',
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
}
