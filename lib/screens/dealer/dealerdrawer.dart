import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/global/voucherTypes.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/dealer/dashboard/dealerdashboard.dart';
import 'package:mlco/screens/dealer/ledgerRegisterReports/ledgerRegister.dart';
import 'package:mlco/screens/dealer/ledgerRegisterReports/outstanding.dart';
import 'package:mlco/screens/dealer/ledgerRegisterReports/targetreport.dart';
import 'package:mlco/screens/login/login.dart';
import 'package:mlco/screens/reports/Valuation.dart';
import 'package:mlco/screens/reports/itemRegisterReports/itemRegister.dart';
import 'package:mlco/screens/reports/ledgerChildOutstandingReports/ledgerChildOutstanding.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/currentStock.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/outstanding.dart';
import 'package:mlco/screens/reports/ledgerRegisterReports/ledgerRegister.dart';
import 'package:mlco/screens/reports/salesPersonReports%20copy/salesPersonReport.dart';
import 'package:mlco/screens/sales/salesEnquiry.dart';
import 'package:mlco/screens/sales/salesInvoice.dart';
import 'package:mlco/screens/sales/salesOrder.dart';
import 'package:mlco/screens/sales/salesProformaInvoice.dart';
import 'package:mlco/screens/sales/salesQuatation.dart';
import 'package:mlco/screens/sales/salesReturn.dart';
import 'package:mlco/screens/vaoucher/creditnotevoucher.dart';
import 'package:mlco/screens/vaoucher/voucher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DealerDrawer extends StatefulWidget {
  DealerDrawer({super.key});

  @override
  State<DealerDrawer> createState() => _DealerDrawerState();
}

class _DealerDrawerState extends State<DealerDrawer> {
  final TextStyle drawerTextStyle = GoogleFonts.inter(
    fontSize: 16,
    color: const Color.fromRGBO(0, 0, 0, 1),
    fontWeight: FontWeight.w500,
  );

  final TextStyle logoutTextStyle = GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: const Color.fromRGBO(208, 0, 0, 1),
  );

  int? _currentExpandedValue;

  String fyStartDate = '';
  String fyendsDate = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        String fy_startDate = userData['company']['currentFYStarts'];
        String fy_endDate = userData['company']['currentFYEnds'];

        if (fy_startDate != null) {
          setState(() {
            this.fyStartDate = formatDate(fy_startDate);
            fyendsDate = formatDate(fy_endDate);
          });
          print('Loaded fyStartDate: $fyStartDate');
        } else {
          print('fyStartDate is null or not found in userData');
        }
      } catch (e) {
        print('Error parsing userData JSON: $e');
      }
    } else {
      print('No userData found in SharedPreferences');
    }
  }

  logOut(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/mlcoic.png',
                  height: 80,
                  width: 154,
                ),
                const SizedBox(height: 8),
                Text(
                  "M. Lalwani & Co.",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Since 1944",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                createDrawerItem(
                  icon: 'assets/icons/homedrawer.png',
                  text: 'Home',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DealerDashboardScreen()),
                    );
                  },
                ),
                // createDrawerItem(
                //   icon: 'assets/icons/invoice.png',
                //   text: 'Invoice',
                //   onTap: () {},
                // ),
                // createExpandableDrawerItem(
                //   icon: 'assets/icons/invoice.png',
                //   text: 'Invoices',
                //   children: [
                //     createSubmenuItem(
                //       text: 'Sales Invoice',
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => SalesInvoiceScreen(
                //                     invoiceType: InvoiceType.salesInvoice,
                //                   )),
                //         );
                //       },
                //     ),
                //     createSubmenuItem(
                //       text: 'Sales Return',
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => SalesReturnScreen()),
                //         );
                //       },
                //     ),
                //     createSubmenuItem(
                //       text: 'Sales Order',
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => SalesOrderScreen()),
                //         );
                //       },
                //     ),
                //     createSubmenuItem(
                //       text: 'Sales Enquiry',
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => SalesEnquiryScreen()),
                //         );
                //       },
                //     ),
                //   ],
                // ),

                SizedBox(
                  height: 5,
                ),
                createExpandableDrawerItem(
                  icon: 'assets/icons/reports.png',
                  text: 'Reports',
                  children: [
                    createSubmenuItem(
                      text: 'Outstanding',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DealerOutstandingReportScreen()),
                        );
                      },
                    ),
                    createSubmenuItem(
                      text: 'Register',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DealerRegisterReportScreen()),
                        );
                      },
                    ),
                    createSubmenuItem(
                      text: 'Target Report',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TargetReportScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$fyStartDate - $fyendsDate',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  bool? result = await showConfirmationDialog(context);
                  if (result == true) {
                    // User confirmed
                    logOut(context);
                  } else {
                    // User canceled
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.exit_to_app,
                        color: Color.fromRGBO(208, 0, 0, 1)),
                    Text(
                      'Log Out',
                      style: logoutTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget createDrawerItem(
      {required String icon, required String text, GestureTapCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(246, 246, 246, 1),
          // borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromRGBO(220, 220, 220, 1),
              gradient: announcementGradient,
            ),
            child: Center(
              child: Image.asset(
                icon,
                width: 24,
                height: 24,
              ),
            ),
          ),
          title: Text(
            text,
            style: drawerTextStyle,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget createSubmenuItem({required String text, GestureTapCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(246, 246, 246, 1),
          borderRadius: BorderRadius.circular(0.0),
        ),
        child: ListTile(
          title: Text(
            text,
            style: drawerTextStyle.copyWith(fontSize: 14),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget createExpandableDrawerItem({
    required String icon,
    required String text,
    required List<Widget> children,
  }) {
    return ExpansionPanelList.radio(
      elevation: 0,
      expandedHeaderPadding: EdgeInsets.all(0),
      //radioGroupValue: _currentExpandedValue,
      children: [
        ExpansionPanelRadio(
          backgroundColor: const Color.fromRGBO(246, 246, 246, 1),
          value: 0,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
              tileColor: const Color.fromRGBO(246, 246, 246, 1),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(220, 220, 220, 1),
                  gradient: announcementGradient,
                ),
                child: Center(
                  child: Image.asset(
                    icon,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              title: Text(
                text,
                style: drawerTextStyle,
              ),
            );
          },
          body: Column(
            children: children,
          ),
          canTapOnHeader: true,
        ),
      ],
    );
  }
}

Future<bool?> showConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Log out', style: TextStyle(fontSize: 20)),
        content: Text(
          'Are you sure you want to Log Out?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true
            },
            child: Text('Yes'),
          ),
        ],
      );
    },
  );
}
