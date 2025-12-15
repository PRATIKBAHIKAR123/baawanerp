import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/searchItem.dart';
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
import 'package:mlco/screens/reports/ledgerOutstandingReports/agefilterPopup.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/ageing.dart';
import 'package:mlco/services/ledgerService.dart';
import 'package:mlco/services/reportsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentStockReportListScreen extends StatefulWidget {
  @override
  _CurrentStockReportListScreenState createState() =>
      _CurrentStockReportListScreenState();
}

class _CurrentStockReportListScreenState
    extends State<CurrentStockReportListScreen> {
  final TextStyle inter16 = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(129, 129, 129, 1));

  final TextStyle inter13 = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Color.fromRGBO(0, 0, 0, 1));

  int _selectedIndex = 3;
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
    _scrollController.addListener(_scrollListener);
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    todaysDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    loadUserData();
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
        "name": null,
        "itemId": itemid,
        "spId": spid == 0 ? null : spid,
        "sessionId": currentSessionId
      };

      var response = await currentStockReportListService(requestBody);
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

            // totalGrandAmnt = totalGrandAmnt +
            //     (invoice['opening'] *
            //         ((invoice['openingDrCr'] == invoice['ledgerDrCr'])
            //             ? 1
            //             : -1));
            // // totalGrandAmnt += invoice['opening'];
            // refPending = invoice['pending'] *
            //     (invoice['pendingDrCr'] == invoice['ledgerDrCr'] ? 1 : -1);
            // totalPending = totalPending + refPending;
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
                builder: (context) => CurrentStockReportListScreen()),
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
                      'Current Stock',
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
                                    'itemCode': itemCode,
                                    'brand': itemBrand,
                                    'category': itemCat,
                                    'subCategory': itemSubCat,
                                    'type': itemType,
                                    'brandCode': itemBrandCode,
                                    'stockPlace': spid,
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
              ],
            ),
          ),
          SizedBox(height: 10),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                // Expanded(
                //   flex: 6,
                //   child: Text('Item Code', style: inter13),
                // ),
                Expanded(
                  flex: 2,
                  child: Text('HO', style: inter13),
                ),
                Expanded(
                  flex: 2,
                  child: Text('CommHawk', style: inter13),
                ),
                // Expanded(
                //   flex: 2,
                //   child: Text('D_KB', style: inter13),
                // ),
                Expanded(
                  flex: 2,
                  child: Text('Warehouse', style: inter13),
                ),
                Expanded(
                  child: Text('Total', style: inter13),
                ),
                Expanded(
                  flex: 1,
                  child: Text('', style: inter13),
                ),
              ],
            ),
          ),
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
                      if (invoice['category'] != null) {
                        category = invoice['category'];
                      }
                      String subcategory = '';
                      if (invoice['sizes'] != null) {
                        subcategory = invoice['sizes'];
                      }
                      String type = '';
                      if (invoice['type'] != null) {
                        type = invoice['type'];
                      }
                      String brand = '';
                      if (invoice['brand'] != null) {
                        brand = invoice['brand'];
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
                              customHeader(index, invoice, _isExpanded[index]),
                              _isExpanded[index]
                                  ? Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: ShaderMask(
                                                shaderCallback: (bounds) =>
                                                    mlcoGradient.createShader(
                                                        Offset.zero &
                                                            bounds.size),
                                                child: Text(
                                                  invoice['itename'],
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                  Text('Category - ',
                                                      style: inter16),
                                                  Text('$category',
                                                      style: inter13),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text('Sub Category - ',
                                                  style: inter16),
                                              (Text('$subcategory',
                                                  style: inter13)),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text('Type - ',
                                                      style: inter16),
                                                  Text('$type', style: inter13),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text('Brand - ',
                                                      style: inter16),
                                                  Text('$brand',
                                                      style: inter13),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.spaceBetween,
                                          //   children: [
                                          //     Row(
                                          //       children: [
                                          //         Text('ETBL - ',
                                          //             style: inter16),
                                          //         ShaderMask(
                                          //           shaderCallback: (bounds) =>
                                          //               mlcoGradient
                                          //                   .createShader(Offset
                                          //                           .zero &
                                          //                       bounds.size),
                                          //           child: Text(
                                          //             '${invoice['ETBL']}',
                                          //             style: const TextStyle(
                                          //               fontSize: 13,
                                          //               fontWeight:
                                          //                   FontWeight.w600,
                                          //               color: Colors.white,
                                          //             ),
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //     Row(
                                          //       children: [
                                          //         Text('KB - ', style: inter16),
                                          //         ShaderMask(
                                          //           shaderCallback: (bounds) =>
                                          //               mlcoGradient
                                          //                   .createShader(Offset
                                          //                           .zero &
                                          //                       bounds.size),
                                          //           child: Text(
                                          //             '${invoice['KB']}',
                                          //             style: GoogleFonts.inter(
                                          //               fontSize: 13,
                                          //               fontWeight:
                                          //                   FontWeight.w600,
                                          //               color: Colors.white,
                                          //             ),
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ],
                                          // ),
                                          // SizedBox(height: 5),
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.spaceBetween,
                                          //   children: [
                                          //     Row(
                                          //       children: [
                                          //         Text('D_KB - ',
                                          //             style: inter16),
                                          //         ShaderMask(
                                          //           shaderCallback: (bounds) =>
                                          //               mlcoGradient
                                          //                   .createShader(Offset
                                          //                           .zero &
                                          //                       bounds.size),
                                          //           child: Text(
                                          //             '${invoice['D_KB']}',
                                          //             style: const TextStyle(
                                          //               fontSize: 13,
                                          //               fontWeight:
                                          //                   FontWeight.w600,
                                          //               color: Colors.white,
                                          //             ),
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //     Row(
                                          //       children: [
                                          //         Text('D_BP - ',
                                          //             style: inter16),
                                          //         ShaderMask(
                                          //           shaderCallback: (bounds) =>
                                          //               mlcoGradient
                                          //                   .createShader(Offset
                                          //                           .zero &
                                          //                       bounds.size),
                                          //           child: Text(
                                          //             '${invoice['D_BP']}',
                                          //             style: GoogleFonts.inter(
                                          //               fontSize: 13,
                                          //               fontWeight:
                                          //                   FontWeight.w600,
                                          //               color: Colors.white,
                                          //             ),
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ],
                                          // ),
                                          // SizedBox(height: 5),
                                          // Row(
                                          //   children: [
                                          //     Text('Total - ', style: inter16),
                                          //     ShaderMask(
                                          //       shaderCallback: (bounds) =>
                                          //           mlcoGradient.createShader(
                                          //               Offset.zero &
                                          //                   bounds.size),
                                          //       child: Text(
                                          //         '${invoice['total']}',
                                          //         style: GoogleFonts.inter(
                                          //           fontSize: 13,
                                          //           fontWeight: FontWeight.w600,
                                          //           color: Colors.white,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    )
                                  : Container(),
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

  Widget customHeader(int index, Map<String, dynamic> item, bool isExpanded) {
    String itemname = item['itemcode'] ?? '';

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                mlcoGradient.createShader(Offset.zero & bounds.size),
            child: Text(
              itemname,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      mlcoGradient.createShader(Offset.zero & bounds.size),
                  child: Text(
                    '${item['HO']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      mlcoGradient.createShader(Offset.zero & bounds.size),
                  child: Text(
                    '${item['CommHawk']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Expanded(
              //   flex: 2,
              //   child: ShaderMask(
              //     shaderCallback: (bounds) =>
              //         mlcoGradient.createShader(Offset.zero & bounds.size),
              //     child: Text(
              //       '${item['D_KB']}',
              //       style: const TextStyle(
              //         fontSize: 13,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
              Expanded(
                flex: 2,
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      mlcoGradient.createShader(Offset.zero & bounds.size),
                  child: Text(
                    '${item['Warehouse']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      mlcoGradient.createShader(Offset.zero & bounds.size),
                  child: Text(
                    '${item['total']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0, right: 2),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded[index] = !_isExpanded[index];
                    });
                  },
                  child: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
              // SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Total :' + ' ${formattedTotal}',
              //       style: inter14_w600,
              //     ),
              //     Text(
              //       'Pending :' + ' ${formattedPending}',
              //       style: inter14_w600,
              //     )
              //   ],
              // ),
            ],
          );
        },
      ),
    );
  }
}
