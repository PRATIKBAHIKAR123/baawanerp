import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/filterPopup.dart';
import 'package:mlco/common-widgets/searchbillparty.dart';
import 'package:mlco/common-widgets/totalBottomBar.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/outstanding.dart';

class OutstandingAgeingReportListScreen extends StatefulWidget {
  @override
  _OutstandingAgeingReportListScreenState createState() =>
      _OutstandingAgeingReportListScreenState();
}

class _OutstandingAgeingReportListScreenState
    extends State<OutstandingAgeingReportListScreen> {
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
  late String fromDate;
  late String toDate;

  final List<Map<String, dynamic>> Invoices = [
    {
      'partyName': 'Ambica Castwell Pvt. Ltd. (CR)',
      'bill_No': 'OGS0457/23-24',
      'voucher': 'Purchase',
      'date': '2024-01-30',
      'grandTotal': 1479.00,
      'overDue': '20 Days',
      'pending': 1479.00,
    },
    {
      'partyName': 'Ambica Castwell Pvt. Ltd. (CR)',
      'bill_No': 'OGS0457/23-24',
      'voucher': 'Purchase',
      'date': '2024-01-30',
      'grandTotal': 1479.00,
      'overDue': '20 Days',
      'pending': 1479.00,
    },
    {
      'partyName': 'Ambica Castwell Pvt. Ltd. (CR)',
      'bill_No': 'OGS0457/23-24',
      'voucher': 'Purchase',
      'date': '2024-01-30',
      'grandTotal': 1479.00,
      'overDue': '20 Days',
      'pending': 1479.00,
    },
    // Add more static data as needed
  ];

  final List<Map<String, dynamic>> quickLinks = [
    {'id': '1', 'name': 'Outstanding'},
    {'id': '2', 'name': 'Ageing Report'}
  ];

  String currntquickLink = '2';

  @override
  void initState() {
    super.initState();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
  }

  void updateDates(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
  }

  void _onQuickLinkTapped(String id) {
    print(id);
    switch (id) {
      case '1':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OutstandingReportListScreen()),
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
          SizedBox(
            height: 10,
          ),
          Container(
            child: SearchBillParty(onTextChanged: billNoChange),
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
                      'Ledger Outstanding',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          'As on 12/02/2024',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '( Gauri Dhannani )',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        )
                      ],
                    )
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
          SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickLinks.map((link) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                      onTap: () => {_onQuickLinkTapped(link['id'])},
                      child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: 164,
                          decoration: BoxDecoration(
                              gradient: link['id'] == '2'
                                  ? mlcoGradient
                                  : inactivelinksgradient,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24))),
                          child: Text(
                            link['name'],
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: link['id'] == '2'
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ))),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: Invoices.length,
              itemBuilder: (context, index) {
                var invoice = Invoices[index];
                DateTime date = DateTime.parse(invoice['date']);
                String formattedDate = DateFormat('dd/MM/yyyy').format(date);

                return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    color: Color.fromRGBO(255, 255, 255, 1),
                    elevation: 5,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        mlcoGradient.createShader(
                                            Offset.zero & bounds.size),
                                    child: Text(
                                      '31/12/2023',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '<=7 Days - ',
                                        style: inter16,
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          '₹ 0.00',
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
                                        '15 to 21 Days - ',
                                        style: inter16,
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          '₹ 0.00',
                                          style: const TextStyle(
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
                                        '22 to 42 Days - ',
                                        style: inter16,
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          '₹ 0.00',
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
                                        '8 to 14 Days - ',
                                        style: inter16,
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            mlcoGradient.createShader(
                                                Offset.zero & bounds.size),
                                        child: Text(
                                          '₹ 0.00',
                                          style: const TextStyle(
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
                              Row(
                                children: [
                                  Text(
                                    '>42 Days - ',
                                    style: inter16,
                                  ),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        mlcoGradient.createShader(
                                            Offset.zero & bounds.size),
                                    child: Text(
                                      '₹ 13,298.00',
                                      style: const TextStyle(
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
                        ),
                        Container(
                          height: 42,
                          alignment: Alignment.center,
                          width: double.infinity,
                          clipBehavior: Clip.none,
                          decoration: BoxDecoration(
                            gradient: mlcoGradient,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                          ),
                          child: Text(
                            'Total ( INR ) -₹ 13,298.00',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ));
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          outstadingBottomsheet(12, 23, 34, 45, 56, 67),
          CustomBottomNavBar(
              currentIndex: _selectedIndex, onTap: _onItemTapped),
        ],
      ),
    );
  }
}

Widget outstadingBottomsheet(
    _7_day, _14_day, _21_day, _42_day, _55_day, total) {
  final TextStyle inter14_w600 = GoogleFonts.inter(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );

  final TextStyle inter13_w600 = GoogleFonts.inter(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );
  final formattedTotal = CurrencyFormatter.format(total);
  final formatted_7_day = CurrencyFormatter.format(_7_day);
  final formatted_14_day = CurrencyFormatter.format(_14_day);
  final formatted_21_day = CurrencyFormatter.format(_21_day);
  final formatted_42_day = CurrencyFormatter.format(_42_day);
  final formatted_55_day = CurrencyFormatter.format(_55_day);
  return Container(
    padding: EdgeInsets.all(16),
    height: 200,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(gradient: mlcoGradient),
    child: BottomSheet(
      backgroundColor: Colors.transparent,
      onClosing: () {},
      builder: (BuildContext context) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '<=7 Days - ' + '$formatted_7_day',
                  style: inter13_w600,
                ),
                Text(
                  '8 to 14 Days - '
                  ' $formatted_14_day',
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
                  '15 to 21 Days - ' + ' ${formatted_21_day}',
                  style: inter13_w600,
                ),
                Text(
                  '>42 Days - ' + ' ${formatted_42_day}',
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
                  '22 to 42 Days - ' + ' ${formatted_55_day}',
                  style: inter13_w600,
                ),
              ],
            ),
            SizedBox(
              height: 6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total - ' + ' ${formattedTotal}',
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
